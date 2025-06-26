import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final bool appState;
  final int maxDripRate;
  final Function(bool) toggleSession;

  const HomePage({
    super.key,
    required this.appState,
    required this.maxDripRate,
    required this.toggleSession,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _dripRate = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 0), () {}); // Initial inactive timer
    _startOrStopTimerBasedOnState(); // Start or stop based on initial appState
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startOrStopTimerBasedOnState() {
    if (widget.appState && !_timer.isActive) {
      _timer.cancel();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _fetchLatestIVFlow();
      });
      _fetchLatestIVFlow(); // Immediate fetch on session start
    } else if (!widget.appState && _timer.isActive) {
      _timer.cancel();
      _timer = Timer(const Duration(seconds: 0), () {});
      setState(() {
        _dripRate = 0; // Reset drip rate when session ends
      });
    }
  }

  Future<void> _fetchLatestIVFlow() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.40:3000/api/ivflow/latest?deviceId=ESP32_BLE'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dripRate = (data['latest_iv_flow'] ?? 0).toInt(); // Default to 0 if null
        });
      } else {
        print(
            'Failed to fetch IV flow: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching IV flow: $e - Response: ${e.toString()}');
    }
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appState != oldWidget.appState) {
      _startOrStopTimerBasedOnState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Drip Assist', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              _buildDripRateIndicator(),
              const SizedBox(height: 32),
              _buildSessionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDripRateIndicator() {
    double progress = widget.appState
        ? (_dripRate > 0 && _dripRate <= widget.maxDripRate)
            ? _dripRate / widget.maxDripRate
            : 0.0
        : 0.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 15,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$_dripRate',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  'ml/hr',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Drip Rate: $_dripRate ml/hr (Max: ${widget.maxDripRate} ml/hr)',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionButton() {
    return SizedBox(
      width: 200, // Match the width of the CircularProgressIndicator
      child: ElevatedButton.icon(
        onPressed: () {
          widget.toggleSession(!widget.appState);
          _startOrStopTimerBasedOnState(); // Sync timer with state change
        },
        icon: Icon(
          widget.appState ? Icons.stop_circle_outlined : Icons.play_circle_fill,
          size: 24,
          color: Colors.white,
        ),
        label: Text(
          widget.appState ? 'End Session' : 'Start Session',
          style: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}