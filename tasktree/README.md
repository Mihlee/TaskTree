# 🌳 TaskTree Board

An interactive, gamified task management desktop and mobile application built with Flutter. **TaskTree Board** bridges daily productivity with visual progress tracking: as you check off your tasks each day, your workspace grows a virtual forest.

---

## 📋 Table of Contents

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

## ✨ Features

- 📅 **Interactive Calendar:** Daily task mapping and date switching using `table_calendar`.
- 🌲 **Visual Forest Gamification:** Real-time tree growth indicators and streak counter. Completing 100% of a day's tasks triggers a celebration dialog and plants a permanent tree in your forest grid.
- ⚡ **Full Task CRUD:** Add, edit, check off, and swipe-to-delete tasks with rich attributes (titles, detailed notes, categories, priority levels).
- 🔍 **Search & Quick Filters:** Live text search across titles/descriptions combined with category chip filtering.
- 🏷️ **Custom Category Creation:** Dynamically create custom categories on the fly.
- 💾 **Local Data Persistence:** Automatic JSON serialization saved to local storage via `shared_preferences`.
- 📦 **Export & Import Backup:** One-click JSON backup export to clipboard and instant restore functionality.
- 🌓 **Adaptive Theme & Layout:** Toggle between Dark and Light modes with responsive side-by-side desktop layout and mobile stacking.

---

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (v3.0.0+) |
| **Language** | Dart |
| **State Management** | Native `StatefulWidget` & lifting state |
| **Storage** | `shared_preferences` |
| **Calendar** | `table_calendar` |
| **System Utilities** | `flutter/services.dart` (Clipboard integration) |

---

## 🚀 Getting Started

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
