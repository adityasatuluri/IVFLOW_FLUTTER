const axios = require("axios");

// API endpoint configuration
const API_URL = "http://localhost:3000/api/ivflow";

// Function to generate random data
function generateRandomData() {
  return {
    flow_rate: Math.floor(Math.random() * 150),
    alarm_status: Math.random() < 0.5,
    monitoring_status: Math.random() < 0.5,
  };
}

// Function to send data to API
async function sendData() {
  try {
    const payload = generateRandomData();
    console.log("Sending payload:", payload);

    const response = await axios.post(API_URL, payload);
    console.log("Response:", response.data);
  } catch (error) {
    console.error("Error sending data:", error.message);
  }
}

// Send data every 5 seconds
setInterval(sendData, 5000);

// Initial send
sendData();
