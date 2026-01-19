// Basic smoke test for AirSlate application
//
// This test verifies that the application can be built and launched
// without errors.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:airslate/main.dart';

void main() {
  testWidgets('AirSlate app launches without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that the app builds successfully
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
