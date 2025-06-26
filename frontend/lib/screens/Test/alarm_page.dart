import 'package:flutter/material.dart';

class AlarmPage extends StatelessWidget {
  final Function(bool) toggleSession;
  final Function(int) updateMaxDripRate;
  final int currentMaxDripRate;

  const AlarmPage(
      {super.key,
      required this.toggleSession,
      required this.updateMaxDripRate,
      required this.currentMaxDripRate});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _maxDripRateController =
        TextEditingController(text: currentMaxDripRate.toString());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Alarm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _maxDripRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Drip Rate (ml/hr)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newMaxDripRate =
                    int.tryParse(_maxDripRateController.text) ?? 50;
                updateMaxDripRate(newMaxDripRate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Submit Max Drip Rate',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => toggleSession(true),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue, width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Toggle Session for Testing',
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
