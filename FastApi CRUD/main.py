from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, List, Optional

app = FastAPI()

class Product(BaseModel):
    name: str
    price: float

class Menu(BaseModel):
    name: str
    products: List[Product] = []

class Category(BaseModel):
    name: str
    menus: Dict[str, Menu] = {}

categories: Dict[str, Category] = {}

# CATEGORIE CRUD
@app.post("/categories")
def create_category(category: Category):
    if category.name in categories:
        raise HTTPException(status_code=400, detail="Category already exists")
    categories[category.name] = category
    return category

@app.get("/categories")
def read_categories():
    return list(categories.values())

@app.put("/categories/{category_name}")
def update_category(category_name: str, category: Category):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    # Menține meniurile vechi dacă nu se trimit noi meniuri
    if not category.menus:
        category.menus = categories[category_name].menus
    categories[category_name] = category
    return category

@app.delete("/categories/{category_name}")
def delete_category(category_name: str):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    del categories[category_name]
    return {"detail": "Category deleted"}

# MENIU CRUD
@app.post("/categories/{category_name}/menus")
def add_menu(category_name: str, menu: Menu):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu.name in categories[category_name].menus:
        raise HTTPException(status_code=400, detail="Menu already exists in this category")
    categories[category_name].menus[menu.name] = menu
    return menu

@app.get("/categories/{category_name}/menus")
def read_menus(category_name: str):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    return list(categories[category_name].menus.values())

@app.put("/categories/{category_name}/menus/{menu_name}")
def update_menu(category_name: str, menu_name: str, new_menu: Menu):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    # Menține produsele vechi dacă nu se trimit altele
    if not new_menu.products:
        new_menu.products = categories[category_name].menus[menu_name].products
    categories[category_name].menus[menu_name] = new_menu
    return new_menu

@app.delete("/categories/{category_name}/menus/{menu_name}")
def delete_menu(category_name: str, menu_name: str):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    del categories[category_name].menus[menu_name]
    return {"detail": "Menu deleted from category"}

# PRODUS CRUD
@app.post("/categories/{category_name}/menus/{menu_name}/products")
def add_product(category_name: str, menu_name: str, product: Product):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    menu = categories[category_name].menus[menu_name]
    if any(p.name == product.name for p in menu.products):
        raise HTTPException(status_code=400, detail="Product already exists in this menu")
    menu.products.append(product)
    return product

@app.get("/categories/{category_name}/menus/{menu_name}/products")
def get_products(category_name: str, menu_name: str):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    return categories[category_name].menus[menu_name].products

@app.put("/categories/{category_name}/menus/{menu_name}/products/{product_name}")
def update_product(category_name: str, menu_name: str, product_name: str, new_product: Product):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    menu = categories[category_name].menus[menu_name]
    for idx, product in enumerate(menu.products):
        if product.name == product_name:
            menu.products[idx] = new_product
            return new_product
    raise HTTPException(status_code=404, detail="Product not found in this menu")

@app.delete("/categories/{category_name}/menus/{menu_name}/products/{product_name}")
def delete_product(category_name: str, menu_name: str, product_name: str):
    if category_name not in categories:
        raise HTTPException(status_code=404, detail="Category not found")
    if menu_name not in categories[category_name].menus:
        raise HTTPException(status_code=404, detail="Menu not found in this category")
    menu = categories[category_name].menus[menu_name]
    for idx, product in enumerate(menu.products):
        if product.name == product_name:
            del menu.products[idx]
            return {"detail": "Product deleted from menu"}
    raise HTTPException(status_code=404, detail="Product not found in this menu")
