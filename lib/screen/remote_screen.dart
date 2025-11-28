import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../services/mqtt_service.dart';
import 'dart:developer';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  bool _isAutomatic = true; // default to Automatic as in the mock
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraInitializing = false;
  late MQTTService _mqtt;
  bool _mqttReady = false;
  String? _mqttError;
  Timer? _holdTimer;
  String? _holdingCommand;

  @override
  void initState() {
    super.initState();
    if (_isAutomatic) {
      _initCamera();
    }
    _setupMqtt();
  }

  @override
  void dispose() {
    _disposeCamera();
    _stopHold();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (_cameraController != null) return;
    setState(() => _cameraInitializing = true);
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final back = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras!.first);
        _cameraController = CameraController(back, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
      }
    } catch (e) {
      // ignore errors here but log
      debugPrint('Camera init error: $e');
    } finally {
      if (mounted) setState(() => _cameraInitializing = false);
    }
  }

  Future<void> _disposeCamera() async {
    try {
      await _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;
  }

  Future<void> _setupMqtt() async {
    _mqtt = MQTTService();
    try {
      await _mqtt.connect();
      if (mounted) setState(() { _mqttReady = true; });
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
                            await _disposeCamera();
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
                            await _initCamera();
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
    // Placeholder camera area + range card
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Camera preview placeholder - replace with actual camera widget later
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black,
                child: _cameraController != null && _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : _cameraInitializing
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam_outlined, size: 56, color: Colors.black38),
                                  SizedBox(height: 8),
                                  Text('Camera preview', style: TextStyle(color: Colors.black45)),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!_mqttReady && _mqttError == null)
          const Text('Menghubungkan MQTT...', style: TextStyle(color: Colors.black54))
        else if (_mqttError != null)
          Text(_mqttError!, style: const TextStyle(color: Colors.redAccent))
        else
          const Text('MQTT siap', style: TextStyle(color: Colors.green)),

        const SizedBox(height: 28),
        // Range card
        Column(
          children: const [
            Text('Range To User', style: TextStyle(color: Colors.black54, fontSize: 16)),
            SizedBox(height: 6),
            Text('1.5', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Meter', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ],
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

class _HoldDirectionButton extends StatelessWidget {
  const _HoldDirectionButton({required this.icon, required this.onHoldStart, required this.onHoldEnd});
  final IconData icon;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onHoldStart(),
      onPointerUp: (_) => onHoldEnd(),
      onPointerCancel: (_) => onHoldEnd(),
      child: SizedBox(
        width: 84,
        height: 64,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: const Border.fromBorderSide(BorderSide(color: Colors.black87, width: 2)),
          ),
          child: Center(child: Icon(icon, color: Colors.black87, size: 28)),
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
