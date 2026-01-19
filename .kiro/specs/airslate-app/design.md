# Design Document: AirSlate Desktop Application

## Overview

AirSlate is a Flutter-based desktop application that combines task management and note-taking with a premium iOS/iPadOS-inspired interface. The application uses Cupertino design patterns, glassmorphism effects, and smooth animations to create a polished user experience on Windows and macOS platforms.

The architecture follows clean architecture principles with clear separation between UI, business logic, and data layers. State management is handled through Riverpod, providing reactive updates across the application. Local data persistence uses Isar for fast, efficient NoSQL storage.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Widgets    │  │  Animations  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Business Logic Layer                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Providers  │  │  Notifiers   │  │   Services   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    Models    │  │ Repositories │  │  Isar DB     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Framework**: Flutter 3.x (Desktop target)
- **Language**: Dart 3.x
- **State Management**: Riverpod 2.x
- **Database**: Isar 3.x (NoSQL local database)
- **Window Management**: window_manager package
- **UI Design**: Cupertino widgets + custom glassmorphism components

### Project Structure

```
lib/
├── main.dart                          # Application entry point
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_dimensions.dart       # Spacing, sizes
│   │   └── app_text_styles.dart      # Typography
│   ├── theme/
│   │   └── app_theme.dart            # Cupertino theme configuration
│   └── utils/
│       └── window_setup.dart         # Window initialization
├── data/
│   ├── models/
│   │   ├── task.dart                 # Task data model
│   │   └── note.dart                 # Note data model
│   ├── repositories/
│   │   ├── task_repository.dart      # Task data operations
│   │   └── note_repository.dart      # Note data operations
│   └── database/
│       └── isar_service.dart         # Isar database setup
├── providers/
│   ├── task_provider.dart            # Task state management
│   ├── note_provider.dart            # Note state management
│   └── navigation_provider.dart      # Navigation state
└── ui/
    ├── screens/
    │   ├── main_screen.dart          # Main layout with sidebar
    │   ├── inbox_screen.dart         # Inbox task view
    │   ├── today_screen.dart         # Today's tasks view
    │   └── notes_screen.dart         # Notes list/editor view
    ├── widgets/
    │   ├── title_bar.dart            # Custom window title bar
    │   ├── sidebar.dart              # Navigation sidebar
    │   ├── task_tile.dart            # Task list item
    │   ├── task_input.dart           # New task input field
    │   ├── note_card.dart            # Note preview card
    │   └── glass_container.dart      # Reusable glassmorphism container
    └── animations/
        └── checkbox_animation.dart    # Animated checkbox widget
```

## Components and Interfaces

### 1. Window Management

**WindowSetup Service**
```dart
class WindowSetup {
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
```

**TitleBar Widget**
- Provides draggable area using `GestureDetector` with `windowManager.startDragging()`
- Displays macOS-style window controls (close, minimize, maximize) on the left
- Uses glassmorphism effect with `BackdropFilter`
- Height: 52px

### 2. Navigation System

**NavigationProvider**
```dart
enum NavigationSection { inbox, today, notes }

class NavigationNotifier extends StateNotifier<NavigationSection> {
  NavigationNotifier() : super(NavigationSection.inbox);
  
  void navigateTo(NavigationSection section) {
    state = section;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationSection>(
  (ref) => NavigationNotifier(),
);
```

**Sidebar Widget**
- Fixed width: 250px
- Glassmorphism background using `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`
- Navigation items: Inbox, Today, Notes
- Active item highlighted with subtle background color
- Uses `CupertinoListTile` or custom widget for items

### 3. Task Management

**Task Model**
```dart
@collection
class Task {
  Id id = Isar.autoIncrement;
  
  late String title;
  late bool isCompleted;
  late DateTime createdAt;
  DateTime? completedAt;
  
  Task({
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
```

**TaskRepository**
```dart
class TaskRepository {
  final Isar isar;
  
  TaskRepository(this.isar);
  
  // Create
  Future<void> addTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }
  
  // Read
  Stream<List<Task>> watchAllTasks() {
    return isar.tasks.where().watch(fireImmediately: true);
  }
  
  Future<List<Task>> getTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return await isar.tasks
        .filter()
        .createdAtGreaterThan(startOfDay)
        .findAll();
  }
  
  // Update
  Future<void> toggleTaskCompletion(int taskId) async {
    await isar.writeTxn(() async {
      final task = await isar.tasks.get(taskId);
      if (task != null) {
        task.isCompleted = !task.isCompleted;
        task.completedAt = task.isCompleted ? DateTime.now() : null;
        await isar.tasks.put(task);
      }
    });
  }
  
  // Delete
  Future<void> deleteTask(int taskId) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(taskId);
    });
  }
}
```

**TaskProvider**
```dart
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return TaskRepository(isar);
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTodayTasks();
});
```

**TaskTile Widget**
- Displays circular checkbox with smooth fill animation
- Shows task title with optional strikethrough when completed
- Uses `AnimatedContainer` for checkbox animation
- Uses `AnimatedDefaultTextStyle` for text strikethrough animation
- Tap on checkbox toggles completion status
- Animation duration: 300ms with `Curves.easeInOut`

**TaskInput Widget**
- `CupertinoTextField` with placeholder "New task..."
- Positioned at bottom of task list
- On submit (Enter key):
  - Validates input is not empty or whitespace-only
  - Creates new task via provider
  - Clears input field
  - Maintains focus for next entry

### 4. Notes System

**Note Model**
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;
  
  late String content;
  late DateTime createdAt;
  late DateTime lastModifiedAt;
  
  Note({
    required this.content,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastModifiedAt = lastModifiedAt ?? DateTime.now();
  
  String get preview {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}
```

**NoteRepository**
```dart
class NoteRepository {
  final Isar isar;
  
  NoteRepository(this.isar);
  
  Future<void> addNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }
  
  Stream<List<Note>> watchAllNotes() {
    return isar.notes
        .where()
        .sortByLastModifiedAtDesc()
        .watch(fireImmediately: true);
  }
  
  Future<void> updateNote(Note note) async {
    note.lastModifiedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }
  
  Future<void> deleteNote(int noteId) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(noteId);
    });
  }
}
```

**NotesScreen**
- List view mode: Displays note cards with preview text
- Editor mode: Full-screen `CupertinoTextField` with `maxLines: null`
- Auto-save: Debounced save (500ms delay) after user stops typing
- Back button returns to list view

### 5. Visual Design Implementation

**GlassContainer Widget**
```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  
  const GlassContainer({
    required this.child,
    this.borderRadius = 16.0,
    this.blurSigma = 10.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withOpacity(0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: CupertinoColors.separator.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

**Design Constants**
```dart
class AppDimensions {
  static const double sidebarWidth = 250.0;
  static const double titleBarHeight = 52.0;
  static const double borderRadiusSmall = 16.0;
  static const double borderRadiusMedium = 20.0;
  static const double borderRadiusLarge = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
}

class AppColors {
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC2C2C2E);
}
```

## Data Models

### Task Entity

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | Id (int) | Auto-increment primary key | Unique, auto-generated |
| title | String | Task description | Non-empty, max 500 chars |
| isCompleted | bool | Completion status | Default: false |
| createdAt | DateTime | Creation timestamp | Auto-set on creation |
| completedAt | DateTime? | Completion timestamp | Nullable, set when completed |

### Note Entity

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | Id (int) | Auto-increment primary key | Unique, auto-generated |
| content | String | Note text content | Can be empty, max 10000 chars |
| createdAt | DateTime | Creation timestamp | Auto-set on creation |
| lastModifiedAt | DateTime | Last edit timestamp | Updated on every change |

### Validation Rules

**Task Validation**
- Title must not be empty string
- Title must not be only whitespace characters
- Title length must be between 1 and 500 characters

**Note Validation**
- Content can be empty (for new notes)
- Content length must not exceed 10000 characters
- Auto-save only triggers if content has changed

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Task Creation Persistence

*For any* valid task title (non-empty, non-whitespace), when a task is created and added to the database, retrieving all tasks should include a task with that exact title.

**Validates: Requirements 4.1, 4.7**

### Property 2: Empty Task Rejection

*For any* string composed entirely of whitespace characters (spaces, tabs, newlines), attempting to create a task with that string should be rejected, and the task list length should remain unchanged.

**Validates: Requirements 4.2**

### Property 3: Task Completion Toggle

*For any* task in the database, toggling its completion status twice should return it to its original completion state.

**Validates: Requirements 4.4**

### Property 4: Task Persistence Round Trip

*For any* valid task, after saving it to the database and then loading all tasks, the loaded list should contain a task with identical title, completion status, and creation timestamp (within 1 second tolerance).

**Validates: Requirements 4.7, 4.8, 6.2, 6.4**

### Property 5: Note Auto-Save Persistence

*For any* note content string, after creating a note with that content and retrieving it from the database, the retrieved note's content should match the original content exactly.

**Validates: Requirements 5.4, 6.3**

### Property 6: Note Modification Timestamp Update

*For any* existing note, when its content is modified and saved, the lastModifiedAt timestamp should be greater than the original lastModifiedAt timestamp.

**Validates: Requirements 5.4, 6.6**

### Property 7: Database Load on Startup

*For any* set of tasks and notes in the database, when the application launches and loads data, the number of loaded tasks should equal the number of tasks in the database, and the number of loaded notes should equal the number of notes in the database.

**Validates: Requirements 4.8, 6.4**

### Property 8: Navigation State Consistency

*For any* navigation section (Inbox, Today, Notes), after navigating to that section, the active navigation state should reflect the selected section.

**Validates: Requirements 3.3, 3.4**

### Property 9: Today Tasks Filtering

*For any* task created today, querying for today's tasks should include that task in the results.

**Validates: Requirements 4.8** (implicit requirement for "Today" section)

### Property 10: Task Deletion Removes from Database

*For any* task in the database, after deleting that task, querying all tasks should not include a task with that ID.

**Validates: Requirements 6.2** (implicit delete operation)

## Error Handling

### Database Errors
- **Connection Failure**: Log error and show user-friendly message "Unable to access local storage"
- **Write Failure**: Retry once, then notify user "Failed to save changes"
- **Corruption**: Attempt recovery, fallback to empty database with user notification

### Input Validation Errors
- **Empty Task**: Silent rejection, maintain focus on input field
- **Oversized Content**: Show warning when approaching limit, prevent input beyond limit
- **Invalid Characters**: Allow all Unicode characters, sanitize for display

### Window Management Errors
- **Initialization Failure**: Fall back to standard window with title bar
- **Platform Unsupported**: Show error message and exit gracefully

### State Management Errors
- **Provider Disposal**: Ensure proper cleanup to prevent memory leaks
- **Concurrent Modifications**: Use Isar transactions to ensure data consistency

## Testing Strategy

### Unit Tests

Unit tests will verify specific examples, edge cases, and error conditions:

- **Task Validation**: Test empty strings, whitespace-only strings, valid strings, boundary lengths
- **Note Preview**: Test short content, long content, empty content
- **Date Filtering**: Test tasks from today, yesterday, future dates
- **Repository Methods**: Test CRUD operations with specific data examples
- **Widget Rendering**: Test that widgets display correct data for specific inputs

### Property-Based Tests

Property-based tests will verify universal properties across all inputs using the **test** package with custom property testing utilities (or a Dart property testing library if available):

- **Minimum 100 iterations per property test** to ensure comprehensive coverage
- Each test tagged with format: **Feature: airslate-app, Property {number}: {property_text}**
- Tests will generate random valid inputs (task titles, note content, timestamps)
- Tests will verify properties hold for all generated inputs

**Property Test Configuration**:
```dart
// Example property test structure
void main() {
  group('Task Management Properties', () {
    test('Property 1: Task Creation Persistence', () {
      // Feature: airslate-app, Property 1: Task Creation Persistence
      for (int i = 0; i < 100; i++) {
        final randomTitle = generateRandomTaskTitle();
        // Test property holds
      }
    });
  });
}
```

### Integration Tests

- **End-to-End Flows**: Test complete user journeys (create task → complete → verify persistence)
- **Navigation**: Test switching between sections and state preservation
- **Database Integration**: Test actual Isar database operations with test database

### Testing Balance

- Property tests handle comprehensive input coverage through randomization
- Unit tests focus on specific examples that demonstrate correct behavior
- Integration tests verify components work together correctly
- Both unit and property tests are necessary for complete coverage

## Dependencies

### Required Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.0
  
  # Window Management
  window_manager: ^0.3.7
  
  # UI
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  isar_generator: ^3.1.0
  build_runner: ^2.4.0
  
  # Linting
  flutter_lints: ^3.0.0
```

## Implementation Notes

### Initialization Sequence

1. Initialize Isar database
2. Setup window manager (frameless, size, position)
3. Load initial data from database
4. Initialize Riverpod providers
5. Render main UI

### Performance Considerations

- Use `StreamProvider` for reactive database updates (Isar watches)
- Implement debouncing for note auto-save (500ms)
- Use `const` constructors where possible
- Lazy-load note content in list view (show preview only)
- Limit animation complexity to maintain 60fps

### Platform-Specific Considerations

- **macOS**: Window controls on left, use native blur effects
- **Windows**: Window controls on right (adjust TitleBar), use custom blur implementation
- Test on both platforms for visual consistency

### Accessibility

- Ensure sufficient color contrast for text
- Support keyboard navigation (Tab, Enter, Escape)
- Provide semantic labels for screen readers
- Support system font scaling
