# Gingaf Developer Guide

Technical overview of the Ginga engine architecture and modular implementation.

## Setup

### 1. Flutter SDK

Install the Flutter SDK from the official website:
[https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)

### 2. Configure Platforms

```powershell
flutter config --enable-web
flutter config --enable-windows-desktop
```

### 3. Windows Native Prerequisites

Native Windows WebView support requires `nuget.exe`.

1. Download `nuget.exe` from [dist.nuget.org](https://dist.nuget.org/win-x86-commandline/latest/nuget.exe).
2. Add the directory containing `nuget.exe` to your `PATH`.
3. Configure the official package source (required for first use):

```powershell
nuget sources add -Name nuget.org -Source https://api.nuget.org/v3/index.json
```

4. Pre-install required native dependencies to bypass build-time acquisition failures:

```powershell
# Run from the project root
New-Item -ItemType Directory -Force -Path build/windows/x64/packages
nuget install Microsoft.Windows.ImplementationLibrary -Version 1.0.220914.1 -ExcludeVersion -OutputDirectory build/windows/x64/packages
nuget install Microsoft.Web.WebView2 -Version 1.0.1210.39 -ExcludeVersion -OutputDirectory build/windows/x64/packages
```

### 4. Initialize Project

```powershell
flutter create . --platforms=web,windows
flutter pub get
```

## Architecture

The engine uses a dispatcher-based architecture. `MainScreen` identifies the application type from the `APP` dart-define and routes execution to the appropriate runtime.

### Runtimes

- **NCLApp**: Processes `.ncl` documents using `NCLParser` and renders them via the internal NCL display list.
- **HTMLApp**: Executes `.html` documents within a script-enabled WebView (powered by `webview_all`).

## CCWS Service Layer

The Common Core Web Services (CCWS) layer provides DTV service state and metadata to hosted applications.

### Platform Support

- **Desktop (Windows/Linux)**: Utilizes a stateful `Router` serving via `HttpServer`. Each instance probes for available ports starting from `44642`.
- **Web (Chrome)**: Implements mock service resolution. Future implementation requires `service_worker.js` for intercepting `fetch` requests to `http://ccws.local`.

### Port Discovery Protocol

Applications resolve the CCWS endpoint by probing ports `44642` to `44662` sequentially. This ensures seamless connection to the local service without hardcoded port dependencies.

## Module Structure

### `lib/ncl-lang/`

Contains the parsing logic and domain models for NCL documents.

- `parser.dart`: Lexical analysis and tree construction.
- `ncl_document.dart`: Data structures representing NCL nodes (port, context, media).

### `lib/ginga-ccws/`

Encapsulates the CCWS service logic.

- `ccws.dart`: Main service class with managed lifecycle (`start()`, `stop()`).
- `router.dart`: Request routing and DTV service metadata.

### `lib/ginga-html/`

Implementation of the Ginga HTML runtime.

- `html_app.dart`: High-level widget managing the WebView lifecycle and content loading.

## Development Workflows

### Running CCWS Standalone

The CCWS service can be launched as a standalone Dart VM process for debugging or external tool integration:

```powershell
dart run lib/ginga-ccws/ccws.dart
```

### Extending the NCL Parser

When adding support for new NCL elements:

1. Update `lib/ncl-lang/ncl_document.dart` with the new data structures.
2. Extend the `NCLParser` class in `lib/ncl-lang/parser.dart` to handle the new XML nodes.
3. Verify the structural integrity with unit tests in `test/ncl-lang/`.

## Testing

Execute the test suite for core logic and integration:

```powershell
flutter test
```
