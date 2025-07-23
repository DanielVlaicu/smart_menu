import firebase_admin
from firebase_admin import credentials, storage, firestore

def init_firebase():
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'smartmenu-d3e47.firebasestorage.app'
    })
