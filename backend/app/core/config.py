from dotenv import load_dotenv
import os

load_dotenv()


class Settings:
    # OpenAI
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY")

    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./chat.db")

    # Auth / Security
    JWT_SECRET: str = os.getenv("JWT_SECRET")

    # Dev fallback (temporary)
    DEFAULT_USER_ID: str = os.getenv("DEFAULT_USER_ID", "local_user")


settings = Settings()