# Examples

All example NCL and HTML documents are stored in the `examples/` folder at the root of the workspace.

### Run Ginga-NCL or Ginga-HTML applications with UI

You may run app with UI as below.

> **Note:** It is required to create a `ginga/examples` link to `examples` to allow Flutter to find it. You can do this by running `make ginga/examples`.

```bash
cd gingaf/ginga
flutter run -d windows --dart-define="APP=examples/video.ncl"
flutter run -d windows --dart-define="APP=examples/video.html"
flutter run -d chrome --dart-define="APP=examples/video.ncl"
flutter run -d chrome --dart-define="APP=examples/video.html"
```

For easy, you can use `make run-example app=NAME` for current platform, where NAME is a file at `examples`. See below.

```bash
cd gingaf/
make run-example app=video.ncl
make run-example app=video.html
```

### Run Headless (no-UI) Ginga-NCL applications

To run headless NCL simulation:

```bash
cd gingaf/
dart ncl_doc/lib/main.dart examples/video.ncl
```

For easy, you can use `make run-example-headless`. See below.

```bash
cd gingaf/
make run-example-headless app=video.ncl
```

### Download PUC-Rio Examples

```bash
cd gingaf/
make download-puc-examples
```
