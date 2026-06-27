# app.py
# Flask backend for the order tracking platform.
# Provides a health check and basic order create/list/get endpoints.

from flask import Flask

app = Flask(__name__)

# In-memory order storage (resets on restart - fine for this demo project)
orders = []


@app.route("/health")
def health():
    # Used by monitoring/load balancers to confirm the app is alive.
    return {"status": "healthy"}


@app.route("/orders", methods=["GET"])
def list_orders():
    # Returns every order created so far, newest last.
    return {"orders": orders}


@app.route("/orders", methods=["POST"])
def create_order():
    # Creates a new order with an auto-incrementing id.
    order = {
        "id": len(orders) + 1,
        "status": "CREATED"
    }
    orders.append(order)
    return order, 201


@app.route("/orders/<int:order_id>", methods=["GET"])
def get_order(order_id):
    # Looks up a single order by its id.
    for order in orders:
        if order["id"] == order_id:
            return order
    return {"error": "Order not found"}, 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
