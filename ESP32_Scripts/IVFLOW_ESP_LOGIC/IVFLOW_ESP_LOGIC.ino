#include <WiFi.h>
#include <HTTPClient.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Wi-Fi credentials
String ssid = "";
String password = "";

#define LED_PIN 2
#define BLE_SERVER_NAME "ESP32_BLE"
#define SERVICE_UUID "12345678-1234-1234-1234-123456789012"
#define CHARACTERISTIC_UUID "87654321-4321-4321-4321-210987654321"

// Fixed API URL
const String API_URL = "https://ivflow-flutter.onrender.com/api/ivflow";

bool deviceConnected = false;
bool wifiConnected = false;

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
unsigned long lastSendTime = 0;

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

void sendDataToAPI() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to Wi-Fi. Skipping data transmission.");
    return;
  }

  HTTPClient http;
  
  // Generate random values
  int flow_rate = random(0, 150);
  bool alarm_status = random(0, 2);
  bool monitoring_status = random(0, 2);

  // Prepare JSON payload
  String jsonPayload = "{\"flow_rate\":" + String(flow_rate) + 
                      ",\"alarm_status\":" + String(alarm_status) +
                      ",\"device_id\":\"" + BLE_SERVER_NAME + 
                      "\",\"monitoring_status\":" + String(monitoring_status) + "}";

  http.begin(API_URL);  // Using the fixed API URL
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
  if (deviceConnected && wifiConnected && (millis() - lastSendTime > 5000)) {
    lastSendTime = millis();
    sendDataToAPI();
  }
}
