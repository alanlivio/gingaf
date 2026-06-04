# Examples

All example NCL and HTML documents are stored in the `examples/` folder at the root of the workspace.

### Run Ginga-NCL or Ginga-HTML applications with GUI

You may run app with GUI. See below.

```bash
flutter run -d windows --dart-define="APP=examples/video.ncl"
flutter run -d windows --dart-define="APP=examples/video.html"
flutter run -d chrome --dart-define="APP=examples/video.ncl"
flutter run -d chrome --dart-define="APP=examples/video.html"
```

For easy, you can use `make run-example app=NAME` for current platform, where NAME is a file at `examples`. See below.

```bash
make run-example app=video.ncl
make run-example app=video.html
```

### Run Headless (no-GUI) Ginga-NCL applications

To run headless NCL simulation:

```bash
dart ./ncl_doc/lib/cli.dart ./examples/video.ncl
```

For easy, you can use `make run-example-headless`. See below.

```bash
make run-example-headless app=video.ncl
```

### Download PUC-Rio Examples

```bash
make download-puc-examples
```
