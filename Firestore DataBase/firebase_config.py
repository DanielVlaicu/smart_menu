import firebase_admin
from firebase_admin import credentials
import json
import os


def init_firebase():
    if os.environ.get("FIREBASE_SERVICE_ACCOUNT"):
        # Railway / Cloud
        service_account_info = json.loads(os.environ["FIREBASE_SERVICE_ACCOUNT"])
        cred = credentials.Certificate(service_account_info)
    else:
        # Local (Windows / PyCharm)
        cred = credentials.Certificate("serviceAccountKey.json")

    firebase_admin.initialize_app(cred)
