from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from firebase_admin import auth
from firebase_config import init_firebase

app = FastAPI()
init_firebase()

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
        return {"success": True, "uid": user_record.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
