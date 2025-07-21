# main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import auth, credentials, initialize_app, firestore
from pydantic import BaseModel

app = FastAPI()

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase Admin SDK
try:
    cred = credentials.Certificate("firebase_config.json")
    initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Firebase init error: {e}")

class AuthRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(AuthRequest):
    name: str | None = None

@app.post("/api/register")
def register(request: RegisterRequest):
    try:
        user = auth.create_user(
            email=request.email,
            password=request.password
        )

        user_data = {
            "email": request.email,
            "uid": user.uid,
            "name": request.name or "",
            "role": "user"
        }
        db.collection("users").document(user.uid).set(user_data)

        return {"status": "success", "uid": user.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/login")
def login(_):
    raise HTTPException(status_code=501, detail="Login via backend not supported. Use Firebase client SDK.")
