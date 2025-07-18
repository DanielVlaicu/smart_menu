from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import os

app = FastAPI()

FIREBASE_API_KEY = os.environ.get('FIREBASE_API_KEY')

cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def firebase_register(email, password):
    url = f'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={FIREBASE_API_KEY}'
    payload = {'email': email, 'password': password, 'returnSecureToken': True}
    return requests.post(url, json=payload)

def firebase_login(email, password):
    url = f'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_API_KEY}'
    payload = {'email': email, 'password': password, 'returnSecureToken': True}
    return requests.post(url, json=payload)

@app.post('/api/register')
async def register(request: Request):
    data = await request.json()
    email = data.get('email')
    password = data.get('password')
    if not email or not password:
        return JSONResponse({'status': 'error', 'message': 'Email și parolă lipsesc'}, status_code=400)
    resp = firebase_register(email, password)
    resp_json = resp.json()
    if resp.status_code == 200:
        uid = resp_json['localId']
        db.collection('users').document(uid).set({
            'uid': uid,
            'email': email,
            'registered_at': firestore.SERVER_TIMESTAMP,
            'last_login': firestore.SERVER_TIMESTAMP
        })
        return JSONResponse({'status': 'success', 'message': 'Cont creat cu succes!', 'uid': uid})
    else:
        msg = resp_json.get('error', {}).get('message', 'Unknown error')
        if msg == 'EMAIL_EXISTS':
            return JSONResponse({'status': 'error', 'message': 'Email deja folosit'}, status_code=409)
        return JSONResponse({'status': 'error', 'message': msg}, status_code=400)

@app.post('/api/login')
async def login(request: Request):
    data = await request.json()
    email = data.get('email')
    password = data.get('password')
    if not email or not password:
        return JSONResponse({'status': 'error', 'message': 'Email și parolă lipsesc'}, status_code=400)
    resp = firebase_login(email, password)
    resp_json = resp.json()
    if resp.status_code == 200:
        uid = resp_json['localId']
        db.collection('users').document(uid).set({
            'uid': uid,
            'email': email,
            'last_login': firestore.SERVER_TIMESTAMP
        }, merge=True)
        return JSONResponse({'status': 'success', 'message': 'Login reușit!', 'uid': uid})
    else:
        msg = resp_json.get('error', {}).get('message', 'Unknown error')
        if msg == 'EMAIL_NOT_FOUND':
            return JSONResponse({'status': 'error', 'message': 'Cont inexistent.'}, status_code=404)
        elif msg == 'INVALID_PASSWORD':
            return JSONResponse({'status': 'error', 'message': 'Parolă greșită'}, status_code=401)
        return JSONResponse({'status': 'error', 'message': msg}, status_code=400)

@app.get('/api/users')
def get_all_users():
    users_ref = db.collection('users').stream()
    users = [doc.to_dict() for doc in users_ref]
    return {'users': users}

@app.get('/api/users/{uid}')
def get_user(uid: str):
    doc = db.collection('users').document(uid).get()
    if doc.exists:
        return doc.to_dict()
    else:
        raise HTTPException(status_code=404, detail="User not found")

@app.put('/api/users/{uid}')
async def update_user(uid: str, request: Request):
    data = await request.json()
    doc_ref = db.collection('users').document(uid)
    doc = doc_ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="User not found")
    doc_ref.update(data)
    return {"status": "success", "message": "User updated"}

@app.delete('/api/users/{uid}')
def delete_user(uid: str):
    doc_ref = db.collection('users').document(uid)
    doc = doc_ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="User not found")
    doc_ref.delete()
    return {"status": "success", "message": "User deleted"}

@app.get('/api/test')
def test():
    return {"msg": "Backend FastAPI+Firestore merge!"}
