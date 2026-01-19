# Implementation Plan: AirSlate Desktop Application

## Overview

This implementation plan breaks down the AirSlate desktop application into discrete, incremental tasks. Each task builds on previous work, ensuring continuous integration and validation. The plan follows a bottom-up approach: core infrastructure → data layer → business logic → UI components → integration.

## Tasks

- [x] 1. Setup project dependencies and core infrastructure
  - Add all required packages to `pubspec.yaml` (riverpod, isar, window_manager, path_provider)
  - Run `flutter pub get` to install dependencies
  - Create core constants files: `app_colors.dart`, `app_dimensions.dart`, `app_text_styles.dart`
  - _Requirements: 2.2, 2.3, 2.4_

- [x] 2. Implement data models and database setup
  - [x] 2.1 Create Task model with Isar annotations
    - Define `Task` class with id, title, isCompleted, createdAt, completedAt fields
    - Add Isar collection annotation and field annotations
    - _Requirements: 4.3, 4.7, 6.5_

  - [x] 2.2 Create Note model with Isar annotations
    - Define `Note` class with id, content, createdAt, lastModifiedAt fields
    - Add preview getter method
    - Add Isar collection annotation
    - _Requirements: 5.3, 5.5, 6.6_

  - [x] 2.3 Setup Isar database service
    - Create `IsarService` class to initialize and provide Isar instance
    - Configure Isar with Task and Note schemas
    - Use `path_provider` to get application documents directory
    - _Requirements: 6.1, 6.4_

  - [x] 2.4 Run Isar code generation
    - Execute `dart run build_runner build` to generate Isar files
    - Verify generated files are created correctly

- [x] 3. Implement repository layer
  - [x] 3.1 Create TaskRepository
    - Implement `addTask()` method with transaction
    - Implement `watchAllTasks()` stream method
    - Implement `getTodayTasks()` query method
    - Implement `toggleTaskCompletion()` method
    - Implement `deleteTask()` method
    - _Requirements: 4.1, 4.4, 4.7, 4.8, 6.2_

  - [ ]* 3.2 Write property test for TaskRepository
    - **Property 1: Task Creation Persistence**
    - **Property 4: Task Persistence Round Trip**
    - Generate random task titles and verify persistence
    - _Requirements: 4.1, 4.7, 4.8, 6.2, 6.4_

  - [x] 3.3 Create NoteRepository
    - Implement `addNote()` method with transaction
    - Implement `watchAllNotes()` stream method with sorting
    - Implement `updateNote()` method with timestamp update
    - Implement `deleteNote()` method
    - _Requirements: 5.1, 5.4, 6.3_

  - [ ]* 3.4 Write property test for NoteRepository
    - **Property 5: Note Auto-Save Persistence**
    - **Property 6: Note Modification Timestamp Update**
    - Generate random note content and verify persistence and timestamps
    - _Requirements: 5.4, 6.3, 6.6_

- [x] 4. Implement state management with Riverpod
  - [x] 4.1 Create navigation provider
    - Define `NavigationSection` enum (inbox, today, notes)
    - Create `NavigationNotifier` StateNotifier
    - Create `navigationProvider`
    - _Requirements: 3.3, 3.4, 8.1, 8.2_

  - [ ]* 4.2 Write property test for navigation state
    - **Property 8: Navigation State Consistency**
    - Test navigation to all sections maintains correct state
    - _Requirements: 3.3, 3.4_

  - [x] 4.3 Create task providers
    - Create `taskRepositoryProvider`
    - Create `allTasksProvider` as StreamProvider
    - Create `todayTasksProvider` as FutureProvider
    - _Requirements: 4.8, 8.1, 8.2, 8.4_

  - [x] 4.4 Create note providers
    - Create `noteRepositoryProvider`
    - Create `allNotesProvider` as StreamProvider
    - _Requirements: 5.1, 8.1, 8.2, 8.4_

- [x] 5. Implement window management
  - [x] 5.1 Create WindowSetup utility
    - Implement `initialize()` method with window_manager configuration
    - Set window size to 1000x700, minimum size 800x600
    - Configure titleBarStyle as hidden
    - Set window to center and show on startup
    - _Requirements: 1.1, 1.5_

  - [x] 5.2 Create TitleBar widget
    - Implement draggable area using GestureDetector with `windowManager.startDragging()`
    - Add window control buttons (close, minimize, maximize) on left side
    - Apply glassmorphism effect with BackdropFilter
    - Set height to 52px
    - _Requirements: 1.2, 1.3, 1.4, 1.6, 2.1_

  - [ ]* 5.3 Write unit tests for TitleBar
    - Test widget renders with correct height
    - Test window control buttons are present
    - _Requirements: 1.2, 1.3_

- [x] 6. Implement reusable UI components
  - [x] 6.1 Create GlassContainer widget
    - Implement with BackdropFilter using ImageFilter.blur
    - Add configurable borderRadius and blurSigma parameters
    - Apply semi-transparent background with border
    - _Requirements: 2.1, 2.2_

  - [x] 6.2 Create CheckboxAnimation widget
    - Implement animated circular checkbox with fill animation
    - Use AnimatedContainer for smooth transitions
    - Duration: 300ms with Curves.easeInOut
    - _Requirements: 4.4, 7.1_

  - [ ]* 6.3 Write unit tests for GlassContainer
    - Test widget renders with correct border radius
    - Test blur effect is applied
    - _Requirements: 2.1, 2.2_

- [x] 7. Implement task management UI
  - [x] 7.1 Create TaskTile widget
    - Display CheckboxAnimation and task title
    - Implement tap handler to toggle completion via provider
    - Apply strikethrough animation when completed using AnimatedDefaultTextStyle
    - _Requirements: 4.3, 4.4, 4.5, 7.1, 7.2_

  - [x] 7.2 Create TaskInput widget
    - Implement CupertinoTextField with "New task..." placeholder
    - Add input validation (reject empty/whitespace-only)
    - On submit: create task via provider, clear field, maintain focus
    - _Requirements: 4.1, 4.2, 4.6_

  - [ ]* 7.3 Write property test for task input validation
    - **Property 2: Empty Task Rejection**
    - Generate random whitespace strings and verify rejection
    - _Requirements: 4.2_

  - [ ]* 7.4 Write property test for task completion toggle
    - **Property 3: Task Completion Toggle**
    - Test toggling twice returns to original state
    - _Requirements: 4.4_

- [x] 8. Implement notes UI
  - [x] 8.1 Create NoteCard widget
    - Display note preview text (first 100 characters)
    - Show last modified timestamp
    - Add tap handler to open note editor
    - Apply glassmorphism styling
    - _Requirements: 5.1, 5.5, 5.6_

  - [x] 8.2 Create NoteEditor widget
    - Implement CupertinoTextField with maxLines: null
    - Add debounced auto-save (500ms delay)
    - Implement back button to return to list
    - _Requirements: 5.2, 5.3, 5.4_

  - [ ]* 8.3 Write unit tests for NoteCard
    - Test preview truncation for long content
    - Test timestamp display
    - _Requirements: 5.5_

- [x] 9. Implement navigation sidebar
  - [x] 9.1 Create Sidebar widget
    - Set fixed width to 250px
    - Apply GlassContainer for glassmorphism effect
    - Create navigation items for Inbox, Today, Notes
    - Highlight active item based on navigationProvider
    - Add tap handlers to update navigationProvider
    - _Requirements: 2.1, 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 9.2 Write unit tests for Sidebar
    - Test sidebar renders with correct width
    - Test all navigation items are present
    - _Requirements: 3.1, 3.2_

- [x] 10. Implement main screens
  - [x] 10.1 Create InboxScreen
    - Display all tasks using allTasksProvider
    - Render TaskTile for each task
    - Add TaskInput at bottom
    - Apply bouncing scroll physics
    - _Requirements: 2.5, 4.1, 4.6, 4.8_

  - [x] 10.2 Create TodayScreen
    - Display today's tasks using todayTasksProvider
    - Render TaskTile for each task
    - Add TaskInput at bottom
    - Apply bouncing scroll physics
    - _Requirements: 2.5, 4.8_

  - [ ]* 10.3 Write property test for today tasks filtering
    - **Property 9: Today Tasks Filtering**
    - Create tasks with various dates and verify today filter
    - _Requirements: 4.8_

  - [x] 10.4 Create NotesScreen
    - Display notes list using allNotesProvider
    - Render NoteCard for each note
    - Add floating action button to create new note
    - Implement navigation to NoteEditor
    - _Requirements: 5.1, 5.2, 5.6_

- [x] 11. Implement main application layout
  - [x] 11.1 Create MainScreen widget
    - Use Row layout with Sidebar (250px) and Content_Area (flexible)
    - Add TitleBar at top
    - Switch content based on navigationProvider (Inbox, Today, Notes)
    - Apply soft background color to Content_Area
    - _Requirements: 2.6, 3.3_

  - [x] 11.2 Update main.dart
    - Initialize window manager using WindowSetup
    - Initialize Isar database
    - Wrap app with ProviderScope
    - Use CupertinoApp with MainScreen as home
    - Configure theme with SF Pro Display font
    - _Requirements: 1.1, 1.5, 2.3, 6.4, 8.1_

- [ ] 12. Checkpoint - Ensure all tests pass
  - Run all unit tests and property tests
  - Verify application launches without errors
  - Test basic functionality: create task, complete task, create note
  - Ask the user if questions arise

- [ ] 13. Implement animations and polish
  - [ ] 13.1 Add content transition animations
    - Implement AnimatedSwitcher for screen transitions
    - Use fade and scale animations for UI elements
    - _Requirements: 7.3, 7.5_

  - [ ] 13.2 Refine animation curves
    - Apply spring-based curves (Curves.easeInOutCubic, Curves.elasticOut)
    - Ensure all animations are smooth and consistent
    - _Requirements: 7.4_

  - [ ]* 13.3 Write unit tests for animations
    - Test animation durations and curves
    - Verify animations complete correctly

- [ ] 14. Implement additional features and error handling
  - [ ] 14.1 Add task deletion functionality
    - Add swipe-to-delete gesture on TaskTile
    - Implement delete confirmation dialog
    - Call repository deleteTask method
    - _Requirements: 6.2_

  - [ ]* 14.2 Write property test for task deletion
    - **Property 10: Task Deletion Removes from Database**
    - Verify deleted tasks don't appear in queries
    - _Requirements: 6.2_

  - [ ] 14.3 Add note deletion functionality
    - Add delete button in NoteEditor
    - Implement delete confirmation dialog
    - Call repository deleteNote method
    - _Requirements: 6.3_

  - [ ] 14.4 Implement error handling
    - Add try-catch blocks for database operations
    - Show user-friendly error messages using CupertinoAlertDialog
    - Log errors for debugging
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 15. Final testing and validation
  - [ ]* 15.1 Write property test for database load on startup
    - **Property 7: Database Load on Startup**
    - Create tasks and notes, restart app simulation, verify all loaded
    - _Requirements: 4.8, 6.4_

  - [ ]* 15.2 Run comprehensive property test suite
    - Execute all property tests with 100+ iterations each
    - Verify all properties pass consistently

  - [ ] 15.3 Perform integration testing
    - Test complete user flows: create → edit → delete
    - Test navigation between all sections
    - Test data persistence across app restarts
    - Verify animations and UI polish

  - [ ] 15.4 Platform-specific testing
    - Test on Windows: verify window controls, blur effects
    - Test on macOS: verify window controls position, native blur
    - Ensure visual consistency across platforms

- [ ] 16. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties with 100+ iterations
- Unit tests validate specific examples and edge cases
- Build incrementally: each task should result in working, integrated code
- Run `dart run build_runner build` after creating/modifying Isar models
