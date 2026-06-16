# gingaf

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

`gingaf` is an MIT-licensed, multi-platform implementation of the interactive TV middleware Ginga standardised by ITU-T and SBTVD.

For a web-based evaluation of gingaf, try [Ginga Playground](https://alanlivio.github.io/gingaf/ginga-playground/).

## local run

First see environment setup at [SETUP.md](SETUP.md).

To locally run Ginga-NCL or Ginga-HTML applications with GUI, do at `ginga/`:

```bash
flutter run -d <chrome,windows> --dart-define="APP=<path_to_file>"
```

To locally run Ginga-NCL application headless (no-GUI), do at `ncl_doc`:

```bash
dart ./lib/main.dart <path_to_file>
```

For instructions on running examples, see [EXAMPLES.md](EXAMPLES.md).
