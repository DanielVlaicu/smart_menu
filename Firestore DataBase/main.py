from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, Depends
from auth import verify_token
from database import db

app = FastAPI()

# Activează CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # sau doar frontend-ul tău
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.get("/")
def root():
    return {"message": "API is running 🚀"}

@app.get("/users")
async def get_users(user_data=Depends(verify_token)):
    users_ref = db.collection("users")
    docs = users_ref.stream()
    return [{**doc.to_dict(), "id": doc.id} for doc in docs]
