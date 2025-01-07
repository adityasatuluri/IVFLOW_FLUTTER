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
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

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

  void subscribeToNotifications(BluetoothCharacteristic characteristic) {
    bleSubscription = characteristic.value.listen((value) {
      final response = String.fromCharCodes(value);
      print("Received response: $response");
      if (mounted) {
        setState(() {
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

  void sendCredentials() async {
    if (writeCharacteristic != null) {
      try {
        String ssid = _ssidController.text;
        String password = _passwordController.text;

        if (ssid.isNotEmpty) {
          await writeCharacteristic!.write("SSID:$ssid".codeUnits);
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (password.isNotEmpty) {
          await writeCharacteristic!.write("PASS:$password".codeUnits);
          await Future.delayed(const Duration(milliseconds: 500));
        }

        await writeCharacteristic!.write("CONNECT".codeUnits);
        setState(() {
          _isConnected = !_isConnected;
        });
      } catch (e) {
        print("Error sending credentials: $e");
      }
    }
  }

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
    _ssidController.dispose();
    _passwordController.dispose();
    disconnectDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await disconnectDevice();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.device.name.isNotEmpty
                ? widget.device.name
                : "Unknown Device",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'SSID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: writeCharacteristic != null ? sendCredentials : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.red : Colors.green,
                ),
                child: Text(_isConnected ? "Disconnect" : "Connect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
