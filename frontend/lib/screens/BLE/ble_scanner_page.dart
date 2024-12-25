import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_control_page.dart';

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
