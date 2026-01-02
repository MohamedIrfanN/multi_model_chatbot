from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db import crud
from app.schemas.auth import RegisterRequest, LoginRequest

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register")
def register(body: RegisterRequest, db: Session = Depends(get_db)):
    email = body.email.lower().strip()
    password = body.password

    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")
    
    if len(password) > 128:
        raise HTTPException(status_code=400, detail="Password too long (max 128 characters).")

    existing = crud.get_user_auth_by_email(db, email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_id = crud.new_user_id()
    crud.create_user(db, user_id)

    password_hash = crud.hash_password(password)
    crud.create_user_auth(db, user_id=user_id, email=email, password_hash=password_hash)

    token = crud.create_access_token(user_id)
    return {"access_token": token, "user_id": user_id}


@router.post("/login")
def login(body: LoginRequest, db: Session = Depends(get_db)):
    email = body.email.lower().strip()
    password = body.password

    user_auth = crud.get_user_auth_by_email(db, email)
    if not user_auth:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not crud.verify_password(password, user_auth.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = crud.create_access_token(user_auth.user_id)
    return {"access_token": token, "user_id": user_auth.user_id}