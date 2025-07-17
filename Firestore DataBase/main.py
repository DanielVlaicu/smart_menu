from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, auth, firestore

app = Flask(__name__)

cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

@app.route('/api/save_user', methods=['POST'])
def save_user():
    data = request.get_json()
    id_token = data.get('id_token')
    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token['uid']
        email = decoded_token.get('email', '')
        name = decoded_token.get('name', '')

        db.collection('users').document(uid).set({
            'uid': uid,
            'email': email,
            'name': name,
            'last_login': firestore.SERVER_TIMESTAMP
        }, merge=True)

        return jsonify({'status': 'success', 'uid': uid})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
