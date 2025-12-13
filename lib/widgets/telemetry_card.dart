import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';

class TelemetryCard extends StatelessWidget {
  final TelemetryData telemetry;
  const TelemetryCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Battery: ${telemetry.battery}%'),
            Text('Range to User: ${telemetry.rangeToUser}m'),
            Text('Weight: ${telemetry.weight}kg'),
          ],
        ),
      ),
    );
  }
}