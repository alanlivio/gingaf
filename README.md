# gingaf

Multi-platform Ginga engine implementation for Web and Desktop.

For environment setup and technical architecture details, see [SETUP.md](SETUP.md).

## Running Applications

The engine supports NCL and HTML runtimes with an integrated CCWS service layer. Use `--dart-define` to specify the application target.

### Execution Pattern

```powershell
flutter run -d <device> --dart-define="APP=<path_to_file>"
```

### Options

- **`APP`**: Path to the `.ncl` or `.html` file.
- **`CCWS`**: Boolean flag to enable the CCWS service (defaults to `true`).

### Examples

**NCL Runtime:**

```powershell
flutter run -d windows --dart-define="APP=examples/image.ncl"
```

**HTML Runtime (Chrome):**

```powershell
flutter run -d chrome --dart-define="APP=examples/image.html"
```

**HTML Runtime (Windows):**

```powershell
flutter run -d windows --dart-define="APP=examples/current_service.html"
```

**Headless NCL Validation (CLI):**

```powershell
dart ./ncl_vm/lib/main.dart ./gingaf/examples/image.ncl
```
