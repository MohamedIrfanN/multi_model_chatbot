from fastapi import APIRouter
from app.schemas.chat import ChatRequest, ChatResponse
# from app.services.openai_service import generate_reply
from fastapi.responses import StreamingResponse
from app.services.openai_service import stream_reply

router = APIRouter()

# @router.post("/chat", response_model=ChatResponse)
# def chat(request: ChatRequest):
#     print("📩 Received message:", request.message)
#     reply = generate_reply(request.message)
#     print("📤 Sending reply")
#     return ChatResponse(reply=reply)


@router.post("/chat")
def chat(request: ChatRequest):
    return StreamingResponse(
        stream_reply(request.message),
        media_type="text/plain",
    )
