import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:carrymate/screen/cart_screen.dart';
import 'package:carrymate/screen/profile_screen.dart';

void main() {
  group('CartScreen', () {
    testWidgets('shows list of carts and refresh button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CartScreen()));
      expect(find.text('Carts'), findsOneWidget); // AppBar title
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // initial cart item
      expect(find.textContaining('Cart'), findsWidgets);

      // tap refresh and ensure still shows carts
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.textContaining('Cart'), findsWidgets);
    });
  });

  group('ProfileScreen', () {
    testWidgets('shows health status and increments steps', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      expect(find.text('Profile'), findsOneWidget); // AppBar title
      expect(find.text('Health Status'), findsOneWidget);
      final stepsFinder = find.textContaining('Steps');
      expect(stepsFinder, findsWidgets);

      final buttonFinder = find.text('Tambah Langkah +25');
      expect(buttonFinder, findsOneWidget);

      // capture steps value before
      String before = tester.widget<Text>(find.textContaining('Steps').first).data!;

      await tester.tap(buttonFinder);
      await tester.pump();

      // Ensure steps changed (contains larger number)
      final afterTextWidgets = tester.widgetList<Text>(find.textContaining('Steps'));
      bool changed = afterTextWidgets.any((t) => t.data != null && t.data! != before);
      expect(changed, isTrue);
    });
  });
}
