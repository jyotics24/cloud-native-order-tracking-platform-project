// ==========================================================
// script.js
// Cloud-Native Order Tracking Platform
// Frontend JavaScript
// ==========================================================

// IMPORTANT:
// Empty string means the frontend talks to the SAME server
// that served index.html.
//
// Local:
// http://localhost:5000
//
// Kubernetes:
// http://LoadBalancer
//
const API_BASE_URL = "";

// ----------------------------------------------------------
// Health Check
// ----------------------------------------------------------
async function checkHealth() {

    const badge = document.getElementById("health-status");

    try {

        const response = await fetch(`${API_BASE_URL}/health`);

        const data = await response.json();

        if (data.status === "healthy") {

            badge.textContent = "Backend Healthy";
            badge.className = "health-badge healthy";

        } else {

            badge.textContent = "Backend Unhealthy";
            badge.className = "health-badge unhealthy";

        }

    } catch (err) {

        badge.textContent = "Backend Offline";
        badge.className = "health-badge unhealthy";

    }

}


// ----------------------------------------------------------
// Create Order
// ----------------------------------------------------------
async function createOrder() {

    const result = document.getElementById("create-result");

    try {

        const response = await fetch(`${API_BASE_URL}/orders`, {
            method: "POST"
        });

        const order = await response.json();

        result.style.color = "green";
        result.innerHTML =
            `Order Created<br>
             ID : ${order.id}<br>
             Status : ${order.status}`;

        loadOrders();

    } catch (err) {

        result.style.color = "red";
        result.innerHTML = "Failed to create order.";

    }

}


// ----------------------------------------------------------
// Track Order
// ----------------------------------------------------------
async function trackOrder() {

    const id = document.getElementById("track-order-id").value;

    const result = document.getElementById("track-result");

    if (id === "") {

        result.style.color = "red";
        result.innerHTML = "Please enter an Order ID.";

        return;
    }

    try {

        const response =
            await fetch(`${API_BASE_URL}/orders/${id}`);

        const data = await response.json();

        if (response.status === 404) {

            result.style.color = "red";
            result.innerHTML = "Order not found.";

            return;
        }

        result.style.color = "green";

        result.innerHTML =
            `Order ID : ${data.id}<br>
             Status : ${data.status}`;

    } catch (err) {

        result.style.color = "red";
        result.innerHTML = "Backend unavailable.";

    }

}


// ----------------------------------------------------------
// Load Orders
// ----------------------------------------------------------
async function loadOrders() {

    const table =
        document.getElementById("orders-table-body");

    try {

        const response =
            await fetch(`${API_BASE_URL}/orders`);

        const data = await response.json();

        table.innerHTML = "";

        if (data.orders.length === 0) {

            table.innerHTML =
                "<tr><td colspan='2'>No Orders Found</td></tr>";

            return;
        }

        data.orders.forEach(order => {

            table.innerHTML += `
                <tr>
                    <td>${order.id}</td>
                    <td>${order.status}</td>
                </tr>
            `;

        });

    } catch (err) {

        table.innerHTML =
            "<tr><td colspan='2'>Unable to load orders.</td></tr>";

    }

}


// ----------------------------------------------------------
// Events
// ----------------------------------------------------------
document
    .getElementById("create-order-btn")
    .addEventListener("click", createOrder);

document
    .getElementById("track-order-btn")
    .addEventListener("click", trackOrder);

document
    .getElementById("refresh-orders-btn")
    .addEventListener("click", loadOrders);


// ----------------------------------------------------------
// Initial Load
// ----------------------------------------------------------
checkHealth();

loadOrders();