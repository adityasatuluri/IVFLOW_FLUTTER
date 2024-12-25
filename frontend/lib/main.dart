import 'package:flutter/material.dart';
import 'screens/BLE/ble_scanner_page.dart';

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
