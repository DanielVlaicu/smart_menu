from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Permite CORS pentru Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Sau setează URL-ul tău Flutter web dacă ai
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Model pentru request-uri de login/register
class UserRequest(BaseModel):
    email: str
    password: str

@app.get("/")
def home():
    return {"message": "API merge ✅"}

@app.post("/api/register")
def register(user: UserRequest):
    # Aici ai putea salva în Firestore sau face logica ta
    return {"status": "success", "email": user.email}

@app.post("/api/echo")
def echo(user: UserRequest):
    return {"echoed": user.dict()}
