from pydantic import BaseModel
from typing import Optional, Literal, List

class CreateSessionRequest(BaseModel):
    title: Optional[str] = "New chat"

class SessionOut(BaseModel):
    id: str
    title: str

class MessageOut(BaseModel):
    id: str
    role: Literal["user", "assistant"]
    content: Optional[str] = None
    image_base64: Optional[str] = None
    image_mime: Optional[str] = None

class ChatStreamRequest(BaseModel):
    session_id: str
    message: str
    # multi-user later: accept from auth; for now optional override
    user_id: Optional[str] = None

class ChatTitleRequest(BaseModel):
    session_id: str
    prompt: str
    user_id: Optional[str] = None











# from pydantic import BaseModel
# from typing import Optional

# class ChatRequest(BaseModel):
#     message: str

# class ChatResponse(BaseModel):
#     reply: str
