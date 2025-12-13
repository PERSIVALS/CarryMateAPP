import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import '../models/telemetry_data.dart';

class MQTTService {
  final MqttServerClient _client;

  // default bawaan
  final String commandTopic = 'carrymate/mobile/command';
  final String telemetryTopic = 'carrymate/robot/telemetry';

  // tambahan untuk konfigurasi dinamis dari QR
  String? _dynamicCommandTopic;
  String? _dynamicTelemetryTopic;

  bool _connected = false;
  bool _connecting = false;

  final StreamController<TelemetryData> _telemetryController =
      StreamController<TelemetryData>.broadcast();
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;

  MQTTService()
      : _client = MqttServerClient(
          'broker.hivemq.com',
          'carrymate-${const Uuid().v4()}',
        ) {
    _client.logging(on: false);
    _client.port = 1883; // unsecured port
    _client.keepAlivePeriod = 30;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
  }

  /// Method lama tetap ada
  Future<void> connect() async {
    if (_connected || _connecting) return;
    _connecting = true;
    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    try {
      log('MQTT connect() mulai...');
      await _client.connect();
      log('MQTT connect() selesai, status=${_client.connectionStatus}');
      if (_client.connectionStatus?.state != MqttConnectionState.connected) {
        throw Exception('MQTT connect failed: ${_client.connectionStatus}');
      }
      _connected = true;
      final topic = _dynamicTelemetryTopic ?? telemetryTopic;
      _client.subscribe(topic, MqttQos.atMostOnce);
      log('Subscribed ke $topic');
      _client.updates!.listen(_onMessage);
    } catch (e) {
      log('MQTT connect error: $e');
      _client.disconnect();
      rethrow;
    } finally {
      _connecting = false;
    }
  }
  
  /// Method baru: connect dengan konfigurasi hasil QR
  Future<void> connectWith({
    required String broker,
    required int port,
    required String clientId,
    required String telemetryTopic,
    required String commandTopic,
  }) async {
    _dynamicTelemetryTopic = telemetryTopic;
    _dynamicCommandTopic = commandTopic;

    _client.server = broker;
    _client.port = port;
    _client.clientIdentifier = clientId;

    await connect(); // tetap pakai logika connect() lama
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

    // pilih topic dinamis kalau ada
    final topic = _dynamicCommandTopic ?? commandTopic;
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
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
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // pilih telemetry topic dinamis kalau ada
      final expectedTopic = _dynamicTelemetryTopic ?? telemetryTopic;
      if (topic == expectedTopic) {
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