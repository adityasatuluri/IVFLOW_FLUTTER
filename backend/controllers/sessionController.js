const { adminDb, adminFirestore } = require("./firebase_config");

exports.startSession = async (req, res) => {
  try {
    const sessionData = {
      caretaker_id: req.body.caretaker_id,
      centre_id: req.body.centre_id,
      device_id: "/device/" + req.body.device_id,
      patient_id: req.body.patient_id,
      start_time: new Date().toISOString(),
      alarms: [],
    };

    const sessionRef = await adminFirestore
      .collection("session")
      .add(sessionData);

    res.status(200).json({
      message: "Session started successfully",
      session_id: sessionRef.id,
    });
  } catch (error) {
    console.error("Start session error:", error);
    res.status(500).json({ error: "Failed to start session" });
  }
};

exports.stopSession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const deviceId = req.body.device_id || "device1";

    const rtdbRef = adminDb.ref(`${deviceId}/iv flow`);
    const snapshot = await rtdbRef.once("value");
    const flowRate = snapshot.val();

    await adminFirestore.collection("session").doc(sessionId).update({
      flow_rate: flowRate,
      end_time: new Date().toISOString(),
    });

    res.status(200).json({
      message: "Session stopped successfully",
    });
  } catch (error) {
    console.error("Stop session error:", error);
    res.status(500).json({ error: "Failed to stop session" });
  }
};


