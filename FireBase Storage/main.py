from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from firebase_config import init_firebase
from gallery_service import router

# 🔐 Inițializează Firebase o singură dată
init_firebase()

app = FastAPI()

# 🔄 Activează CORS pentru a permite apeluri din Flutter/Web etc.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 👉 poți înlocui cu domeniul frontendului pentru mai multă securitate
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Încarcă rutele definite în gallery_service
app.include_router(router)
