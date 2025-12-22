from fastapi import FastAPI
from app.db.database import Base, engine
from app.api.sessions import router as sessions_router
from app.api.chat import router as chat_router
from app.db.migrate import ensure_image_columns

def create_tables():
    Base.metadata.create_all(bind=engine)
    ensure_image_columns(engine)

create_tables()

app = FastAPI(title="Multimodal Chat Backend")

app.include_router(sessions_router)
app.include_router(chat_router)
