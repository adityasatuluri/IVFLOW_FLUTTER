import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DeviceScannerPage(),
    );
  }
}

class DeviceScannerPage extends StatefulWidget {
  const DeviceScannerPage({super.key});

  @override
  State<DeviceScannerPage> createState() => _DeviceScannerPageState();
}

class _DeviceScannerPageState extends State<DeviceScannerPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() async {
    setState(() {
      isScanning = true;
      scanResults = [];
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    }).onDone(() {
      setState(() {
        isScanning = false;
      });
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  void onDeviceTap(BluetoothDevice device) async {
    stopScan();
    await device.connect();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceControlPage(device: device),
      ),
    );
  }

  Widget buildDeviceList() {
    return ListView.builder(
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        final result = scanResults[index];
        return ListTile(
          title: Text(result.device.name.isNotEmpty
              ? result.device.name
              : "Unknown Device"),
          subtitle: Text(result.device.id.id),
          onTap: () => onDeviceTap(result.device),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Device Scanner'),
        actions: [
          if (isScanning)
            IconButton(
              onPressed: stopScan,
              icon: const Icon(Icons.stop),
            )
          else
            IconButton(
              onPressed: startScan,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: scanResults.isEmpty
          ? const Center(child: Text('No devices found'))
          : buildDeviceList(),
    );
  }
}

class DeviceControlPage extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceControlPage({super.key, required this.device});

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  BluetoothCharacteristic? writeCharacteristic;

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  void discoverServices() async {
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
          }
        }
      }
    }
  }

  void sendValue(String value) async {
    if (writeCharacteristic != null) {
      try {
        print("Writing value: $value"); // Debug log
        await writeCharacteristic!.write(value.codeUnits);
      } catch (e) {
        print("Error writing value: $e");
      }
    } else {
      print("writeCharacteristic is null"); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name.isNotEmpty
            ? widget.device.name
            : "Unknown Device"),
      ),
      body: Center(
        child: writeCharacteristic == null
            ? const Text("Discovering services...")
            : Column(
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
                ],
              ),
      ),
    );
  }
}
