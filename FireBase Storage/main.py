from fastapi import FastAPI
from firebase_config import init_firebase
from gallery_service import router

# Initializează Firebase o singură dată
init_firebase()

app = FastAPI()

# Încarcă rutele definite în gallery_service
app.include_router(router)