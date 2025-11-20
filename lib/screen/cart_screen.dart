import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simple data model representing a robot cart.
class CartItem {
  CartItem({required this.id, required this.battery, required this.rangeMeters, required this.weightKg});
  final int id; // cart identifier
  double battery; // 0..100
  double rangeMeters; // distance to user
  double weightKg; // carried load
}

/// Fake repository producing cart data. In the future replace with Firestore calls.
class CartRepository with ChangeNotifier {
  final _rng = Random();
  final List<CartItem> _carts = [
    CartItem(id: 32, battery: 85, rangeMeters: 1.5, weightKg: 5),
    CartItem(id: 12, battery: 42, rangeMeters: 2.1, weightKg: 3.2),
    CartItem(id: 7, battery: 96, rangeMeters: 0.8, weightKg: 1.7),
  ];

  List<CartItem> get carts => List.unmodifiable(_carts);

  /// Simulate refresh by randomizing values slightly.
  Future<void> refresh() async {
    for (final c in _carts) {
      c.battery = (c.battery + _rng.nextInt(15) - 7).clamp(0, 100).toDouble();
      c.rangeMeters = (c.rangeMeters + _rng.nextDouble() - 0.5).clamp(0.3, 5.0);
      c.weightKg = (c.weightKg + _rng.nextDouble() - 0.5).clamp(0, 20);
    }
    notifyListeners();
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final repo = CartRepository();
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2D4C6A);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Carts', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D4C6A), Color(0xFF1E3A52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await repo.refresh();
              if (mounted) setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Available Carts',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D4C6A),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, i) {
                    final cart = repo.carts[i];
                    final isSelected = cart.id == selectedId;
                    return GestureDetector(
                      onTap: () => setState(() => selectedId = cart.id),
                      child: _CartCard(cart: cart, primary: primary, selected: isSelected),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: repo.carts.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartCard extends StatelessWidget {
  const _CartCard({required this.cart, required this.primary, required this.selected});
  final CartItem cart;
  final Color primary;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: selected ? primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.08),
            blurRadius: selected ? 25 : 20,
            offset: Offset(0, selected ? 12 : 8),
          ),
        ],
        border: Border.all(
          color: selected ? primary : Colors.transparent,
          width: 2.5,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_cart_outlined, size: 18, color: primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cart ${cart.id}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.battery_charging_full, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${cart.battery.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(Icons.navigation, 'Range: ${cart.rangeMeters.toStringAsFixed(1)} m'),
                const SizedBox(height: 4),
                _InfoRow(Icons.scale, 'Weight: ${cart.weightKg.toStringAsFixed(1)} Kg'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: cart.battery / 100,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFE9EEF4),
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cart.battery.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.battery_charging_full_rounded, size: 18, color: primary),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
      ],
    );
  }
}
