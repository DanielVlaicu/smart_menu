# Folosește o imagine Python oficială
FROM python:3.12-slim

# Setează directorul de lucru
WORKDIR /app

# Copiază fișierele în container
COPY . .

# Instalează dependențele
RUN pip install --no-cache-dir -r requirements.txt

# Rulează FastAPI folosind uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
