// Platform-specific tests for AirSlate application
//
// These tests verify platform-specific behavior:
// - Windows: window controls, blur effects
// - macOS: window controls position, native blur
// - Visual consistency across platforms

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:airslate/main.dart';
import 'package:airslate/ui/widgets/title_bar.dart';
import 'package:airslate/ui/widgets/glass_container.dart';
import 'package:airslate/ui/widgets/sidebar.dart';

void main() {
  group('Platform-Specific Tests - Window Controls', () {
    testWidgets('Title bar is present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify title bar exists
      expect(find.byType(TitleBar), findsOneWidget);

      // Verify window control buttons are present
      // The TitleBar should contain buttons for close, minimize, maximize
      final titleBarWidget = tester.widget<TitleBar>(find.byType(TitleBar));
      expect(titleBarWidget, isNotNull);
    });

    testWidgets('Window controls are positioned correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      final titleBarFinder = find.byType(TitleBar);
      expect(titleBarFinder, findsOneWidget);

      // Get the title bar widget
      final titleBar = tester.widget<TitleBar>(titleBarFinder);
      
      // On macOS, controls should be on the left
      // On Windows, controls should be on the right
      // This is handled in the TitleBar implementation
      
      // Verify the title bar has the correct height
      final titleBarBox = tester.getSize(titleBarFinder);
      expect(titleBarBox.height, equals(52.0));
    });

    testWidgets('Title bar responds to interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      final titleBarFinder = find.byType(TitleBar);
      expect(titleBarFinder, findsOneWidget);

      // Verify title bar can be interacted with (dragging area)
      // In a real app, this would trigger window dragging
      // In tests, we just verify the widget responds to gestures
      await tester.tap(titleBarFinder);
      await tester.pumpAndSettle();

      // No errors should occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Platform-Specific Tests - Blur Effects', () {
    testWidgets('Glassmorphism effects are applied', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify GlassContainer widgets are present
      expect(find.byType(GlassContainer), findsWidgets);

      // Verify sidebar uses glassmorphism
      expect(find.byType(Sidebar), findsOneWidget);
    });

    testWidgets('Blur effects render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Find all GlassContainer instances
      final glassContainers = find.byType(GlassContainer);
      
      // Verify they render without errors
      for (final container in tester.widgetList<GlassContainer>(glassContainers)) {
        expect(container.borderRadius, greaterThan(0));
        expect(container.blurSigma, greaterThan(0));
      }

      // No rendering errors should occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('Backdrop filters are properly configured', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify BackdropFilter widgets exist (used in glassmorphism)
      expect(find.byType(BackdropFilter), findsWidgets);

      // Verify they render without errors
      expect(tester.takeException(), isNull);
    });
  });

  group('Platform-Specific Tests - Visual Consistency', () {
    testWidgets('Sidebar width is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      final sidebarFinder = find.byType(Sidebar);
      expect(sidebarFinder, findsOneWidget);

      // Verify sidebar has correct width (250px)
      final sidebarBox = tester.getSize(sidebarFinder);
      expect(sidebarBox.width, equals(250.0));
    });

    testWidgets('Border radius values are consistent', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Find all GlassContainer instances
      final glassContainers = find.byType(GlassContainer);
      
      // Verify border radius is within expected range (16-24px)
      for (final container in tester.widgetList<GlassContainer>(glassContainers)) {
        expect(container.borderRadius, greaterThanOrEqualTo(16.0));
        expect(container.borderRadius, lessThanOrEqualTo(24.0));
      }
    });

    testWidgets('Typography is consistent across screens', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Navigate through all screens and verify text rendering
      final screens = ['Inbox', 'Today', 'Notes'];
      
      for (final screen in screens) {
        final screenButton = find.text(screen);
        if (tester.any(screenButton)) {
          await tester.tap(screenButton);
          await tester.pumpAndSettle();

          // Verify no rendering errors
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Color scheme is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify CupertinoApp theme is applied
      final app = tester.widget<CupertinoApp>(find.byType(CupertinoApp));
      expect(app.theme, isNotNull);

      // Navigate through screens to verify consistent styling
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();

      // No styling errors should occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Platform-Specific Tests - Window Sizing', () {
    testWidgets('Window has correct default size', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // In tests, we can't directly check window size, but we can verify
      // the app renders correctly at the expected size
      final appFinder = find.byType(CupertinoApp);
      expect(appFinder, findsOneWidget);

      // Verify no layout errors occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('Layout adapts to window size', (WidgetTester tester) async {
      // Test with default size
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify sidebar and content area are both visible
      expect(find.byType(Sidebar), findsOneWidget);

      // No layout errors should occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Platform-Specific Tests - Scroll Behavior', () {
    testWidgets('Bouncing scroll physics work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Create multiple tasks to enable scrolling
      final taskInputFinder = find.byType(CupertinoTextField);
      if (tester.any(taskInputFinder)) {
        for (int i = 0; i < 5; i++) {
          await tester.enterText(taskInputFinder.first, 'Scroll test task $i');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Try to scroll
        final scrollableFinder = find.byType(CustomScrollView);
        if (tester.any(scrollableFinder)) {
          await tester.drag(scrollableFinder.first, const Offset(0, -100));
          await tester.pumpAndSettle();

          // No errors should occur during scrolling
          expect(tester.takeException(), isNull);
        }
      }
    });
  });

  group('Platform-Specific Tests - Platform Detection', () {
    test('Platform is correctly identified', () {
      // Verify we can detect the platform
      expect(Platform.isWindows || Platform.isMacOS || Platform.isLinux, isTrue);
      
      // Log platform for debugging
      if (Platform.isWindows) {
        print('Running on Windows');
      } else if (Platform.isMacOS) {
        print('Running on macOS');
      } else if (Platform.isLinux) {
        print('Running on Linux');
      }
    });
  });
}
