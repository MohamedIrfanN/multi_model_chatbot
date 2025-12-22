import base64
from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.database import get_db
from app.db import crud
from app.schemas.chat import CreateSessionRequest, SessionOut, MessageOut

router = APIRouter(prefix="/sessions", tags=["sessions"])

def _get_user_id(x_user_id: str | None):
    # single user now, multi-user later via auth
    return x_user_id or settings.DEFAULT_USER_ID

@router.get("", response_model=list[SessionOut])
def list_sessions(
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(x_user_id)
    crud.ensure_user(db, user_id)
    sessions = crud.list_sessions(db, user_id)
    return [SessionOut(id=s.id, title=s.title) for s in sessions]

@router.post("", response_model=SessionOut)
def create_session(
    body: CreateSessionRequest,
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(x_user_id)
    crud.ensure_user(db, user_id)
    s = crud.create_session(db, user_id, title=body.title or "New chat")
    return SessionOut(id=s.id, title=s.title)

@router.get("/{session_id}/messages", response_model=list[MessageOut])
def get_messages(
    session_id: str,
    db: Session = Depends(get_db),
    x_user_id: str | None = Header(default=None),
):
    user_id = _get_user_id(x_user_id)
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
