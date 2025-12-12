import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import '../models/telemetry_data.dart';

class MQTTService {
  final MqttServerClient _client;
  final String commandTopic = 'carrymate/mobile/command';
  final String telemetryTopic = 'carrymate/robot/telemetry';
  bool _connected = false;
  bool _connecting = false;
  
  final StreamController<TelemetryData> _telemetryController = StreamController<TelemetryData>.broadcast();
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;

  MQTTService()
      : _client = MqttServerClient('broker.hivemq.com', 'carrymate-${const Uuid().v4()}') {
    _client.logging(on: false);
    _client.port = 1883; // unsecured port
    _client.keepAlivePeriod = 30;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
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
      // Subscribe to telemetry after connected
      _client.subscribe(telemetryTopic, MqttQos.atMostOnce);
      _client.updates!.listen(_onMessage);
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
    _client.publishMessage(commandTopic, MqttQos.atMostOnce, builder.payload!);
    log('MQTT publish: $payload');
  }

  void _onDisconnected() {
    _connected = false;
  }

  void _onConnected() {
    _connected = true;
    log('MQTT connected');
  }

  void _onSubscribed(String topic) {
    log('MQTT subscribed to: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final recMess = msg.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      if (topic == telemetryTopic) {
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final telemetry = TelemetryData.fromJson(json);
          _telemetryController.add(telemetry);
          log('Telemetry received: battery=${telemetry.battery}%, range=${telemetry.rangeToUser}m');
        } catch (e) {
          log('Failed to parse telemetry: $e');
        }
      }
    }
  }

  void dispose() {
    _telemetryController.close();
    _client.disconnect();
  }
}
