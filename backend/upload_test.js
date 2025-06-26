function sendRandomData() {
  // Generate random values
  const flow_rate = Math.floor(Math.random() * 150); // 0 to 149
  const alarm_status = Math.floor(Math.random() * 2); // 0 or 1
  const monitoring_status = Math.floor(Math.random() * 2); // 0 or 1
  const device_id = "ESP32_BLE"; // Simulated device ID

  // Construct JSON payload
  const jsonPayload = {
    flow_rate: flow_rate,
    alarm_status: alarm_status,
    device_id: device_id,
    monitoring_status: monitoring_status,
  };

  // Send data to API
  fetch("http://localhost:3000/api/ivflow", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(jsonPayload),
  })
    .then((response) => {
      console.log("Response status:", response.status);
      return response.text();
    })
    .then((data) => {
      console.log("Response data:", data);
    })
    .catch((error) => {
      console.error("Error sending data:", error);
    });
}

// Send data every 5 seconds to mimic ESP32 loop
setInterval(sendRandomData, 3000);
