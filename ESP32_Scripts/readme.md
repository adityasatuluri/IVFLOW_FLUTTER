# ESP32 Scripts for IVFLOW_FLUTTER

This repository contains Arduino scripts for ESP32, developed as part of the IVFLOW_FLUTTER project. These scripts enable communication between an ESP32 microcontroller and a Flutter-based application via Bluetooth Low Energy (BLE). The scripts support various functionalities such as toggling lights, sending alphanumeric strings, and blinking LEDs.

---

## Directory Structure

### 1. `ble_send_info`
**Description**:  
This script handles the transmission of alphanumeric strings and numeric values from a Flutter app to the ESP32. The ESP32 processes the received commands and performs corresponding actions, such as turning on/off an LED or displaying the received string.

**Features**:
- Handles alphanumeric string commands prefixed with `A:`.
- Processes numeric values prefixed with `N:`.
- Sends acknowledgment back to the Flutter app via BLE.

---

### 2. `ble_toggle_light`
**Description**:  
This script enables toggling an LED on or off through BLE commands. Commands sent from the Flutter app are received by the ESP32, which then controls the LED state accordingly.

**Features**:
- Recognizes `1` to turn on the LED and `0` to turn it off.
- Provides status feedback to the connected Flutter app.

---

### 3. `light_blink`
**Description**:  
This script allows the ESP32 to blink an LED in predefined patterns. It is ideal for testing or indicating specific events such as BLE connectivity.

**Features**:
- Supports custom blink patterns.
- Useful for visual debugging and testing BLE connections.

---

## Setup Instructions

### Prerequisites
1. **Hardware**:
   - ESP32 microcontroller.
   - LED (optional for testing light-related functionalities).

2. **Software**:
   - Arduino IDE with the ESP32 board package installed.
   - [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus) package in your Flutter project.

---

### Steps to Deploy
1. Open the Arduino IDE and load the desired script (`.ino` file).
2. Ensure the correct board and port settings are selected for your ESP32.
3. Modify the UUIDs in the script if needed to match your BLE configuration.
4. Upload the script to the ESP32.
5. Pair the ESP32 with the Flutter app and start testing.

---

## BLE Commands Overview

| Command         | Description                       | Example Usage       |
|------------------|-----------------------------------|---------------------|
| `1`             | Turn on LED                      | Toggle LED ON       |
| `0`             | Turn off LED                     | Toggle LED OFF      |
| `A:<string>`    | Send alphanumeric string to ESP32 | `A:HelloESP32`      |
| `N:<number>`    | Send numeric value to ESP32       | `N:123`             |

---

## Troubleshooting
- **No BLE Connection**:
  - Ensure the UUIDs in the script match those in the Flutter app.
  - Verify the ESP32 BLE is powered and advertising.

- **Commands Not Working**:
  - Check the serial monitor for debugging information.
  - Verify the Flutter app is sending commands in the correct format.

- **LED Not Responding**:
  - Ensure the LED is connected to the correct GPIO pin specified in the script.

---
