import uuid
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.db import models

def ensure_user(db: Session, user_id: str):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        user = models.User(id=user_id)
        db.add(user)
        db.commit()
    return user

def create_session(db: Session, user_id: str, title: str = "New chat") -> models.ChatSession:
    session = models.ChatSession(
        id=str(uuid.uuid4()),
        user_id=user_id,
        title=title,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    # Create empty summary row (optional but convenient)
    summary = models.ChatSummary(
        session_id=session.id,
        user_id=user_id,
        summary="",
        updated_at=datetime.now(timezone.utc),
    )
    db.add(summary)
    db.commit()
    return session

def list_sessions(db: Session, user_id: str):
    return (
        db.query(models.ChatSession)
        .filter(models.ChatSession.user_id == user_id)
        .order_by(desc(models.ChatSession.updated_at))
        .all()
    )

def get_session(db: Session, user_id: str, session_id: str) -> models.ChatSession | None:
    return (
        db.query(models.ChatSession)
        .filter(models.ChatSession.user_id == user_id, models.ChatSession.id == session_id)
        .first()
    )

def touch_session(db: Session, user_id: str, session_id: str, title_if_new: str | None = None):
    session = get_session(db, user_id, session_id)
    if not session:
        return None
    if title_if_new and session.title == "New chat":
        session.title = title_if_new
    session.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(session)
    return session

def add_message(
    db,
    user_id: str,
    session_id: str,
    role: str,
    content: str | None = None,
    image_bytes: bytes | None = None,
    image_mime: str | None = None,
):
    msg = models.ChatMessage(
        id=str(uuid.uuid4()),
        user_id=user_id,
        session_id=session_id,
        role=role,
        content=content,
        image_bytes=image_bytes,
        image_mime=image_mime,
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg

def update_session_title(db: Session, user_id: str, session_id: str, title: str):
    session = get_session(db, user_id, session_id)
    if not session:
        return None
    sanitized = title.strip()
    if not sanitized:
        return None

    session.title = sanitized[:80]
    session.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(session)
    return session

def get_recent_messages(db: Session, user_id: str, session_id: str, limit: int):
    # newest first, then we reverse in service
    rows = (
        db.query(models.ChatMessage)
        .filter(
            models.ChatMessage.user_id == user_id,
            models.ChatMessage.session_id == session_id,
        )
        .order_by(desc(models.ChatMessage.created_at))
        .limit(limit)
        .all()
    )
    return list(reversed(rows))

def list_messages(db: Session, user_id: str, session_id: str, limit: int = 200):
    rows = (
        db.query(models.ChatMessage)
        .filter(
            models.ChatMessage.user_id == user_id,
            models.ChatMessage.session_id == session_id,
        )
        .order_by(models.ChatMessage.created_at)
        .limit(limit)
        .all()
    )
    return rows

def get_summary(db: Session, user_id: str, session_id: str) -> str:
    row = (
        db.query(models.ChatSummary)
        .filter(models.ChatSummary.user_id == user_id, models.ChatSummary.session_id == session_id)
        .first()
    )
    return row.summary if row else ""

def set_summary(db: Session, user_id: str, session_id: str, summary: str):
    row = (
        db.query(models.ChatSummary)
        .filter(models.ChatSummary.user_id == user_id, models.ChatSummary.session_id == session_id)
        .first()
    )
    if not row:
        row = models.ChatSummary(session_id=session_id, user_id=user_id, summary=summary)
        db.add(row)
    else:
        row.summary = summary
        row.updated_at = datetime.now(timezone.utc)
    db.commit()

def count_assistant_messages(db, user_id: str, session_id: str) -> int:
    return (
        db.query(models.ChatMessage)
        .filter(
            models.ChatMessage.user_id == user_id,
            models.ChatMessage.session_id == session_id,
            models.ChatMessage.role == "assistant",
        )
        .count()
    )
