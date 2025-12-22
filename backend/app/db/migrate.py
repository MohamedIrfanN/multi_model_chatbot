from sqlalchemy import text
from sqlalchemy.engine import Engine

def ensure_image_columns(engine: Engine):
    with engine.connect() as conn:
        result = conn.execute(
            text("PRAGMA table_info(chat_messages)")
        ).fetchall()

        existing_cols = {row[1] for row in result}

        if "image_bytes" not in existing_cols:
            conn.execute(
                text("ALTER TABLE chat_messages ADD COLUMN image_bytes BLOB")
            )

        if "image_mime" not in existing_cols:
            conn.execute(
                text("ALTER TABLE chat_messages ADD COLUMN image_mime TEXT")
            )

        conn.commit()
