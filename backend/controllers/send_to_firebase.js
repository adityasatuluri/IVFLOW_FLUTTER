const { ref, set } = require("firebase/database");
const database = require("./firebase_config");

const updateIVFlowData = async (deviceId, data) => {
  try {
    const { flow_rate, alarm_status, monitoring_status } = data;

    await set(ref(database, `${deviceId}/iv flow`), flow_rate);
    await set(ref(database, `${deviceId}/alarm status`), alarm_status);
    await set(
      ref(database, `${deviceId}/monitoring status`),
      monitoring_status
    );

    return true;
  } catch (error) {
    console.error("Firebase update error:", error);
    throw error;
  }
};

module.exports = {
  updateIVFlowData,
};
