from openai import OpenAI
from app.core.config import settings
import base64

client = OpenAI(api_key=settings.OPENAI_API_KEY)

SYSTEM_PROMPT = "You are a helpful AI assistant."

def stream_assistant_reply(messages_for_openai):
    # messages_for_openai: list of {"role": "...", "content": "..."}
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages_for_openai,
        stream=True,
    )
    for chunk in resp:
        delta = chunk.choices[0].delta
        if delta and delta.content:
            yield delta.content
            

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
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a summarization engine."},
            {"role": "user", "content": prompt},
        ],
    )
    return resp.choices[0].message.content or ""


def stream_vision_reply(messages_for_openai):
    """
    messages_for_openai: list of OpenAI multimodal messages
    """
    resp = client.chat.completions.create(
        model="gpt-4o-mini",  # vision-capable
        messages=messages_for_openai,
        stream=True,
    )
    for chunk in resp:
        delta = chunk.choices[0].delta
        if delta and delta.content:
            yield delta.content


def image_bytes_to_base64(image_bytes: bytes) -> str:
    return base64.b64encode(image_bytes).decode("utf-8")














# from openai import OpenAI
# from app.core.config import settings

# client = OpenAI(api_key=settings.OPENAI_API_KEY)


# def stream_reply(user_message: str):
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[
#             {"role": "system", "content": "You are a helpful AI assistant."},
#             {"role": "user", "content": user_message},
#         ],
#         stream=True,
#     )

#     for chunk in response:
#         delta = chunk.choices[0].delta
#         if delta and delta.content:
#             yield delta.content
