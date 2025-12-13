class PairConfig {
  final String device;
  final String broker;
  final int port;
  final String telemetryTopic;
  final String commandTopic;

  PairConfig({
    required this.device,
    required this.broker,
    required this.port,
    required this.telemetryTopic,
    required this.commandTopic,
  });
}

class QRParser {
  static PairConfig? parse(String raw) {
    if (!raw.startsWith('carrymate://pair')) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;

    final q = uri.queryParameters;
    final device = q['device'];
    final broker = q['broker'];
    final portStr = q['port'];
    final telemetry = q['telemetry'];
    final command = q['command'];

    if ([device, broker, portStr, telemetry, command].any((v) => v == null || v!.isEmpty)) {
      return null;
    }

    final port = int.tryParse(portStr!);
    if (port == null || port <= 0 || port > 65535) return null;

    return PairConfig(
      device: device!,
      broker: broker!,
      port: port,
      telemetryTopic: telemetry!,
      commandTopic: command!,
    );
  }
}