import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'remote_screen.dart';
import 'cart_screen.dart';

class UserHealth with ChangeNotifier {
  UserHealth({required this.name, required this.email, this.steps = 1075, this.calories = 107});
  String name;
  String email;
  int steps;
  int calories; // simplistic static calories

  void incrementSteps([int by = 10]) {
    steps += by;
    if (steps % 100 == 0) calories += 3; // trivial calories increase
    notifyListeners();
  }

  void updateName(String newName) {
    name = newName.trim();
    notifyListeners();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = UserHealth(name: 'Yoo Jae Suk', email: 'user@example.com');
  bool _editing = false;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = user.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2D4C6A);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // In future: FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: user,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D4C6A), Color(0xFF1E3A52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Color(0xFF2D4C6A)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editing
                                ? TextField(
                                    controller: _nameCtrl,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      labelText: 'Name',
                                      labelStyle: TextStyle(color: Colors.white70),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white70),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSubmitted: (v) => _saveName(),
                                  )
                                : Text(
                                    user.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 14, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  user.email,
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(_editing ? Icons.check : Icons.edit, color: Colors.white),
                          onPressed: () => _editing ? _saveName() : setState(() => _editing = true),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Health Status',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D4C6A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _healthCard('Calories', '${user.calories} KCAL', Icons.local_fire_department_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _healthCard('Steps', '${user.steps} Steps', Icons.directions_walk)),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7ECF), Color(0xFF1E5FA0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7ECF).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => user.incrementSteps(25),
                      icon: const Icon(Icons.directions_walk, color: Colors.white),
                      label: const Text(
                        'Tambah Langkah +25',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Aksi Cepat',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D4C6A),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _quickAction(Icons.settings_remote, 'Remote', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RemoteScreen()));
                        }),
                        _quickAction(Icons.shopping_cart, 'Cart 32', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                        }),
                        _quickAction(Icons.shield, 'Safety', () {
                          _showInfoDialog(
                            context,
                            'Safety Tips',
                            '1. Jaga jarak aman dengan robot saat bergerak.\n'
                            '2. Pastikan area sekitar bebas dari halangan.\n'
                            '3. Matikan perangkat jika terjadi anomali berat.\n'
                            '4. Periksa roda & sensor secara berkala.',
                          );
                        }),
                        _quickAction(Icons.battery_charging_full, 'Battery', () {
                          _showInfoDialog(
                            context,
                            'Battery Status',
                            'Perkiraan baterai saat ini 85%.\nGunakan mode hemat daya saat tinggal < 20%.',
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _healthCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFF2E7ECF).withValues(alpha: 0.2), const Color(0xFF2E7ECF).withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFF2E7ECF), width: 3),
            ),
            child: Icon(icon, color: const Color(0xFF2E7ECF), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 6),
              Text(value, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
            ]),
          )
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7ECF).withValues(alpha: 0.15),
                    const Color(0xFF2E7ECF).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2E7ECF), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _saveName() {
    user.updateName(_nameCtrl.text);
    setState(() => _editing = false);
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
