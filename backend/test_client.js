const axios = require("axios");

// API endpoint configuration
const API_URL = "http://localhost:3000/api/ivflow";

// Session data (for now)
const sessionData = {
  caretaker_id: "/users/5vaMogv7m6Nki8x7QmHtp6ps1Uc2",
  centre_id: "/centre/z46G4giBUSHDzMGsSazb",
  device_id: "ESP32_BLE",
  patient_id: "/users/RwVQVwwORlXclvep2Vc2uU0jwO2",
  start_time: new Date().toISOString(),
  alarms: [],
  flow_rate: [],
  end_time: null,
};

// Function to send data to the API
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

// Helper function to generate random data
function generateRandomData() {
  return {
    flow_rate: Math.floor(Math.random() * 150),
    alarm_status: Math.random() < 0.5,
    monitoring_status: Math.random() < 0.5,
    device_id: "ESP_32",
  };
}

// Function to start a session using the API route
async function startSession() {
  try {
    const response = await axios.post(
      "http://localhost:3000/api/startsession",
      sessionData
    );
    console.log("Session started:", response.data);
    return response.data.session_id; // Return session ID to use later
  } catch (error) {
    console.error("Error starting session:", error.message);
  }
}

// Function to stop the session using the API route
async function stopSession(sessionId) {
  try {
    const response = await axios.post(
      `http://localhost:3000/api/stopsession/${sessionId}`,
      {
        device_id: "ESP32_BLE", // Replace with dynamic device ID if needed
      }
    );
    console.log("Session stopped:", response.data);
  } catch (error) {
    console.error("Error stopping session:", error.message);
  }
}

// Function to manage the session flow
const runSessionFlow = async () => {
  try {
    // Start the session
    const sessionId = await startSession();

    // Simulate a delay before stopping the session
    setTimeout(async () => {
      await stopSession(sessionId);
    }, 5000); // 5 seconds delay
  } catch (error) {
    console.error("Session flow error:", error);
  }
};

// Uncomment to send data at regular intervals
// setInterval(sendData, 1500); // Send data every 1.5 seconds
sendData();

// Run the session flow
runSessionFlow();
