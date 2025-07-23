# Imagine de bază oficială
FROM python:3.12-slim

# Setează directorul de lucru
WORKDIR /app

# Copiază tot codul
COPY . .

# Instalează dependințele
RUN pip install --no-cache-dir -r requirements.txt

# Expune portul
EXPOSE 8000

# Comandă de pornire
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
