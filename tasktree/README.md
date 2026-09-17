#  TaskTree Board

An interactive, gamified task management desktop and mobile application built with Flutter. **TaskTree Board** bridges daily productivity with visual progress tracking: as you check off your tasks each day, your workspace grows a virtual forest.

---

##  Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [How to Use the App](#-how-to-use-the-app)
- [Project Architecture](#-project-architecture)
- [Data Persistence & Backup](#-data-persistence--backup)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

##  Features

- 📅 **Interactive Calendar:** Daily task mapping and date switching using `table_calendar`.
-  **Visual Forest Gamification:** Real-time tree growth indicators and streak counter. Completing 100% of a day's tasks triggers a celebration dialog and plants a permanent tree in your forest grid.
-  **Full Task CRUD:** Add, edit, check off, and swipe-to-delete tasks with rich attributes (titles, detailed notes, categories, priority levels).
-  **Search & Quick Filters:** Live text search across titles/descriptions combined with category chip filtering.
-  **Custom Category Creation:** Dynamically create custom categories on the fly.
-  **Local Data Persistence:** Automatic JSON serialization saved to local storage via `shared_preferences`.
-  **Export & Import Backup:** One-click JSON backup export to clipboard and instant restore functionality.
-  **Adaptive Theme & Layout:** Toggle between Dark and Light modes with responsive side-by-side desktop layout and mobile stacking.

---

##  Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (v3.0.0+) |
| **Language** | Dart |
| **State Management** | Native `StatefulWidget` & lifting state |
| **Storage** | `shared_preferences` |
| **Calendar** | `table_calendar` |
| **System Utilities** | `flutter/services.dart` (Clipboard integration) |

---

##  Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (`v3.0.0` or higher)
2. [Dart SDK](https://dart.dev/get-dart)
3. An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) with Flutter extensions.

Verify your environment by running:
```bash
flutter --version

```
### Installation

1. **Clone the repository**

   - [git clone](https://github.com/your-username/tasktree-board.git)(https://github.com/your-username/tasktree-board.git)

   - cd tasktree-board

2. **Install dependencies:**

   - flutter pub get

### How to Run the App:

`Run on default connected device`

- flutter run

 ` Run on Web (Chrome)`

- flutter run -d chrome

 `Run on macOS Desktop`

- flutter run -d macos 


---

### How to Use the App
1. **Managing Tasks**

- Select a day on the calendar to view or manage tasks for that specific date.

- Click + Add Task to open the task creator modal.

- Swipe left on any task card to delete it.

- Tap any task card to edit its title, notes, priority, or category.

2. **Growing Your Forest**

- Each task you check off increases your daily completion percentage bar.

- Completing 100% of tasks for a date completes that day's tree.

- Navigate to the Forest & Stats tab at the bottom to view your total grown trees, overall success percentage, and complete forest log.

3. **Backing Up & Restoring Data**
- Go to the Forest & Stats tab and tap the Backup & Restore icon in the top app bar.

- Tap Export Backup JSON to copy your complete workspace database string to your clipboard.

- To restore on another device or browser, paste your raw JSON string into the restore input field and tap Restore Data.

## 📂 Project Architecture

lib/
├── main.dart                 `Application entry point &theme configuration`
├── models/
│   └── task.dart              `Task model & JSON serialization logic`
├── services/
│   └── storage_service.dart   `SharedPreferences manager`
├── views/
│   ├── main_navigation.dart   `Tab navigation controller`
│   ├── task_workspace.dart    `Calendar, search, and task board view`
│   └── forest_analytics.dart  `Forest grid and productivity statistics`
└── widgets/
    ├── task_card.dart         `Dismissible task tile`
    ├── backup_dialog.dart     `JSON export/import modal`
    └── tree_progress.dart     `Dynamic tree growth indicator bar`
    
   ## Data Persistence & Backup
All data is stored key-value style locally on your device:

Tasks Key: tasktree_tasks (Map of date strings to serialized Task JSON lists)

Categories Key: tasktree_categories (List of user-defined string category tags)
## Troubleshooting
Issue: Tasks disappear when restarting the app on Web.

Fix: Ensure persistent storage is enabled in your web browser settings. Clearing browser cache/cookies will wipe local shared_preferences. Use the JSON Export tool prior to clearing cache.

Issue: Package import errors after pulling new code.

Fix: Run flutter pub clean && flutter pub get in your root directory.

##  License
This project is licensed under the MIT License - see the LICENSE file for details.

