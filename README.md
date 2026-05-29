# gingaf

Multi-platform Ginga engine implementation for Web and Desktop.

For environment setup and technical architecture details, see [SETUP.md](SETUP.md).

## Running Applications

The engine supports NCL and HTML runtimes with an integrated CCWS service layer. Use `--dart-define` to specify the application target.

### Execution Pattern

Run from the `gingaf/` subdirectory:

```powershell
flutter run -d <device> --dart-define="APP=<path_to_file>"
```

### Options

- **`APP`**: Path to the `.ncl` or `.html` file, relative to `gingaf/`.
- **`CCWS`**: Boolean flag to enable the CCWS service (defaults to `true`).

### Examples

Run all `flutter run` commands from the `gingaf/` subdirectory.

**NCL Runtime:**

```powershell
flutter run -d windows --dart-define="APP=examples/image.ncl"
```

**NCL Runtime (Lua Canvas):**

```powershell
flutter run -d windows --dart-define="APP=examples/lua_canvas.ncl"
```

**HTML Runtime (Chrome):**

```powershell
flutter run -d chrome --dart-define="APP=examples/image.html"
```

**HTML Runtime (Windows):**

```powershell
flutter run -d windows --dart-define="APP=examples/current_service.html"
```

**Headless NCL Execution (CLI):**

Run from the monorepo root:

```powershell
dart ./ncl_doc/lib/cli.dart ./examples/image.ncl
```
