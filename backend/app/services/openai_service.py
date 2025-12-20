from openai import OpenAI
from app.core.config import settings

client = OpenAI(api_key=settings.OPENAI_API_KEY)

# def generate_reply(user_message: str) -> str:
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[
#             {"role": "system", "content": "You are a helpful AI assistant."},
#             {"role": "user", "content": user_message},
#         ],
#     )

#     return response.choices[0].message.content

def stream_reply(user_message: str):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a helpful AI assistant."},
            {"role": "user", "content": user_message},
        ],
        stream=True,
    )

    for chunk in response:
        delta = chunk.choices[0].delta
        if delta and delta.content:
            yield delta.content
