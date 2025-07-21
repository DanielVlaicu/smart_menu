from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from firebase_admin import auth, firestore
from firebase_config import init_firebase
from fastapi.middleware.cors import CORSMiddleware

init_firebase()
app = FastAPI()
db = firestore.client()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Poți restricționa doar la domeniul tău Flutter web / mobil
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class User(BaseModel):
    email: str
    password: str

@app.post("/register")
def register(user: User):
    try:
        user_record = auth.create_user(
            email=user.email,
            password=user.password
        )

        db.collection('users').document(user_record.uid).set({
            'email': user.email,
            'created_at': firestore.SERVER_TIMESTAMP,
            'role': 'user'
        })

        return {"success": True, "uid": user_record.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
