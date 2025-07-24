# Imagine de bază cu Python 3.12
FROM python:3.12-slim

# Setare director de lucru
WORKDIR /app

# Copiază fișierul requirements.txt și instalează dependențele
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiază restul codului în container
COPY . .

# ✅ Setează portul de expunere (opțional pentru local, recomandat pentru claritate)
EXPOSE 8000

# ✅ Rulează aplicația FastAPI pe 0.0.0.0:8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
