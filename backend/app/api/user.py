from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.api.dependencies import get_current_user_id
from app.db import models

router = APIRouter(tags=["user"])

@router.get("/me/tokens")
def get_my_tokens(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    rows = (
        db.query(models.UserTokenUsage)
        .filter(models.UserTokenUsage.user_id == user_id)
        .all()
    )

    return {
        "total": sum(r.total_tokens for r in rows),
        "by_model": {
            r.model: r.total_tokens for r in rows
        },
    }