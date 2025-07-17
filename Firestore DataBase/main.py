import firebase_admin
from firebase_admin import credentials, firestore

# 1. Inițializează Firebase
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. Adaugă un user
db.collection('users').add({'name': 'Jhon', 'email': 'jhon@email.com'})
print("User adăugat!")

# 3. Citește toți userii
print("Toți userii din Firestore:")
users_ref = db.collection('users')
docs = users_ref.stream()
for doc in docs:
    print(f'{doc.id} => {doc.to_dict()}')
