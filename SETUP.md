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

### Windows

The flutter requires Microsoft.VisualStudio.2019.BuildTools. The `webview_all_windows` plugin requires **Windows SDK 10.0.22621.0** (Windows 11 SDK) or later.
Install the Windows 11 SDK via winget:

Native Windows WebView support requires `nuget.exe` and Visual Studio Build Tools with the C++ workload.

```powershell
winget install --id Microsoft.WindowsSDK.10.0.22621 --source winget
winget install --id Microsoft.VisualStudio.2019.BuildTools --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

Then, at gingaf folder, run this command:

```powershell
winget install --id NuGet.NuGet
nuget sources add -Name nuget.org -Source https://api.nuget.org/v3/index.json
New-Item -ItemType Directory -Force -Path build/windows/x64/packages
nuget install Microsoft.Windows.ImplementationLibrary -Version 1.0.220914.1 -ExcludeVersion -OutputDirectory build/windows/x64/packages
nuget install Microsoft.Web.WebView2 -Version 1.0.1210.39 -ExcludeVersion -OutputDirectory build/windows/x64/packages
```

## Testing

Execute the test suite for core logic and integration:

```bash
make test
```
