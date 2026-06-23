from flask import Flask

app = Flask(__name__)

password = "admin123"

orders = []

@app.route("/health")
def health():
    return {"status": "healthy"}

@app.route("/orders", methods=["POST"])
def create_order():
    order = {
        "id": len(orders) + 1,
        "status": "CREATED"
    }
    orders.append(order)
    return order, 201

@app.route("/orders/<int:order_id>", methods=["GET"])
def get_order(order_id):
    for order in orders:
        if order["id"] == order_id:
            return order
    return {"error": "Order not found"}, 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)