# gingaf

`gingaf` is a multi-platform implementation of the interactive TV standard Ginga done by ITU-T and SBTVD.

For a web-based evaluation of gingaf, try [Ginga Playground](https://alanlivio.github.io/gingaf/ginga-playground/).

## local run

First see environment setup and technical architecture details at [SETUP.md](SETUP.md).

To locally run Ginga-NCL or Ginga-HTML applications with GUI, do at `ginga/`:

```bash
flutter run -d <chrome,windows> --dart-define="APP=<path_to_file>"
```

To locally run Ginga-NCL application headless (no-GUI), do at `ncl_doc`:

```bash
dart ./lib/main.dart <path_to_file>
```

For instructions on running examples, see [EXAMPLES.md](EXAMPLES.md).
