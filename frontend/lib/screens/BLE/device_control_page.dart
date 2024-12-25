import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class DeviceControlPage extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceControlPage({super.key, required this.device});

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  BluetoothCharacteristic? writeCharacteristic;
  StreamSubscription? bleSubscription;

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  /// Discover the BLE services and characteristics
  void discoverServices() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == "12345678-1234-1234-1234-123456789012") {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() ==
                "87654321-4321-4321-4321-210987654321") {
              setState(() {
                writeCharacteristic = characteristic;
              });
              subscribeToNotifications(characteristic);
            }
          }
        }
      }
    } catch (e) {
      print("Error discovering services: $e");
    }
  }

  /// Subscribe to notifications from the characteristic
  void subscribeToNotifications(BluetoothCharacteristic characteristic) {
    bleSubscription = characteristic.value.listen((value) {
      final response = String.fromCharCodes(value);
      print("Received response: $response");

      if (mounted) {
        setState(() {
          // Display the received response or handle accordingly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Response: $response")),
          );
        });
      }
    });

    characteristic.setNotifyValue(true).catchError((error) {
      print("Error enabling notifications: $error");
      return true;
    });
  }

  /// Send a value to the characteristic
  void sendValue(String value) async {
    if (writeCharacteristic != null) {
      try {
        await writeCharacteristic!.write(value.codeUnits);
        print("Value sent: $value");
      } catch (e) {
        print("Error writing value: $e");
      }
    } else {
      print("Write characteristic not found!");
    }
  }

  /// Disconnect the BLE device
  Future<void> disconnectDevice() async {
    try {
      await widget.device.disconnect();
      print("Device disconnected");
    } catch (e) {
      print("Error disconnecting device: $e");
    }
  }

  @override
  void dispose() {
    bleSubscription?.cancel();
    bleSubscription = null;

    disconnectDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await disconnectDevice();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.device.name.isNotEmpty
                ? widget.device.name
                : "Unknown Device",
          ),
        ),
        body: Center(
          child: writeCharacteristic == null
              ? const Text("Discovering services...")
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => sendValue("1"),
                        child: const Text("Send 1 (Turn On)"),
                      ),
                      ElevatedButton(
                        onPressed: () => sendValue("0"),
                        child: const Text("Send 0 (Turn Off)"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Send Alphanumeric Value (A:...)",
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) sendValue("A:$value");
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Send Numeric Value (N:...)",
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) sendValue("N:$value");
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
