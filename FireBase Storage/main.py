from google.cloud import storage

# Inițializează storage client
storage_client = storage.Client.from_service_account_json('serviceAccountKey.json')

# Numele bucket-ului tău, îl găsești în Firebase Console la Storage (ex: 'nume-proiect.appspot.com')
bucket_name = 'smartmenu-d3e47.firebasestorage.app'
bucket = storage_client.bucket(bucket_name)

# Numele local și numele sub care vrei să salvezi fișierul în storage
file_path = 'imagine_test.jpg'
blob = bucket.blob(f'imagini/{file_path}')

# Upload!
blob.upload_from_filename(file_path)
print('Imagine urcată cu succes!')

# Obține URL-ul de acces public
url = blob.public_url
print('URL public:', url)
