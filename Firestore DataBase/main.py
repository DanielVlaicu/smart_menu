from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import auth, credentials, initialize_app
from pydantic import BaseModel
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[""],
    allow_credentials=True,
    allow_methods=[""],
    allow_headers=["*"],
)

if not len(auth._get_client().project_id):
    cred = credentials.Certificate("firebase_config.json")
    initialize_app(cred)

class AuthRequest(BaseModel):
    email: str
    password: str

@app.post("/api/register")
def register(request: AuthRequest):
    try:
        user = auth.create_user(
            email=request.email,
            password=request.password
        )
        return {"status": "success", "uid": user.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/login")
def login(request: AuthRequest):
    # Firebase Admin SDK does not support signInWithEmailPassword directly
    # This should be done from the client (Flutter) or use Firebase REST API
    raise HTTPException(status_code=501, detail="Login via backend not supported. Use Firebase client SDK.")
