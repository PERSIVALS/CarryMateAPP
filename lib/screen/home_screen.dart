import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'remote_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2D4C6A); // deep blue from mock

    Widget body;
    if (_currentIndex == 0) {
      body = SafeArea(
        child: Column(
          children: [
            _Header(primary: primary, onRemoteTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemoteScreen()))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BatteryCartCard(primary: primary),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: _StatChip(title: 'Range To User', value: '1.5M', icon: Icons.navigation_rounded)),
                        SizedBox(width: 12),
                        Expanded(child: _StatChip(title: 'Real Weight', value: '5Kg', icon: Icons.shopping_bag_outlined)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Health Status', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: _HealthCard(title: 'Calories', value: '107 KCAL', icon: Icons.local_fire_department_outlined)),
                        SizedBox(width: 12),
                        Expanded(child: _HealthCard(title: 'Steps', value: '1075 Steps', icon: Icons.directions_walk)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentIndex == 1) {
      // Nest CartScreen scaffold inside body so bottom nav stays visible.
      body = const CartScreen();
    } else {
      body = const ProfileScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.primary, this.onRemoteTap});
  final Color primary;
  final VoidCallback? onRemoteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good Morning!', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              Text('Yoo Jae Suk', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
          ),
          // prominent header remote button (white pill)
          InkWell(
            onTap: onRemoteTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gamepad, color: primary, size: 16),
                  const SizedBox(width: 8),
                  Text('Remote', style: GoogleFonts.inter(color: primary, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryCartCard extends StatelessWidget {
  const _BatteryCartCard({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text('Cart 32', style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Battery', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1)),
                Text('Cart', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1)),
              ],
            ),
          ),

          // Right circular battery
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFE9EEF4),
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('85%', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Icon(Icons.battery_charging_full_rounded, size: 18, color: Colors.black54),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D4C6A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // circular icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E7ECF), width: 4),
            ),
            child: Icon(icon, color: const Color(0xFF2E7ECF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
            ]),
          )
        ],
      ),
    );
  }
}
