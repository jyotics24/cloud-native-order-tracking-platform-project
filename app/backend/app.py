# ==========================================================
# app.py
# Cloud-Native Order Tracking Platform
#
# Flask Backend
# - Serves the frontend
# - Provides REST API
# - Used by Jenkins/EKS deployment
# ==========================================================

import os
from flask import Flask, render_template

app = Flask(__name__)

# ----------------------------------------------------------
# Demo in-memory database
# ----------------------------------------------------------
orders = []


# ----------------------------------------------------------
# Home Page
# ----------------------------------------------------------
@app.route("/")
def home():
    return render_template("index.html")


# ----------------------------------------------------------
# Health Check
# ----------------------------------------------------------
@app.route("/health", methods=["GET"])
def health():
    return {
        "status": "healthy"
    }


# ----------------------------------------------------------
# List Orders
# ----------------------------------------------------------
@app.route("/orders", methods=["GET"])
def list_orders():
    return {
        "orders": orders
    }


# ----------------------------------------------------------
# Create Order
# ----------------------------------------------------------
@app.route("/orders", methods=["POST"])
def create_order():

    order = {
        "id": len(orders) + 1,
        "status": "CREATED"
    }

    orders.append(order)

    return order, 201


# ----------------------------------------------------------
# Get Single Order
# ----------------------------------------------------------
@app.route("/orders/<int:order_id>", methods=["GET"])
def get_order(order_id):

    for order in orders:
        if order["id"] == order_id:
            return order

    return {
        "error": "Order not found"
    }, 404


# ----------------------------------------------------------
# Local Development
# ----------------------------------------------------------
if __name__ == "__main__":

    host = os.getenv("FLASK_HOST", "127.0.0.1")
    port = int(os.getenv("PORT", "5000"))

    app.run(
        host=host,
        port=port,
        debug=False
    )