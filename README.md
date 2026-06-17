# gingaf

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

`gingaf` is an MIT-licensed, multi-platform implementation of the interactive TV middleware Ginga standardised by ITU-T and SBTVD.

For a web-based evaluation of `gingaf`, see [a  github-hosted Ginga Playground](https://alanlivio.github.io/gingaf/playground/).

The `gingaf` project structure is:

- `ginga/` - flutter-based GUI presentation player for Ginga applications. See [ginga/README.md](ginga/README.md).
- `ncl_doc/` - Dart-based headless execution engine and core NCL logic. See [ncl_doc/README.md](ncl_doc/README.md).
- `playground/` - web-based interactive playground for evaluating gingaf. See [playground/README.md](playground/README.md).
- `examples/` - collection of sample NCL and HTML documents for testing.

## local run

First see environment setup at [ginga/README.md](ginga/README.md).

To locally run Ginga-NCL or Ginga-HTML applications with GUI, do at `ginga/`:

```bash
cd gingaf/ginga
flutter run -d <chrome,windows> --dart-define="APP=<path_to_file>"
# for easy you can use make
make run-example app=video.ncl
```
