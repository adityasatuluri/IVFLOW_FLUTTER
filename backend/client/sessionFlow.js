const axios = require("axios");

// API endpoint configuration
const API_URL = "https://ivflow-flutter.onrender.com/api/";

// Session data
const sessionData = {
  caretaker_id: "/users/5vaMogv7m6Nki8x7QmHtp6ps1Uc2",
  centre_id: "/centre/z46G4giBUSHDzMGsSazb",
  device_id: "ADITYA",
  patient_id: "/users/RwVQVwwORlXclvep2Vc2uU0jwO2",
  alarms: [],
};

// Function to start a session
async function startSession() {
  try {
    const response = await axios.post(
      API_URL + "sessions/startsession",
      sessionData
    );
    console.log("Session started successfully:", response.data);
    return response.data.session_id; // Return session ID for further use
  } catch (error) {
    console.error(
      "Error starting session:",
      error.response?.data || error.message
    );
    throw error;
  }
}

// Function to stop a session
async function stopSession(sessionId) {
  try {
    const response = await axios.post(
      `${API_URL}sessions/stopsession/${sessionId}`,
      {
        device_id: sessionData.device_id, // Replace with dynamic device ID if needed
      }
    );
    console.log("Session stopped successfully:", response.data);
  } catch (error) {
    console.error(
      "Error stopping session:",
      error.response?.data || error.message
    );
  }
}

// Function to send IV flow data
async function sendIVFlowData() {
  const payload = generateRandomData();
  console.log("Sending payload:", payload);

  try {
    const response = await axios.post(API_URL + "ivflow", payload);
    console.log("Data sent successfully:", response.data);
  } catch (error) {
    console.error(
      "Error sending IV flow data:",
      error.response?.data || error.message
    );
  }
}

// Helper function to generate random data
function generateRandomData() {
  return {
    flow_rate: Math.floor(Math.random() * 150),
    alarm_status: Math.random() < 0.5,
    monitoring_status: Math.random() < 0.5,
    device_id: sessionData.device_id,
  };
}

// Function to manage the session lifecycle
async function runSessionFlow() {
  try {
    // Start a session
    const sessionId = await startSession();

    // Send IV flow data at intervals
    const intervalId = setInterval(sendIVFlowData, 3000); // Send data every 3 seconds

    // Stop the session after 10 seconds
    setTimeout(async () => {
      clearInterval(intervalId); // Stop sending data
      await stopSession(sessionId); // Stop the session
    }, 20000); // 10 seconds
  } catch (error) {
    console.error("Session flow error:", error.message);
  }
}

// Uncomment the line below to run the session flow
runSessionFlow();
