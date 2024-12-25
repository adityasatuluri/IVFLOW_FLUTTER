#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define LED_PIN 2  // Built-in LED pin

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
    String value = pCharacteristic->getValue().c_str();
    if (value.length() > 0) {
      Serial.print("Received value: ");
      Serial.println(value);

      if (value == "1") {
        digitalWrite(LED_PIN, HIGH);
        Serial.println("LED Turned ON");
        pCharacteristic->setValue("Success: LED ON");
      } else if (value == "0") {
        digitalWrite(LED_PIN, LOW);
        Serial.println("LED Turned OFF");
        pCharacteristic->setValue("Success: LED OFF");
      } else if (value.startsWith("A:")) {
        String alphanumeric = value.substring(2);
        Serial.println("Alphanumeric received: " + alphanumeric);
        pCharacteristic->setValue("Success: Alphanumeric received");
      } else if (value.startsWith("N:")) {
        String number = value.substring(2);
        Serial.println("Number received: " + number);
        pCharacteristic->setValue("Success: Number received");
      } else {
        pCharacteristic->setValue("Error: Unknown command");
      }

      pCharacteristic->notify();
    } else {
      Serial.println("Received empty value!");
    }
  }
};

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
  if (deviceConnected) {
    delay(100);
  }
}
