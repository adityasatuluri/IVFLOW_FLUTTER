const axios = require("axios");
const { adminDb, admin } = require("./controllers/firebase_config"); // Importing configured Firebase instances

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

// Helper function to get the current time in IST
function getCurrentTime() {
  return new Date().toLocaleString("en-US", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    second: "numeric",
    timeZoneName: "short",
  });
}

// Function to create a new session
const createSession = async () => {
  const startTime = getCurrentTime();

  const sessionData = {
    alarms: [],
    caretaker_id: "/users/5vaMogv7m6Nki8x7QmHtp6ps1Uc2",
    centre_id: "/centre/z46G4giBUSHDzMGsSazb",
    device_id: "/device/esp-001",
    patient_id: "/users/RwVQVwwORlXclvep2Vc2uU0jwO2",
    start_time: startTime,
    flow_rate: [],
    end_time: null,
  };

  try {
    const docRef = await admin
      .firestore()
      .collection("session")
      .add(sessionData);
    console.log("Session created with ID:", docRef.id);
    return docRef.id;
  } catch (error) {
    console.error("Error creating session:", error);
    throw error;
  }
};

// Function to end an existing session
const endSession = async (sessionId) => {
  const endTime = getCurrentTime();

  try {
    // Retrieve flow rate from Realtime Database
    const deviceId = "device1"; // Replace with dynamic device ID if required
    const rtdbRef = adminDb.ref(`${deviceId}/iv flow`);
    const snapshot = await rtdbRef.once("value");
    const flowRate = snapshot.val();

    // Update Firestore session with end time and flow rate
    await admin
      .firestore()
      .collection("session")
      .doc(sessionId)
      .update({
        end_time: endTime,
        flow_rate: flowRate || [], // Ensure flow rate is not null
      });

    console.log("Session ended successfully");
  } catch (error) {
    console.error("Error ending session:", error);
    throw error;
  }
};

// Function to manage the session flow
const runSessionFlow = async () => {
  try {
    // Create a session
    const sessionId = await createSession();

    // Simulate a delay before ending the session
    setTimeout(async () => {
      await endSession(sessionId);
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
