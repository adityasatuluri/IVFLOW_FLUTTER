import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BLE Device Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // Listen to scanning state changes
    FlutterBluePlus.isScanning.listen((state) {
      setState(() {
        isScanning = state;
      });
    });
  }

  Future<void> requestPermissions() async {
    // Request necessary permissions for BLE scanning
    if (await Permission.bluetoothScan.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth scan permission is required')),
      );
      return;
    }
    if (await Permission.bluetoothConnect.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bluetooth connect permission is required')),
      );
      return;
    }
    if (await Permission.locationWhenInUse.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permission is required for BLE')),
      );
      return;
    }
  }

  void startScan() async {
    // Request permissions
    await requestPermissions();

    // Check Bluetooth adapter state
    var state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      // Clear previous scan results
      setState(() {
        scanResults = [];
      });

      // Start scanning
      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 10),
        );
      } catch (e) {
        print('Error starting scan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting scan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please turn on Bluetooth')),
      );
    }
  }

  void stopScan() async {
    // Stop scanning
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error stopping scan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping scan: $e')),
      );
    }
  }

  Widget deviceList() {
    return ListView.builder(
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        final result = scanResults[index];
        return ListTile(
          title: Text(result.device.name.isEmpty
              ? 'Unknown Device'
              : result.device.name),
          subtitle: Text(result.device.id.id),
          trailing: Text('${result.rssi} dBm'),
        );
      },
    );
  }

  @override
  void dispose() {
    // Stop scanning when the widget is disposed
    if (isScanning) {
      stopScan();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: scanResults.isEmpty
                  ? const Center(
                      child: Text('No devices found'),
                    )
                  : deviceList(),
            ),
            if (isScanning) const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? stopScan : startScan,
        tooltip: isScanning ? 'Stop Scan' : 'Start Scan',
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
