import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/BLE/ble_scanner_page.dart';
import 'screens/Test/home_page.dart';
import 'screens/Test/alarm_page.dart';
import 'screens/Test/drip_calculator_page.dart';

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
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool appState = false;
  int maxDripRate = 50;

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleSession(bool newState) {
    setState(() {
      appState = newState;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateMaxDripRate(int newMax) {
    setState(() {
      maxDripRate = newMax < 500 ? newMax : 500; // Ensure positive value
      appState = false; // Reset appState when maxDripRate changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      HomePage(
        appState: appState,
        maxDripRate: maxDripRate,
        toggleSession: _toggleSession,
      ),
      AlarmPage(
        toggleSession: _toggleSession,
        updateMaxDripRate: _updateMaxDripRate,
        currentMaxDripRate: maxDripRate,
      ),
      const DeviceScannerPage(),
      const DripCalculatorPage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarm'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Add Device'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: 'Drip Calc'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
