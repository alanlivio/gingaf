# gingaf setup

Technical overview of the Ginga engine architecture and modular implementation.

## Setup

### Flutter SDK

Install the Flutter SDK from the official website:
[https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)

### Configure Platforms

```powershell
flutter config --enable-web
flutter config --enable-windows-desktop
```

### Windows WebView

Native Windows WebView support requires `nuget.exe` and Microsoft.VisualStudio.BuildTools

```powershell
winget install Microsoft.VisualStudio.BuildTools
winget install nuget
```

Run from the project root

```powershell
nuget sources add -Name nuget.org -Source https://api.nuget.org/v3/index.json
New-Item -ItemType Directory -Force -Path build/windows/x64/packages
nuget install Microsoft.Windows.ImplementationLibrary -Version 1.0.220914.1 -ExcludeVersion -OutputDirectory build/windows/x64/packages
nuget install Microsoft.Web.WebView2 -Version 1.0.1210.39 -ExcludeVersion -OutputDirectory build/windows/x64/packages
```

## Testing

Execute the test suite for core logic and integration:

```powershell
flutter test
```
