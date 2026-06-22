# test_app.py
# Unit tests for the Flask order tracking backend.
# Run with: pytest test_app.py -v
#
# These tests use Flask's built-in test client, which simulates
# HTTP requests without needing a real running server or network call.

import pytest
from app import app


@pytest.fixture
def client():
    # Flask's test client lets us send fake requests to our app
    # in-memory, which is fast and doesn't need port 5000 open.
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


def test_health_endpoint(client):
    # The /health endpoint should always return 200 and a healthy status.
    # This is the most basic "is the app alive" check.
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_create_order_returns_201(client):
    # Creating an order should return HTTP 201 (Created),
    # along with an id and a status of "CREATED".
    response = client.post("/orders")
    assert response.status_code == 201
    data = response.get_json()
    assert data["status"] == "CREATED"
    assert "id" in data


def test_create_order_increments_id(client):
    # Each new order should get a unique, incrementing id.
    # We create two orders and check the second id is one more than the first.
    first = client.post("/orders").get_json()
    second = client.post("/orders").get_json()
    assert second["id"] == first["id"] + 1


def test_get_existing_order(client):
    # After creating an order, we should be able to fetch it by its id
    # and get back the same data.
    created = client.post("/orders").get_json()
    order_id = created["id"]

    response = client.get(f"/orders/{order_id}")
    assert response.status_code == 200
    data = response.get_json()
    assert data["id"] == order_id
    assert data["status"] == "CREATED"


def test_get_nonexistent_order_returns_404(client):
    # Requesting an order id that was never created should return
    # a 404 with a clear error message, not crash the app.
    response = client.get("/orders/99999")
    assert response.status_code == 404
    data = response.get_json()
    assert data["error"] == "Order not found"
