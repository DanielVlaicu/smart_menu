import firebase_admin
from firebase_admin import credentials
import json
import os

def init_firebase():
    service_account_info = json.loads(os.environ["FIREBASE_KEY"])
    cred = credentials.Certificate(service_account_info)
    firebase_admin.initialize_app(cred)
