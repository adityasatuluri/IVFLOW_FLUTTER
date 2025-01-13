const express = require("express");
const router = express.Router();
const { updateIVFlowData } = require("./controllers/send_to_firebase");
const { adminDb, adminFirestore } = require("./controllers/firebase_config");

// Start session route
router.post("/startsession", async (req, res) => {
  try {
    const sessionData = {
      caretaker_id: req.body.caretaker_id,
      centre_id: req.body.centre_id,
      device_id: req.body.device_id,
      patient_id: req.body.patient_id,
      start_time: new Date().toISOString(),
      alarms: [],
    };

    // Add session to Firestore
    const sessionRef = await adminFirestore
      .collection("session")
      .add(sessionData);

    res.status(200).json({
      message: "Session started successfully",
      session_id: sessionRef.id,
    });
  } catch (error) {
    console.error("Route error:", error);
    res.status(500).json({ error: "Failed to start session" });
  }
});

// Stop session route
router.post("/stopsession/:sessionId", async (req, res) => {
  try {
    const { sessionId } = req.params;
    const deviceId = req.body.device_id || "device1";

    // Get flow rate from Realtime Database
    const rtdbRef = adminDb.ref(`${deviceId}/iv flow`);
    const snapshot = await rtdbRef.once("value");
    const flowRate = snapshot.val();

    // Update Firestore document
    await adminFirestore.collection("session").doc(sessionId).update({
      flow_rate: flowRate,
      end_time: new Date().toISOString(),
    });

    res.status(200).json({
      message: "Session stopped successfully",
    });
  } catch (error) {
    console.error("Route error:", error);
    res.status(500).json({ error: "Failed to stop session" });
  }
});

// Test route
router.get("/test", (req, res) => {
  res.status(200).json({
    status: "success",
    message: "API is working",
  });
});

// Update IV flow data route
router.post("/ivflow", async (req, res) => {
  try {
    const deviceId = req.body.device_id || req.query.deviceId || "device1";
    const { flow_rate, alarm_status, monitoring_status } = req.body;

    if (
      flow_rate === undefined ||
      alarm_status === undefined ||
      monitoring_status === undefined
    ) {
      return res.status(400).json({ error: "Missing required data" });
    }

    // Fetch current `iv flow` array from Realtime Database
    const ivFlowRef = adminDb.ref(`${deviceId}/iv flow`);
    const snapshot = await ivFlowRef.once("value");
    let currentIVFlow = snapshot.val() || [];

    if (!Array.isArray(currentIVFlow)) {
      currentIVFlow = [currentIVFlow]; // Ensure it's an array
    }

    // Prepend the new flow rate to the array
    const updatedIVFlow = [flow_rate, ...currentIVFlow];

    // Update Realtime Database
    await adminDb.ref(`${deviceId}`).update({
      "iv flow": updatedIVFlow,
      "alarm status": alarm_status,
      "monitoring status": monitoring_status,
    });

    // Update Firestore
    const deviceRef = adminFirestore.collection("devices").doc(deviceId);
    await deviceRef.set(
      {
        iv_flow: updatedIVFlow,
        alarm_status,
        monitoring_status,
      },
      { merge: true }
    );

    res.status(200).json({ message: "Data updated successfully" });
  } catch (error) {
    console.error("Route error:", error);
    res
      .status(500)
      .json({ error: "Failed to update data", details: error.message });
  }
});

module.exports = router;
