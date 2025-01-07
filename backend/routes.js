const express = require("express");
const router = express.Router();
const { updateIVFlowData } = require("./controllers/send_to_firebase");

// Test route
router.get("/test", (req, res) => {
  res.status(200).json({
    status: "success",
    message: "API is working",
  });
});

// Post to Firebase
router.post("/ivflow", async (req, res) => {
  try {
    const deviceId = req.query.deviceId || "device2";
    const data = {
      flow_rate: req.body.flow_rate,
      alarm_status: req.body.alarm_status,
      monitoring_status: req.body.monitoring_status,
    };

    await updateIVFlowData(deviceId, data);
    res.status(200).json({ message: "Data updated successfully" });
  } catch (error) {
    console.error("Route error:", error);
    res.status(500).json({ error: "Failed to update data" });
  }
});

module.exports = router;
