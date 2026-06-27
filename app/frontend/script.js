// script.js
// Connects the frontend UI to the Flask backend API.
// All requests go to API_BASE_URL - change this if the backend
// is running somewhere other than localhost:5000.

const API_BASE_URL = "http://localhost:5000";

// ---------------------------------------------------
// Health check - runs once on page load, updates the
// badge in the header to show if the backend is reachable.
// ---------------------------------------------------
async function checkHealth() {
    const badge = document.getElementById("health-status");
    try {
        const response = await fetch(`${API_BASE_URL}/health`);
        const data = await response.json();
        if (data.status === "healthy") {
            badge.textContent = "Backend: Healthy";
            badge.className = "health-badge healthy";
        } else {
            badge.textContent = "Backend: Unhealthy";
            badge.className = "health-badge unhealthy";
        }
    } catch (error) {
        badge.textContent = "Backend: Unreachable";
        badge.className = "health-badge unhealthy";
    }
}

// ---------------------------------------------------
// Create a new order via POST /orders
// ---------------------------------------------------
async function createOrder() {
    const resultEl = document.getElementById("create-result");
    try {
        const response = await fetch(`${API_BASE_URL}/orders`, {
            method: "POST"
        });
        const data = await response.json();
        resultEl.textContent = `Order created! ID: ${data.id}, Status: ${data.status}`;
        resultEl.style.color = "green";
        loadOrders(); // refresh the table to show the new order
    } catch (error) {
        resultEl.textContent = "Failed to create order. Is the backend running?";
        resultEl.style.color = "red";
    }
}

// ---------------------------------------------------
// Track a single order via GET /orders/<id>
// ---------------------------------------------------
async function trackOrder() {
    const idInput = document.getElementById("track-order-id");
    const resultEl = document.getElementById("track-result");
    const orderId = idInput.value;

    if (!orderId) {
        resultEl.textContent = "Please enter an order ID.";
        resultEl.style.color = "red";
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}`);
        const data = await response.json();

        if (response.status === 404) {
            resultEl.textContent = `Order ${orderId} not found.`;
            resultEl.style.color = "red";
        } else {
            resultEl.textContent = `Order ${data.id}: ${data.status}`;
            resultEl.style.color = "green";
        }
    } catch (error) {
        resultEl.textContent = "Failed to reach backend.";
        resultEl.style.color = "red";
    }
}

// ---------------------------------------------------
// Load all orders via GET /orders, render as table rows
// ---------------------------------------------------
async function loadOrders() {
    const tableBody = document.getElementById("orders-table-body");
    try {
        const response = await fetch(`${API_BASE_URL}/orders`);
        const data = await response.json();

        tableBody.innerHTML = ""; // clear existing rows

        if (data.orders.length === 0) {
            tableBody.innerHTML = "<tr><td colspan='2'>No orders yet.</td></tr>";
            return;
        }

        data.orders.forEach(order => {
            const row = document.createElement("tr");
            row.innerHTML = `<td>${order.id}</td><td>${order.status}</td>`;
            tableBody.appendChild(row);
        });
    } catch (error) {
        tableBody.innerHTML = "<tr><td colspan='2'>Failed to load orders.</td></tr>";
    }
}

// ---------------------------------------------------
// Wire up button clicks and run initial load on page open
// ---------------------------------------------------
document.getElementById("create-order-btn").addEventListener("click", createOrder);
document.getElementById("track-order-btn").addEventListener("click", trackOrder);
document.getElementById("refresh-orders-btn").addEventListener("click", loadOrders);

checkHealth();
loadOrders();
