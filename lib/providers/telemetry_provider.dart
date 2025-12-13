import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';
import '../services/mqtt_service.dart';

class TelemetryProvider extends ChangeNotifier {
  final MQTTService _mqtt;
  TelemetryProvider(this._mqtt) {
    _mqtt.telemetryStream.listen((data) {
      _telemetry = data;
      notifyListeners();
    });
  }

  TelemetryData? _telemetry;
  TelemetryData? get telemetry => _telemetry;

  void sendCommand(String command) {
    _mqtt.publishCommand(command);
  }
}