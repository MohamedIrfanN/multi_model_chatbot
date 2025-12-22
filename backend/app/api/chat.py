from fastapi import APIRouter, Depends, Header, HTTPException, UploadFile, File, Form
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.api.utils import ALLOWED_IMAGE_MIME_TYPES, MAX_IMAGE_SIZE_BYTES
from app.core.config import settings
from app.db.database import get_db
from app.db import crud
from app.schemas.chat import ChatStreamRequest, ChatTitleRequest
from app.services.openai_service import (
    SYSTEM_PROMPT,
    image_bytes_to_base64,
    stream_assistant_reply,
    stream_title_from_prompt,
    stream_vision_reply,
    summarize_chat,
)

router = APIRouter(tags=["chat"])

WINDOW_LIMIT = 8          # last N messages sent verbatim
SUMMARY_UPDATE_EVERY = 8  # update summary after N new assistant messages (simple v1)

def _get_user_id(req_user_id: str | None, header_user_id: str | None):
    return req_user_id or header_user_id or settings.DEFAULT_USER_ID

@router.post("/chat")
def chat_stream(
    body: ChatStreamRequest,
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(body.user_id, x_user_id)
    crud.ensure_user(db, user_id)

    session = crud.get_session(db, user_id, body.session_id)
    if not session:
        # Create session automatically if client sends unknown session_id?
        # Better: return 404. You can choose either behavior.
        raise HTTPException(status_code=404, detail="Session not found")

    # 1) Save user message
    crud.add_message(db, user_id, body.session_id, role="user", content=body.message)

    # 2) Build context: system + summary + window
    summary = crud.get_summary(db, user_id, body.session_id)
    recent = crud.get_recent_messages(db, user_id, body.session_id, limit=WINDOW_LIMIT)

    openai_messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    if summary.strip():
        openai_messages.append(
            {"role": "system", "content": f"Conversation summary (memory):\n{summary}"}
        )

    for m in recent:
        openai_messages.append({"role": m.role, "content": m.content})

    # 3) Stream assistant reply, but buffer full text to persist after streaming
    def generator():
        assistant_full = ""
        try:
            for token in stream_assistant_reply(openai_messages):
                assistant_full += token
                yield token
        finally:
            if assistant_full.strip():
                crud.add_message(db, user_id, body.session_id, role="assistant", content=assistant_full)
                crud.touch_session(db, user_id, body.session_id, title_if_new=body.message)

                # Update rolling summary only every SUMMARY_UPDATE_EVERY assistant messages
                assistant_count = crud.count_assistant_messages(db, user_id, body.session_id)

                if assistant_count % SUMMARY_UPDATE_EVERY == 0:
                    prev = crud.get_summary(db, user_id, body.session_id)
                    recent2 = crud.get_recent_messages(
                        db, user_id, body.session_id, limit=WINDOW_LIMIT
                    )

                    recent_text = "\n".join(
                        [f"{m.role}: {m.content}" for m in recent2]
                    )
                    new_summary = summarize_chat(prev, recent_text)
                    crud.set_summary(db, user_id, body.session_id, new_summary)


    # NOTE: We will fix summary update cleanly in the next message (see below)
    return StreamingResponse(generator(), media_type="text/plain")




@router.post("/chat/image")
def chat_image_stream(
    session_id: str = Form(...),
    image: UploadFile = File(...),
    text: str | None = Form(None),
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(None, x_user_id)
    crud.ensure_user(db, user_id)

    # Validate session
    session = crud.get_session(db, user_id, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Validate image type
    if image.content_type not in ALLOWED_IMAGE_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported image type: {image.content_type}",
        )

    image_bytes = image.file.read()

    # Validate image size
    if len(image_bytes) > MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(
            status_code=400,
            detail="Image exceeds 5MB limit",
        )

    # 1️⃣ Persist user message (image + optional text)
    crud.add_message(
        db,
        user_id=user_id,
        session_id=session_id,
        role="user",
        content=text,
        image_bytes=image_bytes,
        image_mime=image.content_type,
    )

    # 2️⃣ Build context (summary + window)
    summary = crud.get_summary(db, user_id, session_id)
    recent = crud.get_recent_messages(db, user_id, session_id, limit=WINDOW_LIMIT)

    openai_messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    if summary.strip():
        openai_messages.append(
            {
                "role": "system",
                "content": f"Conversation summary (memory):\n{summary}",
            }
        )

    for m in recent:
        if m.image_bytes:
            content_blocks = []

            if m.content:
                content_blocks.append({
                    "type": "text",
                    "text": m.content
                })

            content_blocks.append({
                "type": "image_url",
                "image_url": {
                    "url": f"data:{m.image_mime};base64,{image_bytes_to_base64(m.image_bytes)}"
                }
            })
            openai_messages.append(
                {"role": m.role, "content": content_blocks}
            )
        else:
            openai_messages.append(
                {"role": m.role, "content": m.content}
            )

    # 3️⃣ Stream assistant response
    def generator():
        assistant_full = ""
        try:
            for token in stream_vision_reply(openai_messages):
                assistant_full += token
                yield token
        finally:
            if assistant_full.strip():
                crud.add_message(
                    db,
                    user_id=user_id,
                    session_id=session_id,
                    role="assistant",
                    content=assistant_full,
                )

                crud.touch_session(
                    db,
                    user_id,
                    session_id,
                    title_if_new=text or "Image message",
                )

                # Update rolling summary only every SUMMARY_UPDATE_EVERY assistant messages
                assistant_count = crud.count_assistant_messages(db, user_id, session_id)

                if assistant_count % SUMMARY_UPDATE_EVERY == 0:
                    prev = crud.get_summary(db, user_id, session_id)
                    recent2 = crud.get_recent_messages(
                        db, user_id, session_id, limit=WINDOW_LIMIT
                    )

                    recent_text = "\n".join(
                        [
                            f"{m.role}: {m.content or '[image]'}"
                            for m in recent2
                        ]
                    )
                    new_summary = summarize_chat(prev, recent_text)
                    crud.set_summary(db, user_id, session_id, new_summary)

    return StreamingResponse(generator(), media_type="text/plain")


@router.post("/chat/title")
def chat_title_stream(
    body: ChatTitleRequest,
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(body.user_id, x_user_id)
    crud.ensure_user(db, user_id)

    session = crud.get_session(db, user_id, body.session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    prompt = body.prompt.strip()
    if not prompt:
        raise HTTPException(status_code=400, detail="Prompt is required")

    def generator():
        title_full = ""
        try:
            for token in stream_title_from_prompt(prompt):
                title_full += token
                yield token
        finally:
            cleaned = title_full.strip()
            if cleaned:
                crud.update_session_title(db, user_id, body.session_id, cleaned)

    return StreamingResponse(generator(), media_type="text/plain")
