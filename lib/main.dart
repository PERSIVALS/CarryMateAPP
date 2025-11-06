import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // HAPUS atau KOMENTAR baris Firebase dulu
  // await Firebase.initializeApp();
  runApp(const CarryMateApp());
}

class CarryMateApp extends StatelessWidget {
  const CarryMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarryMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
