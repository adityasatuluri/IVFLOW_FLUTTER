#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Define the GPIO pin for the built-in LED
#define LED_PIN 2  // On most ESP32 boards, the built-in LED is on GPIO 2

#define BLE_SERVER_NAME "ESP32_BLE"
#define SERVICE_UUID "12345678-1234-1234-1234-123456789012"
#define CHARACTERISTIC_UUID "87654321-4321-4321-4321-210987654321"

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
bool deviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
  }

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
    pServer->getAdvertising()->start();
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();  // Convert to String
    if (value.length() > 0) {
      Serial.print("Received value: ");
      Serial.println(value);

      // Control the LED based on the received value
      if (value == "1") {
        digitalWrite(LED_PIN, HIGH);
        Serial.println("LED Turned ON");
      } else if (value == "0") {
        digitalWrite(LED_PIN, LOW);
        Serial.println("LED Turned OFF");
      }
    } else {
      Serial.println("Received empty value!");
    }
  }
};

void setup() {
  pinMode(LED_PIN, OUTPUT);  // Configure the LED pin as output
  digitalWrite(LED_PIN, LOW);  // Ensure the LED is off initially

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
  if (deviceConnected) {
    pCharacteristic->setValue("Hello from ESP32!");
    pCharacteristic->notify();
    Serial.println("Notification sent: Hello from ESP32!");
    delay(1000);
  }
  delay(100);
}
