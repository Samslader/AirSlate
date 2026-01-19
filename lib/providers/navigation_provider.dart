import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation sections available in the application
enum NavigationSection {
  inbox,
  today,
  notes,
}

/// State notifier for managing navigation state
class NavigationNotifier extends StateNotifier<NavigationSection> {
  NavigationNotifier() : super(NavigationSection.inbox);
  
  /// Navigate to a specific section
  void navigateTo(NavigationSection section) {
    state = section;
  }
}

/// Provider for navigation state management
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationSection>(
  (ref) => NavigationNotifier(),
);
