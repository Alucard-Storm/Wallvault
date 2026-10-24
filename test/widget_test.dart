// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wallvault/screens/favorites_screen.dart';
import 'package:wallvault/providers/favorites_provider.dart';
import 'package:wallvault/providers/settings_provider.dart';

void main() {
  testWidgets('FavoritesScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          // GlassAppBar reads SettingsProvider (reduce-transparency setting).
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );

    // Verify Favorites screen compiles and displays its header
    expect(find.text('Favorites'), findsOneWidget);
  });
}
