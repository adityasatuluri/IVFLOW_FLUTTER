const { adminDb, adminFirestore } = require("./firebase_config");

exports.updateIVFlowData = async (req, res) => {
  try {
    const deviceId = req.body.device_id;
    const { flow_rate, alarm_status, monitoring_status } = req.body;

    if (
      flow_rate === undefined ||
      alarm_status === undefined ||
      monitoring_status === undefined
    ) {
      return res.status(400).json({ error: "Missing required data" });
    }

    const ivFlowRef = adminDb.ref(`${deviceId}/iv flow`);
    const snapshot = await ivFlowRef.once("value");
    let currentIVFlow = snapshot.val() || [];

    if (!Array.isArray(currentIVFlow)) {
      currentIVFlow = [currentIVFlow];
    }

    const updatedIVFlow = [flow_rate, ...currentIVFlow];

    await adminDb.ref(`${deviceId}`).update({
      "iv flow": updatedIVFlow,
      "alarm status": alarm_status,
      "monitoring status": monitoring_status,
    });

    // const deviceRef = adminFirestore.collection("devices").doc(deviceId);
    // await deviceRef.set(
    //   {
    //     iv_flow: updatedIVFlow,
    //     alarm_status,
    //     monitoring_status,
    //   },
    //   { merge: true }
    // );

    res.status(200).json({ message: "Data updated successfully" });
  } catch (error) {
    console.error("Update IV flow data error:", error);
    res
      .status(500)
      .json({ error: "Failed to update data", details: error.message });
  }
};
