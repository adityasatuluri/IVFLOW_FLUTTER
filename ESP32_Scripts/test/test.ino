#include <WiFi.h>
#include <HTTPClient.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

String ssid = "";
String password = "";

#define LED_PIN 2
#define BLE_SERVER_NAME "ESP32_BLE"
#define SERVICE_UUID "12345678-1234-1234-1234-123456789012"
#define CHARACTERISTIC_UUID "87654321-4321-4321-4321-210987654321"

// Pin configuration
const int sensorPin = 23;  // IR sensor output pin for ESP32 (change as needed)
volatile int dropCount = 0;  // Store total number of drops detected
unsigned long lastDropTime = 0;  // Track time of last detected drop
// Constants for flow rate calculation
const float dropFactor = 20.0;  // Example: IV set with 20 drops per mL
const int calculationInterval = 6000;  // Calculate flow rate every 6 seconds (6000 ms)

// Variables for flow rate calculation
unsigned long lastCalculationTime = 0;
float flowRate = 0.0;  // Flow rate in mL/hr



const String API_URL = "https://ivflow-flutter.onrender.com/api/ivflow";

bool deviceConnected = false;
bool wifiConnected = false;

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
unsigned long lastSendTime = 0;

void IRAM_ATTR onDrop() {
  unsigned long currentTime = millis();  // Get current time

  // Ensure at least 100 ms between drops to prevent double-counting
  if (currentTime - lastDropTime >= 100) {
    dropCount++;  // Increment drop count
    lastDropTime = currentTime;  // Update last drop time
  }
}

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device connected");
    }
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Device disconnected");
      pServer->getAdvertising()->start();
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String value = pCharacteristic->getValue().c_str();
      if (value.length() > 0) {
        Serial.print("Received value: ");
        Serial.println(value);

        if (value.startsWith("SSID:")) {
          ssid = value.substring(5);
          Serial.println("SSID received: " + ssid);
          pCharacteristic->setValue("Success: SSID received");
        } 
        else if (value.startsWith("PASS:")) {
          password = value.substring(5);
          Serial.println("Password received: " + password);
          pCharacteristic->setValue("Success: Password received");
        }
        else if (value == "CONNECT") {
          Serial.println("Attempting to connect to Wi-Fi...");
          WiFi.begin(ssid.c_str(), password.c_str());
          int attempts = 0;
          while (WiFi.status() != WL_CONNECTED && attempts < 20) {
            delay(500);
            Serial.print(".");
            attempts++;
          }
          if (WiFi.status() == WL_CONNECTED) {
            wifiConnected = true;
            Serial.println("\nConnected to Wi-Fi!");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            pCharacteristic->setValue("Success: Connected to Wi-Fi");
          } else {
            wifiConnected = false;
            Serial.println("\nFailed to connect to Wi-Fi.");
            pCharacteristic->setValue("Error: Wi-Fi connection failed");
          }
        }
        pCharacteristic->notify();
      }
    }
};

void sendDataToAPI(int flowRate) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to Wi-Fi. Skipping data transmission.");
    return;
  }

  HTTPClient http;
  
  int flow_rate = flowRate;
  bool alarm_status = true;
  bool monitoring_status = false;

  String jsonPayload = "{\"flow_rate\":" + String(flow_rate) + 
                      ",\"alarm_status\":" + String(alarm_status) +
                      ",\"device_id\":\"" + BLE_SERVER_NAME + 
                      "\",\"monitoring_status\":" + String(monitoring_status) + "}";

  http.begin(API_URL); 
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.POST(jsonPayload);
  
  if (httpResponseCode > 0) {
    Serial.printf("HTTP Response code: %d\n", httpResponseCode);
  } else {
    Serial.printf("Error code: %d\n", httpResponseCode);
  }
  
  http.end();
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  pinMode(sensorPin, INPUT);
  attachInterrupt(sensorPin, onDrop, FALLING); 
  Serial.begin(115200);
  Serial.println("Starting BLE work!");

  BLEDevice::init(BLE_SERVER_NAME);
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY
  );

  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();
  pServer->getAdvertising()->start();
  Serial.println("Waiting for a client connection...");
}

void loop() {
  unsigned long currentTime = millis();

  // Calculate flow rate every calculationInterval (6 seconds)
  if (currentTime - lastCalculationTime >= calculationInterval) {
    noInterrupts();  // Disable interrupts for safe access to dropCount
    int drops = dropCount;  // Get current drop count
    dropCount = 0;  // Reset drop count for next interval
    interrupts();  // Re-enable interrupts

    // Calculate flow rate in mL/hr
    flowRate = (drops / dropFactor) * (3600.0 / (calculationInterval / 1000.0));

    // Display flow rate
    Serial.print("Flow Rate: ");
    Serial.println(flowRate);
    lastCalculationTime = currentTime;
  }

  if (deviceConnected && wifiConnected && (millis() - lastSendTime > 5000)) {
    lastSendTime = millis();
    sendDataToAPI(flowRate);
  }
}