# HealthMate - Fitness Tracker App

![WIP](https://img.shields.io/badge/Status-Work%20In%20Progress-yellow)

A mobile fitness and health tracking application built with Flutter. This app allows users to monitor their daily activity, including steps, calories burned, and water intake. All data is stored locally on the device using an `sqflite` database.

This project is currently in development as part of a university assignment.

## 📱 Screenshots

*Screenshots will be updated as development progresses.*

| Home Page | Record History |
| :---: | :---: |
| <img src="URL_TO_YOUR_HOME_SCREENSHOT" width="300"> | <img src="URL_TO_YOUR_SEARCH_SCREENSHOT" width="300"> |

*(To add images: Upload them to your GitHub repo and replace the `URL_TO_YOUR...` text with the image link.)*

## ✨ Features

- **Track Daily Metrics:** Log steps, calories burned, and water intake (in ml).
- **Local Database:** All data is stored locally on the device using `sqflite`.
- **Full CRUD Operations:** Complete functionality to Create, Read, Update, and Delete health records.
- **Record History:** A "Record History" page to view all past entries.
- **Search & Filter:** Search for specific records by date.
- **Edit & Delete:** Easily edit or delete any past record from the history page.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** [Dart](https://dart.dev/)
- **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
- **Date Formatting:** [intl](https://pub.dev/packages/intl)
- **Database Path:** [path](https://pub.dev/packages/path)

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git)
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd YOUR_REPOSITORY
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## ⚠️ Project Status

This project is **currently in development**. The core functionality (CRUD operations for health records) is complete and functional on mobile (Android/iOS) virtual devices.

### Future Plans

- [ ] Finalize the "Saved" page functionality.
- [ ] Complete the "Settings" page UI and logic.
- [ ] Add data visualization (charts/graphs) to the Home Page.

---