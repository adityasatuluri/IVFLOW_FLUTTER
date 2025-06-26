const fetch = require("node-fetch");

async function fetchLatestIVFlow(deviceId) {
  try {
    const response = await fetch(
      `http://localhost:3000/api/ivflow/latest?deviceId=${deviceId}`,
      {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log(`Latest IV Flow for device ${deviceId}:`, data.latest_iv_flow);
    return data.latest_iv_flow;
  } catch (error) {
    console.error("Error fetching latest IV flow:", error.message);
    throw error;
  }
}

// Example usage: Fetch every 5 seconds for device "ESP32_BLE"
const deviceId = "ESP32_BLE";
setInterval(() => fetchLatestIVFlow(deviceId), 3000);

// Initial call
fetchLatestIVFlow(deviceId);
