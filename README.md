# Alisbae

A Flutter-based mobile book reader that lets you search, download, and read PDF books from [OceanOfPDFs](https://oceanofpdf.com) — all stored locally on your device.

---

## Features

- **Book Search** — Search millions of books by title or author in real time.
- **PDF Download** — Download books as PDFs directly to your device.
- **Built-in PDF Viewer** — Read downloaded books without leaving the app (powered by Syncfusion).
- **Reading Progress** — Automatically tracks the last page you read for every book.
- **Favourites** — Mark books as favourites for quick access.
- **Ratings & Reviews** — Rate and write a personal review for each book.
- **Light & Dark Theme** — Full dark-mode support with a teal-accented light theme.
- **Offline Library** — Your downloaded books are always available, even without an internet connection.

---

## Architecture

The project follows a clean, layered architecture with explicit dependency injection via a `CompositionRoot`:

```
lib/
├── composition_root.dart   # Wires up all dependencies at startup
├── main.dart               # Entry point
├── data/                   # Local database (SQLite via sqflite)
│   ├── datasource/         # Abstract contract + sqflite implementation
│   └── factory/            # Database factory
├── model/                  # Domain models (BookStore, SearchResult, …)
├── service/
│   ├── ocean_of_pdfs/      # Web crawler for OceanOfPDFs search & download
│   └── image_saver/        # Saves book cover images locally
├── state_management/       # BLoC / Cubit state management
│   ├── book/
│   ├── book_details/
│   ├── book_download/
│   └── home/
├── ui/page/                # Flutter UI pages
│   ├── home/               # Search & local library grid
│   ├── book_details/       # Book info, download & open
│   └── book_viewer/        # In-app PDF reader
└── viewmodel/              # View-model layer bridging service ↔ UI
```

---

## Tech Stack

| Layer | Library |
|---|---|
| UI framework | [Flutter](https://flutter.dev) |
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) / [bloc](https://pub.dev/packages/bloc) |
| Local database | [sqflite](https://pub.dev/packages/sqflite) |
| HTTP client | [Dio](https://pub.dev/packages/dio) + cookie support |
| PDF viewer | [syncfusion_flutter_pdfviewer](https://pub.dev/packages/syncfusion_flutter_pdfviewer) |
| In-app WebView | [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) |
| Permissions | [permission_handler](https://pub.dev/packages/permission_handler) |
| Ratings | [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar) |
| Toasts | [fluttertoast](https://pub.dev/packages/fluttertoast) |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.12.0
- Dart SDK ^3.12.0-198.0.dev (bundled with Flutter)
- Android Studio / Xcode (for device/emulator targets)

### Running the app

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Building a release APK

```bash
flutter build apk --release
```

---

## Supported Platforms

| Platform | Status |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Linux | ✅ |

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes and open a pull request.

All contributions are welcome!
