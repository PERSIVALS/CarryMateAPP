// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:carrymate/main.dart';


void main() {
  testWidgets('Shows SplashScreen with branding', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const CarryMateApp());

    // Verify that the splash screen texts are shown initially.
    expect(find.text('CarryMate'), findsOneWidget);
    expect(find.text('Smart Shopping, Effortless'), findsOneWidget);

    // Do not advance time to avoid navigating to onboarding with image assets during test.
  });
}
