from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, Header
from firebase_admin import auth, storage, firestore
from typing import List
from uuid import uuid4
from urllib.parse import unquote

router = APIRouter()

def delete_storage_file_by_url(public_url: str) -> None:
    """
    Șterge blob-ul din Firebase Storage pe baza URL-ului public generat
    de upload_image (v0/b/<bucket>/o/<path>?alt=media&token=...).

    Funcționează pentru domeniile *.googleapis.com și *.firebasestorage.app.
    """
    try:
        if not public_url:
            return

        # extrage bucket name (între "/b/" și următorul "/o/")
        # și calea encodată (după "/o/" până la "?")
        b_idx = public_url.find("/b/")
        o_idx = public_url.find("/o/")
        if b_idx == -1 or o_idx == -1:
            return  # nu e un URL așa cum îl generăm noi

        # bucket name
        b_start = b_idx + 3
        b_end = public_url.find("/", b_start)
        bucket_name = public_url[b_start:b_end]

        # encoded path
        o_start = o_idx + 3
        q_idx = public_url.find("?", o_start)
        encoded_path = public_url[o_start: q_idx if q_idx != -1 else len(public_url)]
        path = unquote(encoded_path)  # "users/uid/branding/xxxx.jpg"

        # ștergere
        bucket = storage.bucket(bucket_name)
        blob = bucket.blob(path)
        if blob.exists():
            blob.delete()
    except Exception:
        # nu blocăm fluxul dacă ștergerea eșuează
        pass
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


@router.post("/initialize")
def initialize_user(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    user_ref = db.collection("users").document(uid)
    existing = user_ref.get().to_dict()
    if existing and existing.get("initialized") == True:
        return {"message": "Deja inițializat"}

    # Categorie inițială
    category_ref = user_ref.collection("categories").document()
    category_ref.set({
        "name": "Food",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True,
        "order": 0  # ✅
    })

    # Subcategorie inițială
    subcategory_ref = category_ref.collection("subcategories").document()
    subcategory_ref.set({
        "name": "Starter rece",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True,
        "order": 0  # ✅
    })

    # Produs inițial
    subcategory_ref.collection("products").document().set({
        "name": "Crochete",
        "price": 0.0,
        "description": "Produs implicit",
        "weight": "",
        "allergens": "",
        "imageUrl": "",
        "visible": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "protected": True,
        "order": 0  # ✅
    })
    # 🆕 Branding implicit
    user_ref.set({
        "initialized": True,
        "restaurant_name": "Meniu",
        "headerImageUrl": ""
    }, merge=True)

    user_ref.set({"initialized": True}, merge=True)
    return {"message": "User initialized cu structura default"}

# ------------------ NUMELE RESTAURANTULUI SI POZA BACKGROUND ------------------

@router.get("/branding")
def get_branding(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    user_doc = db.collection("users").document(uid).get()
    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User inexistent")
    data = user_doc.to_dict() or {}
    return {
        "restaurant_name": data.get("restaurant_name", "Meniu"),
        "header_image_url": data.get("headerImageUrl", "")
    }

@router.put("/branding")
def update_branding(
    name: str = Form(None),
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    user_ref = db.collection("users").document(uid)

    # Citește URL-ul vechi pentru a-l șterge după update
    old_doc = user_ref.get()
    old_url = ""
    if old_doc.exists:
        d = old_doc.to_dict() or {}
        old_url = d.get("headerImageUrl", "")

    update_data = {}

    if name is not None:
        update_data["restaurant_name"] = name

    if file is not None:
        # încarcă noua imagine
        image_url = upload_image(uid, file.file, file.filename, folder="branding")
        update_data["headerImageUrl"] = image_url  # în Firestore păstrăm camelCase

    if not update_data:
        raise HTTPException(status_code=400, detail="Nimic de actualizat")

    # 1) salvează în Firestore
    user_ref.set(update_data, merge=True)

    # 2) dacă am încărcat o imagine nouă și exista una veche, șterge-o din Storage
    if file is not None and old_url:
        delete_storage_file_by_url(old_url)

    # răspuns uniform (snake_case pentru frontend)
    resp = {"message": "Branding actualizat"}
    if "restaurant_name" in update_data:
        resp["restaurant_name"] = update_data["restaurant_name"]
    if "headerImageUrl" in update_data:
        resp["header_image_url"] = update_data["headerImageUrl"]

    return resp



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

    # 🔢 Calculează poziția următoare
    cats_ref = db.collection("users").document(uid).collection("categories")
    existing = list(cats_ref.stream())
    next_order = len(existing)

    # ✅ Salvează categoria cu câmpul `order`
    cat_doc = cats_ref.document()
    cat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "visible": visible,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "order": next_order,
        "protected": False  # 🆕
    })

    return {"message": "Categorie creată", "id": cat_doc.id, "image_url": image_url}

@router.get("/categories", response_model=List[dict])
def get_categories(uid: str = Depends(get_current_uid)):
    db = get_firestore()
    cats_ref = db.collection("users").document(uid).collection("categories")
    cats = cats_ref.order_by("order").stream()
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
    order: int = Form(None),  # 🆕 adăugat
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    update_data = {
        "name": name,
        "visible": visible,
    }

    if order is not None:  # 🆕 doar dacă e furnizat
        update_data["order"] = order

    if file:
        image_url = upload_image(uid, file.file, file.filename, folder="categories")
        update_data["imageUrl"] = image_url

    db.collection("users").document(uid).collection("categories").document(category_id).update(update_data)
    return {"message": "Categorie modificată"}

@router.delete("/categories/{category_id}")
def delete_category(category_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()
    doc = db.collection("users").document(uid).collection("categories").document(category_id).get()
    if doc.exists and doc.to_dict().get("protected"):
        raise HTTPException(status_code=403, detail="Această categorie nu poate fi ștearsă")
    db.collection("users").document(uid).collection("categories").document(category_id).delete()
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
    image_url = upload_image(uid, file.file, file.filename, folder=f"categories/{category_id}/subcategories")

    # 🔢 Calculează ordinea subcategoriilor existente
    subcats_ref = (
        db.collection("users").document(uid)
        .collection("categories").document(category_id)
        .collection("subcategories")
    )
    existing = list(subcats_ref.stream())
    next_order = len(existing)

    subcat_doc = subcats_ref.document()
    subcat_doc.set({
        "name": name,
        "imageUrl": image_url,
        "visible": visible,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "order": next_order,
        "protected": False  # 🆕
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
        "protected": True,
        "order": 0
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
    subs = subs_ref.order_by("order").stream()
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
    order: int = Form(None),  # 🆕 suport pentru ordine
    file: UploadFile = File(None),
    uid: str = Depends(get_current_uid)
):
    db = get_firestore()
    update_data = {
        "name": name,
        "visible": visible
    }

    if order is not None:
        update_data["order"] = order

    if file:
        image_url = upload_image(uid, file.file, file.filename, folder=f"categories/{category_id}/subcategories")
        update_data["imageUrl"] = image_url

    subcat_ref = (
        db.collection("users").document(uid)
        .collection("categories").document(category_id)
        .collection("subcategories").document(subcategory_id)
    )

    if not subcat_ref.get().exists:
        raise HTTPException(status_code=404, detail="Subcategoria nu există")

    subcat_ref.update(update_data)
    return {"message": "Subcategorie modificată"}


@router.delete("/categories/{category_id}/subcategories/{subcategory_id}")
def delete_subcategory(category_id: str, subcategory_id: str, uid: str = Depends(get_current_uid)):
    db = get_firestore()

    subcat_ref = (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
    )

    doc = subcat_ref.get()
    if doc.exists and doc.to_dict().get("protected"):
        raise HTTPException(status_code=403, detail="Această subcategorie nu poate fi ștearsă")

    # 🔁 Șterge toate produsele din subcategorie, în batch-uri
    products_ref = subcat_ref.collection("products")
    while True:
        to_delete = list(products_ref.limit(200).stream())
        if not to_delete:
            break
        batch = db.batch()
        for p in to_delete:
            batch.delete(p.reference)
        batch.commit()

    # 🗑️ După ce nu mai are subcolecții, șterge documentul subcategoriei
    subcat_ref.delete()

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

    # 🔢 Calculează ordinea
    prod_ref = (
        db.collection("users").document(uid)
        .collection("categories").document(category_id)
        .collection("subcategories").document(subcategory_id)
        .collection("products")
    )
    existing = list(prod_ref.stream())
    next_order = len(existing)

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
        "order": next_order,
        "protected": False  # 🆕
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
    products = prod_ref.order_by("order").stream()
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
    order: int = Form(None),  # 🆕 suport pentru ordine
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

    if order is not None:
        update_data["order"] = order

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
    (
        db.collection("users").document(uid)
          .collection("categories").document(category_id)
          .collection("subcategories").document(subcategory_id)
          .collection("products").document(product_id)
          .delete()
    )
    return {"message": "Produs șters"}

@router.get("/public-menu/{uid}")
def get_public_menu(uid: str):
    db = get_firestore()

    # ── Branding (nume + poză antet) ────────────────────────────────────────────
    user_doc = db.collection("users").document(uid).get()
    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="Restaurantul nu există")

    user_data = user_doc.to_dict() or {}
    restaurant_name = user_data.get("restaurant_name", "Meniu")
    header_image_url = user_data.get("headerImageUrl", "")

    # ── Conținut meniu (categorii / subcategorii / produse) ────────────────────
    categories_ref = db.collection("users").document(uid).collection("categories")
    categories = categories_ref.order_by("order").stream()

    result = []
    for cat_doc in categories:
        cat = cat_doc.to_dict()
        if not cat.get("visible", True):
            continue

        cat_data = {
            "id": cat_doc.id,
            "name": cat.get("name"),
            "image_url": cat.get("imageUrl"),
            "subcategories": []
        }

        subcat_ref = categories_ref.document(cat_doc.id).collection("subcategories")
        subcats = subcat_ref.order_by("order").stream()

        for subcat_doc in subcats:
            subcat = subcat_doc.to_dict()
            if not subcat.get("visible", True):
                continue

            subcat_data = {
                "id": subcat_doc.id,
                "name": subcat.get("name"),
                "image_url": subcat.get("imageUrl"),
                "products": []
            }

            prod_ref = subcat_ref.document(subcat_doc.id).collection("products")
            prods = prod_ref.order_by("order").stream()

            for prod_doc in prods:
                prod = prod_doc.to_dict()
                if not prod.get("visible", True):
                    continue

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

    # ── Răspuns cu branding inclus ─────────────────────────────────────────────
    return {
        "restaurant_name": restaurant_name,
        "header_image_url": header_image_url,   # ← branding
        "categories": result
    }


