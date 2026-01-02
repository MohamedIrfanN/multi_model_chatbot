import base64
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db import crud
from app.api.dependencies import get_current_user_id
from app.schemas.chat import CreateSessionRequest, SessionOut, MessageOut

router = APIRouter(prefix="/sessions", tags=["sessions"])

@router.get("", response_model=list[SessionOut])
def list_sessions(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    crud.ensure_user(db, user_id)
    sessions = crud.list_sessions(db, user_id)
    return [SessionOut(id=s.id, title=s.title) for s in sessions]

@router.post("", response_model=SessionOut)
def create_session(
    body: CreateSessionRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    crud.ensure_user(db, user_id)
    s = crud.create_session(db, user_id, title=body.title or "New chat")
    return SessionOut(id=s.id, title=s.title)

@router.get("/{session_id}/messages", response_model=list[MessageOut])
def get_messages(
    session_id: str,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    crud.ensure_user(db, user_id)

    session = crud.get_session(db, user_id, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    msgs = crud.list_messages(db, user_id, session_id, limit=500)

    def to_message_out(m):
        encoded = None
        if m.image_bytes:
            encoded = base64.b64encode(m.image_bytes).decode("utf-8")

        return MessageOut(
            id=m.id,
            role=m.role,
            content=m.content,
            image_base64=encoded,
            image_mime=m.image_mime,
        )

    return [to_message_out(m) for m in msgs]
