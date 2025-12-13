import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/qr_parser.dart';
import '../services/mqtt_service.dart';
import 'remote_screen.dart';
import 'package:provider/provider.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) async {
    print('onDetect terpanggil, jumlah barcode: ${capture.barcodes.length}');
    if (_handled) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    print('QR raw: $raw');

    print('Mulai parse QR: $raw');
    final cfg = QRParser.parse(raw);
    print('Hasil parse: $cfg');

    if (cfg == null) {
      print('Config null, QR tidak valid');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR tidak valid')),
      );
      return;
    }

    print('Config valid: device=${cfg.device}, broker=${cfg.broker}, port=${cfg.port}');
    final mqtt = context.read<MQTTService>();

    try {
      print('Mencoba koneksi MQTT...');
      await mqtt.connectWith(
        broker: cfg.broker,
        port: cfg.port,
        clientId: 'carrymate_${cfg.device}',
        telemetryTopic: cfg.telemetryTopic,
        commandTopic: cfg.commandTopic,
      );
      print('Koneksi MQTT sukses, navigasi ke RemoteScreen...');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RemoteScreen(deviceId: cfg.device, mqtt: mqtt),
        ),
      );
      _handled = true; // tandai sudah diproses
    } catch (e) {
      print('Error saat koneksi MQTT: $e');
      _handled = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal koneksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Robot')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Arahkan ke QR pairing CarryMate',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}