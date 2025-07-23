from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, Header
from firebase_admin import auth, storage, firestore
from typing import List
from uuid import uuid4

router = APIRouter()

# 🔒 Obține UID din ID Token Firebase
def get_current_uid(authorization: str = Header(...)) -> str:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token JWT lipsă sau invalid")
    token = authorization.split(" ")[1]
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception:
        raise HTTPException(status_code=401, detail="Token Firebase invalid")

# 🔧 Obține instanța Firestore
def get_firestore():
    return firestore.client()

# ☁️ Încarcă imagine în Firebase Storage
def upload_image(uid: str, file_obj, filename: str, folder: str = "images") -> str:
    bucket = storage.bucket()
    image_id = f"{uuid4()}_{filename}"
    path = f"users/{uid}/{folder}/{image_id}"
    blob = bucket.blob(path)
    blob.upload_from_file(file_obj, content_type="image/jpeg")
    blob.make_public()
    return blob.public_url

# 🟦 CATEGORII

@router.post("/categories")
def create_category(
    name: str = Form(...),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    image_url = upload_image(uid, file.file, file.filename, folder="categories")
    cat_doc = db.collection("users").document(uid).collection("categories").document()
    cat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    return {"message": "Categorie creată", "id": cat_doc.id, "imageUrl": image_url}

@router.get("/categories", response_model=List[dict])
def get_categories(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    cats_ref = db.collection("users").document(uid).collection("categories")
    cats = cats_ref.order_by("createdAt", direction=firestore.Query.DESCENDING).stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in cats]

@router.put("/categories/{category_id}")
def update_category(
    category_id: str,
    name: str = Form(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    db.collection("users").document(uid).collection("categories").document(category_id).update({
        "name": name
    })
    return {"message": "Categorie modificată"}

@router.delete("/categories/{category_id}")
def delete_category(category_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    db.collection("users").document(uid).collection("categories").document(category_id).delete()
    return {"message": "Categorie ștearsă"}

# 🟨 SUBCATEGORII

@router.post("/categories/{category_id}/subcategories")
def create_subcategory(
    category_id: str,
    name: str = Form(...),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    image_url = upload_image(uid, file.file, file.filename, folder=f"categories/{category_id}/subcategories")
    subcat_doc = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document()
    )
    subcat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    return {"message": "Subcategorie creată", "id": subcat_doc.id, "imageUrl": image_url}

@router.get("/categories/{category_id}/subcategories", response_model=List[dict])
def get_subcategories(category_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    subs_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories")
    )
    subs = subs_ref.order_by("createdAt", direction=firestore.Query.DESCENDING).stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in subs]

@router.put("/categories/{category_id}/subcategories/{subcategory_id}")
def update_subcategory(
    category_id: str,
    subcategory_id: str,
    name: str = Form(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .update({"name": name})
    )
    return {"message": "Subcategorie modificată"}

@router.delete("/categories/{category_id}/subcategories/{subcategory_id}")
def delete_subcategory(category_id: str, subcategory_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .delete()
    )
    return {"message": "Subcategorie ștearsă"}

# 🟩 PRODUSE

@router.post("/categories/{category_id}/subcategories/{subcategory_id}/products")
def create_product(
    category_id: str,
    subcategory_id: str,
    name: str = Form(...),
    price: float = Form(...),
    description: str = Form(""),
    file: UploadFile = File(...),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    image_url = upload_image(uid, file.file, file.filename,
                             folder=f"categories/{category_id}/subcategories/{subcategory_id}/products")
    prod_doc = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products").document()
    )
    prod_doc.set({
        "name": name,
        "price": price,
        "description": description,
        "imageUrl": image_url,
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    return {"message": "Produs creat", "id": prod_doc.id, "imageUrl": image_url}

@router.get("/categories/{category_id}/subcategories/{subcategory_id}/products", response_model=List[dict])
def get_products(category_id: str, subcategory_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    prod_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products")
    )
    prods = prod_ref.order_by("createdAt", direction=firestore.Query.DESCENDING).stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in prods]

@router.put("/categories/{category_id}/subcategories/{subcategory_id}/products/{product_id}")
def update_product(
    category_id: str,
    subcategory_id: str,
    product_id: str,
    name: str = Form(...),
    price: float = Form(...),
    description: str = Form(""),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products").document(product_id)
          .update({
              "name": name,
              "price": price,
              "description": description
          })
    )
    return {"message": "Produs modificat"}

    @router.delete("/categories/{category_id}/subcategories/{subcategory_id}/products/{product_id}")
    def delete_product(category_id: str, subcategory_id: str, product_id: str, uid: str = Depends(get_current_uid)):
        db = get_firestore()  # ← Asta lipsea
        (
            db.collection("users").document(uid)
            .collection("categories").document(category_id)
            .collection("subcategories").document(subcategory_id)
            .collection("products").document(product_id)
            .delete()
        )
        return {"message": "Produs șters"}

    return {"message": "Produs șters"}