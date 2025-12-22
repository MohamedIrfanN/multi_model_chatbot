from dotenv import load_dotenv
import os

load_dotenv()

class Settings:
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY")
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./chat.db")
    DEFAULT_USER_ID: str = os.getenv("DEFAULT_USER_ID", "local_user")

settings = Settings()
