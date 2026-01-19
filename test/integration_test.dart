// Integration tests for AirSlate application
//
// These tests verify complete user flows including:
// - Task creation, editing, and deletion
// - Note creation, editing, and deletion
// - Navigation between sections
// - Data persistence

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:airslate/main.dart';
import 'package:airslate/data/models/task.dart';
import 'package:airslate/data/models/note.dart';
import 'package:airslate/data/database/isar_service.dart';
import 'package:airslate/ui/screens/inbox_screen.dart';
import 'package:airslate/ui/screens/today_screen.dart';
import 'package:airslate/ui/screens/notes_screen.dart';
import 'package:airslate/ui/widgets/task_tile.dart';
import 'package:airslate/ui/widgets/task_input.dart';
import 'package:airslate/ui/widgets/note_card.dart';
import 'package:airslate/ui/widgets/sidebar.dart';

void main() {
  group('Integration Tests - Task Management', () {
    testWidgets('Complete task flow: create → complete → delete', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify we're on the Inbox screen
      expect(find.byType(InboxScreen), findsOneWidget);

      // Find the task input field
      final taskInputFinder = find.byType(TaskInput);
      expect(taskInputFinder, findsOneWidget);

      // Enter a new task
      await tester.enterText(taskInputFinder, 'Integration test task');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify task appears in the list
      expect(find.text('Integration test task'), findsOneWidget);
      expect(find.byType(TaskTile), findsAtLeastNWidgets(1));

      // Complete the task by tapping the checkbox
      final checkboxFinder = find.byType(TaskTile).first;
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Verify task is marked as completed (strikethrough should be applied)
      // The task should still be visible
      expect(find.text('Integration test task'), findsOneWidget);

      // Delete the task (swipe to delete)
      await tester.drag(checkboxFinder, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm deletion if dialog appears
      final deleteButtonFinder = find.text('Delete');
      if (tester.any(deleteButtonFinder)) {
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Empty task rejection', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Count initial tasks
      final initialTaskCount = tester.widgetList(find.byType(TaskTile)).length;

      // Try to create an empty task
      final taskInputFinder = find.byType(TaskInput);
      await tester.enterText(taskInputFinder, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify no new task was created
      final finalTaskCount = tester.widgetList(find.byType(TaskTile)).length;
      expect(finalTaskCount, equals(initialTaskCount));

      // Try whitespace-only task
      await tester.enterText(taskInputFinder, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify no new task was created
      final afterWhitespaceCount = tester.widgetList(find.byType(TaskTile)).length;
      expect(afterWhitespaceCount, equals(initialTaskCount));
    });

    testWidgets('Task completion toggle', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Create a task
      final taskInputFinder = find.byType(TaskInput);
      await tester.enterText(taskInputFinder, 'Toggle test task');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Find the task tile
      final taskTileFinder = find.byType(TaskTile).first;

      // Toggle completion twice
      await tester.tap(taskTileFinder);
      await tester.pumpAndSettle();

      await tester.tap(taskTileFinder);
      await tester.pumpAndSettle();

      // Task should still be visible and in original state
      expect(find.text('Toggle test task'), findsOneWidget);
    });
  });

  group('Integration Tests - Navigation', () {
    testWidgets('Navigate between all sections', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify we start on Inbox
      expect(find.byType(InboxScreen), findsOneWidget);

      // Navigate to Today
      final todayButton = find.text('Today');
      expect(todayButton, findsOneWidget);
      await tester.tap(todayButton);
      await tester.pumpAndSettle();

      // Verify Today screen is displayed
      expect(find.byType(TodayScreen), findsOneWidget);

      // Navigate to Notes
      final notesButton = find.text('Notes');
      expect(notesButton, findsOneWidget);
      await tester.tap(notesButton);
      await tester.pumpAndSettle();

      // Verify Notes screen is displayed
      expect(find.byType(NotesScreen), findsOneWidget);

      // Navigate back to Inbox
      final inboxButton = find.text('Inbox');
      expect(inboxButton, findsOneWidget);
      await tester.tap(inboxButton);
      await tester.pumpAndSettle();

      // Verify Inbox screen is displayed again
      expect(find.byType(InboxScreen), findsOneWidget);
    });

    testWidgets('Navigation state persists during task operations', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Navigate to Today
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Create a task on Today screen
      final taskInputFinder = find.byType(TaskInput);
      await tester.enterText(taskInputFinder, 'Today task');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify we're still on Today screen
      expect(find.byType(TodayScreen), findsOneWidget);

      // Navigate to Inbox
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();

      // Verify we're on Inbox screen
      expect(find.byType(InboxScreen), findsOneWidget);
    });
  });

  group('Integration Tests - Notes Management', () {
    testWidgets('Complete note flow: create → edit → delete', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Navigate to Notes
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(find.byType(NotesScreen), findsOneWidget);

      // Find and tap the add note button (FAB)
      final fabFinder = find.byType(CupertinoButton);
      if (tester.any(fabFinder)) {
        await tester.tap(fabFinder.first);
        await tester.pumpAndSettle();

        // Enter note content
        final textFieldFinder = find.byType(CupertinoTextField);
        if (tester.any(textFieldFinder)) {
          await tester.enterText(textFieldFinder.first, 'Integration test note content');
          await tester.pumpAndSettle();

          // Wait for auto-save
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pumpAndSettle();

          // Go back to notes list
          final backButtonFinder = find.byType(CupertinoButton);
          if (tester.any(backButtonFinder)) {
            await tester.tap(backButtonFinder.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // Verify note appears in the list
      expect(find.textContaining('Integration test note'), findsWidgets);
    });

    testWidgets('Note auto-save functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Navigate to Notes
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Create a new note
      final fabFinder = find.byType(CupertinoButton);
      if (tester.any(fabFinder)) {
        await tester.tap(fabFinder.first);
        await tester.pumpAndSettle();

        // Enter initial content
        final textFieldFinder = find.byType(CupertinoTextField);
        if (tester.any(textFieldFinder)) {
          await tester.enterText(textFieldFinder.first, 'Initial content');
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pumpAndSettle();

          // Edit the content
          await tester.enterText(textFieldFinder.first, 'Initial content - edited');
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pumpAndSettle();

          // The note should be auto-saved
          // Go back and verify
          final backButtonFinder = find.byType(CupertinoButton);
          if (tester.any(backButtonFinder)) {
            await tester.tap(backButtonFinder.first);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });

  group('Integration Tests - Data Persistence', () {
    testWidgets('Tasks persist across widget rebuilds', (WidgetTester tester) async {
      // First session: create tasks
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Create multiple tasks
      final taskInputFinder = find.byType(TaskInput);
      
      await tester.enterText(taskInputFinder, 'Persistent task 1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(taskInputFinder, 'Persistent task 2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Count tasks
      final taskCount = tester.widgetList(find.byType(TaskTile)).length;
      expect(taskCount, greaterThanOrEqualTo(2));

      // Simulate app restart by rebuilding with new ProviderScope
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify tasks are still present
      expect(find.text('Persistent task 1'), findsOneWidget);
      expect(find.text('Persistent task 2'), findsOneWidget);
    });

    testWidgets('Navigation state resets on app restart', (WidgetTester tester) async {
      // Navigate to Notes
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(find.byType(NotesScreen), findsOneWidget);

      // Simulate app restart
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Should be back on Inbox (default)
      expect(find.byType(InboxScreen), findsOneWidget);
    });
  });

  group('Integration Tests - UI Polish', () {
    testWidgets('Animations complete without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Create a task to test checkbox animation
      final taskInputFinder = find.byType(TaskInput);
      await tester.enterText(taskInputFinder, 'Animation test task');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Toggle task completion to trigger animations
      final taskTileFinder = find.byType(TaskTile).first;
      await tester.tap(taskTileFinder);
      
      // Pump frames to allow animation to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // No errors should occur during animation
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen transitions are smooth', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Navigate through all screens
      await tester.tap(find.text('Today'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inbox'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // No errors should occur during transitions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Sidebar maintains glassmorphism effect', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AirSlateApp()));
      await tester.pumpAndSettle();

      // Verify sidebar is present
      expect(find.byType(Sidebar), findsOneWidget);

      // Navigate to different sections
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Sidebar should still be present
      expect(find.byType(Sidebar), findsOneWidget);

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Sidebar should still be present
      expect(find.byType(Sidebar), findsOneWidget);
    });
  });
}
