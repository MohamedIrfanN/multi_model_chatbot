from openai import OpenAI
from app.core.config import settings
import base64
from typing import Iterator

client = OpenAI(api_key=settings.OPENAI_API_KEY)

# -------------------------
# Defaults & constants
# -------------------------

DEFAULT_CHAT_MODEL = "gpt-4o-mini"

SYSTEM_PROMPT = "You are a helpful AI assistant."

# -------------------------
# Text-only streaming
# -------------------------

def stream_assistant_reply(
    messages_for_openai: list[dict],
    model: str | None = None,
) -> tuple[Iterator[str], dict[str, int]]:
    """
    Streams text-only assistant replies.

    messages_for_openai: list of {"role": "...", "content": "..."}
    model: OpenAI model name (defaults to gpt-4o-mini)
    """
    model = model or DEFAULT_CHAT_MODEL

    resp = client.chat.completions.create(
        model=model,
        messages=messages_for_openai,
        stream=True,
        stream_options={"include_usage": True},
    )

    usage: dict[str, int] = {
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "total_tokens": 0,
    }

    def iterator():
        for chunk in resp:
            if not chunk.choices:
                chunk_usage = getattr(chunk, "usage", None)
                if chunk_usage is not None:
                    usage["prompt_tokens"] = getattr(
                        chunk_usage, "prompt_tokens", 0
                    ) or 0
                    usage["completion_tokens"] = getattr(
                        chunk_usage, "completion_tokens", 0
                    ) or 0
                    usage["total_tokens"] = getattr(
                        chunk_usage, "total_tokens", 0
                    ) or 0
                continue

            delta = chunk.choices[0].delta
            if delta and delta.content:
                yield delta.content

    return iterator(), usage

    

# -------------------------
# Rolling summary (unchanged)
# -------------------------

def summarize_chat(previous_summary: str, recent_messages_text: str) -> str:
    """
    Produces a rolling summary. Keep it short, stable, and focused on:
    goals, decisions, constraints, and key facts.
    """
    prompt = f"""
    You maintain a rolling conversation summary used as memory.
    Update the summary using the new messages. Keep it concise and factual.

    Previous summary:
    {previous_summary}

    New messages:
    {recent_messages_text}

    Return the updated summary only.
    """.strip()

    resp = client.chat.completions.create(
        model=DEFAULT_CHAT_MODEL,
        messages=[
            {"role": "system", "content": "You are a summarization engine."},
            {"role": "user", "content": prompt},
        ],
    )

    return resp.choices[0].message.content or ""


# -------------------------
# Vision (image + text)
# -------------------------

def stream_vision_reply(
    messages_for_openai: list[dict],
    model: str | None = None,
) -> tuple[Iterator[str], dict[str, int]]:
    """
    Streams vision + text replies.

    messages_for_openai: multimodal OpenAI messages
    model: OpenAI model name (defaults to gpt-4o-mini)
    """
    model = model or DEFAULT_CHAT_MODEL

    resp = client.chat.completions.create(
        model=model,
        messages=messages_for_openai,
        stream=True,
        stream_options={"include_usage": True},
    )

    usage: dict[str, int] = {
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "total_tokens": 0,
    }

    def iterator():
        for chunk in resp:
            if not chunk.choices:
                chunk_usage = getattr(chunk, "usage", None)
                if chunk_usage is not None:
                    usage["prompt_tokens"] = getattr(
                        chunk_usage, "prompt_tokens", 0
                    ) or 0
                    usage["completion_tokens"] = getattr(
                        chunk_usage, "completion_tokens", 0
                    ) or 0
                    usage["total_tokens"] = getattr(
                        chunk_usage, "total_tokens", 0
                    ) or 0
                continue

            delta = chunk.choices[0].delta
            if delta and delta.content:
                yield delta.content

    return iterator(), usage


# -------------------------
# Utilities
# -------------------------

def image_bytes_to_base64(image_bytes: bytes) -> str:
    return base64.b64encode(image_bytes).decode("utf-8")


# -------------------------
# Title generation (unchanged)
# -------------------------

def stream_title_from_prompt(user_prompt: str):
    """
    Generates a short chat title based on the first user prompt.
    """
    instruction = (
        "Create a brief, descriptive chat title (max 6 words). "
        "Use Title Case and avoid quotes or punctuation at the end."
    )

    resp = client.chat.completions.create(
        model=DEFAULT_CHAT_MODEL,
        messages=[
            {"role": "system", "content": instruction},
            {
                "role": "user",
                "content": (
                    "Conversation opening message:\n"
                    f"{user_prompt}\n\n"
                    "Return only the title."
                ),
            },
        ],
        temperature=0.3,
        max_tokens=32,
        stream=True,
    )

    for chunk in resp:
        delta = chunk.choices[0].delta
        if delta and delta.content:
            yield delta.content
