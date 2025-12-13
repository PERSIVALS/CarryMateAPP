import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/mqtt_service.dart';
import 'dart:developer';

class RemoteScreen extends StatefulWidget {
  final String deviceId; // tambahkan field ini
  final MQTTService mqtt;

  const RemoteScreen({super.key, required this.deviceId, required this.mqtt});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}


class _RemoteScreenState extends State<RemoteScreen> {
  bool _isAutomatic = true;
  late MQTTService _mqtt;
  bool _mqttReady = false;
  String? _mqttError;
  Timer? _holdTimer;
  String? _holdingCommand;
  MobileScannerController? _qrController;
  String? _scannedQRCode;
  bool _isQRScanMode = false;
  bool _flashOn = false;
  double _rangeToUser = 0.0; // Add range state

  @override
  void initState() {
    super.initState();
    _mqtt = widget.mqtt;
    if (_isAutomatic) {
      _initQRScanner();
    }
    _setupMqtt();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _stopHold();
    super.dispose();
  }

  void _initQRScanner() {
    _qrController?.dispose();
    _qrController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: _flashOn,
      returnImage: false,
    );
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
      _qrController?.toggleTorch();
    });
  }

  void _toggleQRScanMode() {
    setState(() {
      _isQRScanMode = !_isQRScanMode;
      _scannedQRCode = null; // Clear previous scan
    });
  }



  Future<void> _setupMqtt() async {
    _mqtt = MQTTService();
    try {
      await _mqtt.connect();
      if (mounted) {
        setState(() { _mqttReady = true; });
        // Subscribe to telemetry stream
        _mqtt.telemetryStream.listen((data) {
          if (mounted) {
            setState(() {
              _rangeToUser = data.rangeToUser;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _mqttError = 'MQTT error: $e'; });
    }
  }

  Future<void> _sendCommand(String cmd, {bool feedback = true, bool hold = false}) async {
    try {
      await _mqtt.publishCommand(cmd, hold: hold);
      if (mounted && feedback) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Command: $cmd'), duration: const Duration(milliseconds: 500)),
        );
      }
    } catch (e) {
      log('Send command error: $e');
      if (mounted && feedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $cmd')),);
      }
    }
  }

  void _startHold(String cmd) {
    _stopHold();
    _holdingCommand = cmd;
    // kirim segera sekali saat mulai (tanpa SnackBar agar tidak spam)
    _sendCommand(cmd, feedback: false, hold: true);
    _holdTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_holdingCommand != null) {
        _sendCommand(_holdingCommand!, feedback: false, hold: true);
      }
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdingCommand = null;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2D4C6A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Blue curved header area
            Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0xFF2D4C6A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // back button to return to Home
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.black54, size: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Good Morning!', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                          Text('Yoo Jae Suk', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      // small label
                      Text('Remote', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),

                  const SizedBox(height: 18),
                  // Manual / Automatic toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_isAutomatic) {
                            setState(() => _isAutomatic = false);
                            _qrController?.dispose();
                            _qrController = null;
                            _sendCommand('MODE_MANUAL');
                            _stopHold();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manual', style: GoogleFonts.inter(color: _isAutomatic ? Colors.white70 : Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            // underline only when Manual active
                            Container(height: 4, width: 80, decoration: BoxDecoration(color: !_isAutomatic ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          if (!_isAutomatic) {
                            setState(() => _isAutomatic = true);
                            _initQRScanner();
                            _sendCommand('MODE_AUTOMATIC');
                            _stopHold();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Automatic', style: GoogleFonts.inter(color: _isAutomatic ? Colors.white : Colors.white70, fontSize: 26, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Container(height: 4, width: 100, decoration: BoxDecoration(color: _isAutomatic ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls / Camera area depending on mode
            Expanded(
              child: _isAutomatic ? _buildAutomaticArea(context) : _buildManualArea(context),
            ),

            // Bottom semicircle-ish bar
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: 220,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomIcon(icon: Icons.home, onTap: () => Navigator.of(context).pop()),
                      _BottomIcon(icon: Icons.apps, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _AppsScreen()))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualArea(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Up button
        _HoldDirectionButton(icon: Icons.arrow_upward, onHoldStart: () => _startHold('UP'), onHoldEnd: _stopHold),
        const SizedBox(height: 18),

        // Left, center (invisible), right
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HoldDirectionButton(icon: Icons.arrow_back, onHoldStart: () => _startHold('LEFT'), onHoldEnd: _stopHold),
            const SizedBox(width: 18),
            SizedBox(width: 84, height: 64),
            const SizedBox(width: 18),
            _HoldDirectionButton(icon: Icons.arrow_forward, onHoldStart: () => _startHold('RIGHT'), onHoldEnd: _stopHold),
          ],
        ),

        const SizedBox(height: 18),
        // Down button
        _HoldDirectionButton(icon: Icons.arrow_downward, onHoldStart: () => _startHold('DOWN'), onHoldEnd: _stopHold),
      ],
    );
  }

  Widget _buildAutomaticArea(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Camera Preview with controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Camera preview area
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _qrController != null
                        ? Stack(
                            children: [
                              // Camera/Scanner view
                              MobileScanner(
                                controller: _qrController!,
                                onDetect: _isQRScanMode ? (capture) {
                                  final List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isNotEmpty) {
                                    final barcode = barcodes.first;
                                    if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                                      setState(() {
                                        _scannedQRCode = barcode.rawValue;
                                      });
                                      log('QR Code detected: ${barcode.rawValue}');
                                      // Send QR code to robot
                                      _sendCommand('QR:${barcode.rawValue}');
                                      // Show success feedback
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✓ QR Code: ${barcode.rawValue}'),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                } : null,
                              ),
                              // QR Scan overlay (only show when in QR mode)
                              if (_isQRScanMode)
                                Center(
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _scannedQRCode != null ? Colors.green : Colors.white,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_scannedQRCode != null)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Top controls
                              Positioned(
                                top: 12,
                                left: 12,
                                right: 12,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Flash toggle
                                    _CameraControlButton(
                                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                                      onTap: _toggleFlash,
                                      active: _flashOn,
                                    ),
                                    // Mode indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _isQRScanMode ? '🔍 QR Scan' : '📷 Camera',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    // QR scan mode toggle
                                    _CameraControlButton(
                                      icon: _isQRScanMode ? Icons.camera_alt : Icons.qr_code_scanner,
                                      onTap: _toggleQRScanMode,
                                      active: _isQRScanMode,
                                    ),
                                  ],
                                ),
                              ),
                              // Bottom instruction text
                              if (_isQRScanMode)
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Arahkan ke QR Code',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt, size: 56, color: Colors.black38),
                                  SizedBox(height: 8),
                                  Text('Memuat Kamera...', style: TextStyle(color: Colors.black45)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Camera action buttons - simplified
                if (_isQRScanMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Arahkan kamera ke QR Code untuk scan otomatis',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (!_mqttReady && _mqttError == null)
          const Text('Menghubungkan MQTT...', style: TextStyle(color: Colors.black54))
        else if (_mqttError != null)
          Text(_mqttError!, style: const TextStyle(color: Colors.redAccent))
        else
          const Text('MQTT siap', style: TextStyle(color: Colors.green)),

        if (_scannedQRCode != null) ...[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(height: 8),
                const Text('QR Code Scanned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  _scannedQRCode!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),
        // Range card
        Column(
          children: [
            const Text('Range To User', style: TextStyle(color: Colors.black54, fontSize: 16)),
            const SizedBox(height: 6),
            Text('${_rangeToUser.toStringAsFixed(1)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Meter', style: TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
    );
  }
}

    // Simple placeholder Apps screen shown when tapping the apps icon
    class _AppsScreen extends StatelessWidget {
      const _AppsScreen();

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Apps'),
            backgroundColor: const Color(0xFF2D4C6A),
          ),
          body: Center(
            child: Text('Apps placeholder', style: GoogleFonts.inter(fontSize: 18)),
          ),
        );
      }
    }

class _HoldDirectionButton extends StatefulWidget {
  const _HoldDirectionButton({required this.icon, required this.onHoldStart, required this.onHoldEnd});
  final IconData icon;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  State<_HoldDirectionButton> createState() => _HoldDirectionButtonState();
}

class _HoldDirectionButtonState extends State<_HoldDirectionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onHoldStart();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onHoldEnd();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onHoldEnd();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 84,
        height: 64,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF2D4C6A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed ? const Color(0xFF2D4C6A) : Colors.black87, 
            width: 2,
          ),
          boxShadow: _isPressed 
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
        ),
        child: Center(
          child: Icon(
            widget.icon, 
            color: _isPressed ? Colors.white : Colors.black87, 
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF2D4C6A)),
      ),
    );
  }
}

// Camera control button (flash, switch, etc)
class _CameraControlButton extends StatelessWidget {
  const _CameraControlButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF2D4C6A) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
