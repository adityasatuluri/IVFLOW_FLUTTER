import 'package:flutter/material.dart';

class DripCalculatorPage extends StatefulWidget {
  const DripCalculatorPage({super.key});

  @override
  State<DripCalculatorPage> createState() => _DripCalculatorPageState();
}

class _DripCalculatorPageState extends State<DripCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  double? desiredDose; // mcg/kg/min
  double? weight; // kg
  double? bagVolume; // mL
  double? drugInBag; // mg

  double? _dripRate;

  void _calculateDripRate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _dripRate =
            (60 * desiredDose! * weight! * bagVolume!) / (1000 * drugInBag!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Drip Calculator',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Enter Values',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Desired Dose (mcg/kg/min)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                            onSaved: (value) =>
                                desiredDose = double.parse(value!),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Weight of the patient (kg)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                            onSaved: (value) => weight = double.parse(value!),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Volume of fluid in bag (mL)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                            onSaved: (value) =>
                                bagVolume = double.parse(value!),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Drug in Bag (mg)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                            onSaved: (value) =>
                                drugInBag = double.parse(value!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateDripRate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Calculate',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  if (_dripRate != null)
                    Text(
                      'IV Drip Rate: ${_dripRate!.toStringAsFixed(2)} mL/hour',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      'Formula: IV Drip Rate (mL/hr) = (60 * Desired Dose * Weight * Bag Volume) / (1000 * Drug in Bag)',
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
