import 'dart:convert';
import 'dart:developer';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MQTTService {
  final MqttServerClient _client;
  final String topic = 'carrtmate/mobile/command'; // sesuai permintaan
  bool _connected = false;
  bool _connecting = false;

  MQTTService()
      : _client = MqttServerClient('broker.hivemq.com', 'carrymate-${const Uuid().v4()}') {
    _client.logging(on: false);
    _client.port = 1883; // unsecured port
    _client.keepAlivePeriod = 30;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = (t) {};
  }

  Future<void> connect() async {
    if (_connected || _connecting) return;
    _connecting = true;
    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    try {
      await _client.connect();
      if (_client.connectionStatus?.state != MqttConnectionState.connected) {
        throw Exception('MQTT connect failed: ${_client.connectionStatus}');
      }
      _connected = true;
    } catch (e) {
      _client.disconnect();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  bool get isConnected => _connected;

  Future<void> ensureConnected() async {
    if (!_connected) {
      await connect();
    }
  }

  Future<void> publishCommand(String command, {bool hold = false}) async {
    await ensureConnected();
    final payloadMap = {
      'command': command,
      'timestamp': DateTime.now().toIso8601String(),
      if (hold) 'hold': true,
    };
    final payload = jsonEncode(payloadMap);
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    log('MQTT publish: $payload');
  }

  void _onDisconnected() {
    _connected = false;
  }

  void _onConnected() {
    _connected = true;
  }

  void dispose() {
    _client.disconnect();
  }
}
