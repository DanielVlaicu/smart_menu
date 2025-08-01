from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, Header
from firebase_admin import auth, storage, firestore
from typing import List
from uuid import uuid4
from pydantic import BaseModel

class ReorderRequest(BaseModel):
    ordered_ids: List[str]

router = APIRouter()

def get_current_uid(authorization: str = Header(...)) -> str:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token JWT lipsă sau invalid")
    token = authorization.split(" ")[1]
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception:
        raise HTTPException(status_code=401, detail="Token Firebase invalid")

def get_firestore():
    return firestore.client()

def upload_image(uid: str, file_obj, filename: str, folder: str = "images") -> str:
    bucket = storage.bucket()
    image_id = f"{uuid4()}_{filename}"
    path = f"users/{uid}/{folder}/{image_id}"
    blob = bucket.blob(path)

    # 🔐 Adaugă token unic și setează metadata explicit
    token = str(uuid4())
    blob.metadata = {
        "firebaseStorageDownloadTokens": token
    }

    blob.upload_from_file(file_obj, content_type="image/jpeg")
    blob.patch()  # IMPORTANT: salvează metadatele

    # 🔗 Construiește URL Firebase compatibil cu `alt=media` și token
    encoded_path = path.replace("/", "%2F")
    firebase_url = (
        f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/{encoded_path}?alt=media&token={token}"
    )

    return firebase_url

def delete_image_from_url(url: str):
    try:
        bucket = storage.bucket()
        prefix = f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/"
        if url.startswith(prefix):
            path = url[len(prefix):].split("?")[0].replace("%2F", "/")
            blob = bucket.blob(path)
            blob.delete()
    except Exception as e:
        print(f"Eroare la ștergerea imaginii: {e}")



@router.post("/initialize")
def initialize_user(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    user_ref = db.collection("users").document(uid)
    existing = user_ref.get().to_dict()
    if existing and existing.get("initialized") == True:
        return {"message": "Deja inițializat"}

    category_ref = user_ref.collection("categories").document()
    category_ref.set({
        "name": "Food",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True
    })

    subcategory_ref = category_ref.collection("subcategories").document()
    subcategory_ref.set({
        "name": "Starter rece",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True
    })

    subcategory_ref.collection("products").document().set({
        "name": "Crochete",
        "price": 0.0,
        "description": "Produs implicit",
        "weight": "",
        "allergens": "",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True
    })

    user_ref.set({"initialized": True}, merge=True)
    return {"message": "User initialized cu structura default"}

# ------------------ CATEGORII ------------------

@router.post("/categories")
def create_category(
    name: str = Form(...),
    visible: bool = Form(True),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    image_url = upload_image(uid, file.file, file.filename, folder="categories")
    cat_ref = db.collection("users").document(uid).collection("categories")
    index = len(list(cat_ref.stream()))  # determină poziția în listă
    cat_doc = cat_ref.document()
    cat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "visible": visible,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "order": index  # 👈 adaugă câmpul pentru ordonare
    })
    return {"message": "Categorie creată", "id": cat_doc.id, "image_url": image_url}


@router.get("/categories", response_model=List[dict])
def get_categories(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    cats_ref = db.collection("users").document(uid).collection("categories")
    cats = cats_ref.order_by("order", direction=firestore.Query.ASCENDING).stream()
    return [{
        "id": doc.id,
        "title": doc.to_dict().get("name"),
        "image_url": doc.to_dict().get("imageUrl"),
        "visible": doc.to_dict().get("visible", True),
        "protected": doc.to_dict().get("protected", False)
    } for doc in cats]

@router.put("/categories/{category_id}")
def update_category(
    category_id: str,
    name: str = Form(...),
    visible: bool = Form(True),
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    update_data = {"name": name, "visible": visible}
    if file:
        image_url = upload_image(uid, file.file, file.filename, folder="categories")
        update_data["imageUrl"] = image_url

    db.collection("users").document(uid).collection("categories").document(category_id).update(update_data)
    return {"message": "Categorie modificată"}

@router.delete("/categories/{category_id}")
def delete_category(category_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    doc_ref = db.collection("users").document(uid).collection("categories").document(category_id)
    doc = doc_ref.get()
    if doc.exists and doc.to_dict().get("protected"):
        raise HTTPException(status_code=403, detail="Această categorie nu poate fi ștearsă")

    image_url = doc.to_dict().get("imageUrl")
    if image_url:
        delete_image_from_url(image_url)

    doc_ref.delete()
    return {"message": "Categorie ștearsă"}


# ------------------ SUBCATEGORII ------------------

@router.post("/categories/{category_id}/subcategories")
def create_subcategory(
    category_id: str,
    name: str = Form(...),
    visible: bool = Form(True),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()

    # Upload imagine pentru subcategorie
    image_url = upload_image(uid, file.file, file.filename, folder=f"categories/{category_id}/subcategories")

    # Determină ordinea pe baza numărului de subcategorii existente
    subcat_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories")
    )
    index = len(list(subcat_ref.stream()))

    # Creează documentul pentru subcategorie
    subcat_doc = subcat_ref.document()
    subcat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "visible": visible,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "order": index  # 👈 Adaugă câmpul order aici
    })

    # Creează produs implicit
    subcat_doc.collection("products").document().set({
        "name": "Produs implicit",
        "price": 0.0,
        "description": "Acesta este un produs generat automat",
        "weight": "",
        "allergens": "",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True
    })

    return {"message": "Subcategorie creată", "id": subcat_doc.id, "image_url": image_url}



@router.get("/categories/{category_id}/subcategories", response_model=List[dict])
def get_subcategories(category_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    subs_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories")
    )
    subs = subs_ref.order_by("order", direction=firestore.Query.ASCENDING).stream()
    return [{
        "id": doc.id,
        "title": doc.to_dict().get("name"),
        "image_url": doc.to_dict().get("imageUrl"),
        "visible": doc.to_dict().get("visible", True),
        "protected": doc.to_dict().get("protected", False),
        "category_id": category_id
    } for doc in subs]

@router.put("/categories/{category_id}/subcategories/{subcategory_id}")
def update_subcategory(
    category_id: str,
    subcategory_id: str,
    name: str = Form(...),
    visible: bool = Form(True),
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    subcat_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
    )
    if not subcat_ref.get().exists:
        raise HTTPException(status_code=404, detail="Subcategoria nu există")
    update_data = {"name": name, "visible": visible}
    if file:
        image_url = upload_image(uid, file.file, file.filename, folder=f"categories/{category_id}/subcategories")
        update_data["imageUrl"] = image_url

    subcat_ref.update(update_data)
    return {"message": "Subcategorie modificată"}

@router.delete("/categories/{category_id}/subcategories/{subcategory_id}")
def delete_subcategory(category_id: str, subcategory_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    doc_ref = db.collection("users").document(uid).collection("categories").document(category_id).collection("subcategories").document(subcategory_id)
    doc = doc_ref.get()
    if doc.exists and doc.to_dict().get("protected"):
        raise HTTPException(status_code=403, detail="Această subcategorie nu poate fi ștearsă")

    image_url = doc.to_dict().get("imageUrl")
    if image_url:
        delete_image_from_url(image_url)

    doc_ref.delete()
    return {"message": "Subcategorie ștearsă"}


# ------------------ PRODUSE ------------------

@router.post("/categories/{category_id}/subcategories/{subcategory_id}/products")
def create_product(
    category_id: str,
    subcategory_id: str,
    name: str = Form(...),
    price: float = Form(...),
    description: str = Form(""),
    weight: str = Form(""),
    allergens: str = Form(""),
    visible: bool = Form(True),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    image_url = upload_image(uid, file.file, file.filename,
                             folder=f"categories/{category_id}/subcategories/{subcategory_id}/products")

    # Determină ordinea produsului pe baza numărului de produse existente
    prod_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products")
    )
    index = len(list(prod_ref.stream()))

    # Creează documentul pentru produs
    prod_doc = prod_ref.document()
    prod_doc.set({
        "name": name,
        "price": price,
        "description": description,
        "weight": weight,
        "allergens": allergens,
        "visible": visible,
        "imageUrl": image_url,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "order": index  # 👈 Adaugă câmpul order aici
    })

    return {"message": "Produs creat", "id": prod_doc.id, "image_url": image_url}


@router.get("/categories/{category_id}/subcategories/{subcategory_id}/products", response_model=List[dict])
def get_products(category_id: str, subcategory_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    prod_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products")
    )
    products = prod_ref.order_by("order", direction=firestore.Query.ASCENDING).stream()
    return [{
        "id": doc.id,
        "name": doc.to_dict().get("name"),
        "price": doc.to_dict().get("price"),
        "description": doc.to_dict().get("description"),
        "weight": doc.to_dict().get("weight"),
        "allergens": doc.to_dict().get("allergens"),
        "image_url": doc.to_dict().get("imageUrl"),
        "visible": doc.to_dict().get("visible", True),
        "protected": doc.to_dict().get("protected", False),
        "subcategory_id": subcategory_id
    } for doc in products]

@router.put("/categories/{category_id}/subcategories/{subcategory_id}/products/{product_id}")
def update_product(
    category_id: str,
    subcategory_id: str,
    product_id: str,
    name: str = Form(...),
    price: float = Form(...),
    description: str = Form(""),
    weight: str = Form(""),
    allergens: str = Form(""),
    visible: bool = Form(True),
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    update_data = {
        "name": name,
        "price": price,
        "description": description,
        "weight": weight,
        "allergens": allergens,
        "visible": visible
    }
    if file:
        image_url = upload_image(uid, file.file, file.filename,
                                 folder=f"categories/{category_id}/subcategories/{subcategory_id}/products")
        update_data["imageUrl"] = image_url

    (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products").document(product_id)
          .update(update_data)
    )
    return {"message": "Produs modificat"}

@router.delete("/categories/{category_id}/subcategories/{subcategory_id}/products/{product_id}")
def delete_product(category_id: str, subcategory_id: str, product_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    doc_ref = db.collection("users").document(uid).collection("categories").document(category_id).collection("subcategories").document(subcategory_id).collection("products").document(product_id)
    doc = doc_ref.get()
    if doc.exists:
        image_url = doc.to_dict().get("imageUrl")
        if image_url:
            delete_image_from_url(image_url)

    doc_ref.delete()
    return {"message": "Produs șters"}


@router.get("/public-menu/{uid}")
def get_public_menu(uid: str):
    db = get_firestore()
    user_doc = db.collection("users").document(uid).get()
    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="Restaurantul nu există")

    restaurant_name = user_doc.to_dict().get("restaurant_name", "Meniu")
    categories_ref = db.collection("users").document(uid).collection("categories")
    categories = categories_ref.order_by("order", direction=firestore.Query.ASCENDING).stream()

    result = []
    for cat_doc in categories:
        cat = cat_doc.to_dict()
        if not cat.get("visible", True):
            continue  # ✅ Skip categoriile ascunse

        cat_data = {
            "id": cat_doc.id,
            "name": cat.get("name"),
            "image_url": cat.get("imageUrl"),
            "subcategories": []
        }

        subcat_ref = categories_ref.document(cat_doc.id).collection("subcategories")
        subcats = subcat_ref.order_by("createdAt", direction=firestore.Query.DESCENDING).stream()
        for subcat_doc in subcats:
            subcat = subcat_doc.to_dict()
            if not subcat.get("visible", True):
                continue  # ✅ Skip subcategoriile ascunse

            subcat_data = {
                "id": subcat_doc.id,
                "name": subcat.get("name"),
                "image_url": subcat.get("imageUrl"),
                "products": []
            }

            prod_ref = subcat_ref.document(subcat_doc.id).collection("products")
            prods = prod_ref.order_by("createdAt", direction=firestore.Query.DESCENDING).stream()
            for prod_doc in prods:
                prod = prod_doc.to_dict()
                if not prod.get("visible", True):
                    continue  # ✅ Skip produsele ascunse

                subcat_data["products"].append({
                    "id": prod_doc.id,
                    "name": prod.get("name"),
                    "price": prod.get("price"),
                    "description": prod.get("description"),
                    "weight": prod.get("weight"),
                    "allergens": prod.get("allergens"),
                    "image_url": prod.get("imageUrl"),
                })

            cat_data["subcategories"].append(subcat_data)

        result.append(cat_data)

    return {
        "restaurant_name": restaurant_name,
        "categories": result
    }
@router.post("/categories/reorder")
def reorder_categories(body: ReorderRequest, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    batch = db.batch()
    for index, cat_id in enumerate(body.ordered_ids):
        ref = db.collection("users").document(uid).collection("categories").document(cat_id)
        batch.update(ref, {"order": index})
    batch.commit()
    return {"message": "Ordinea categoriilor actualizată"}

@router.post("/categories/{category_id}/subcategories/reorder")
def reorder_subcategories(category_id: str, body: ReorderRequest, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    batch = db.batch()
    for index, sub_id in enumerate(body.ordered_ids):
        ref = (
            db.collection("users").document(uid)
              .collection("categories").document(category_id)
              .collection("subcategories").document(sub_id)
        )
        batch.update(ref, {"order": index})
    batch.commit()
    return {"message": "Ordinea subcategoriilor actualizată"}

@router.post("/categories/{category_id}/subcategories/{subcategory_id}/products/reorder")
def reorder_products(category_id: str, subcategory_id: str, body: ReorderRequest, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    batch = db.batch()
    for index, prod_id in enumerate(body.ordered_ids):
        ref = (
            db.collection("users").document(uid)
              .collection("categories").document(category_id)
              .collection("subcategories").document(subcategory_id)
              .collection("products").document(prod_id)
        )
        batch.update(ref, {"order": index})
    batch.commit()
    return {"message": "Ordinea produselor actualizată"}
