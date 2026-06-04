# gingaf

`gingaf` is a multi-platform implementation of the interactive TV standard Ginga done by ITU-T and SBTVD.

To run Ginga-NCL or Ginga-HTML applications with GUI, do at `ginga/`:

```bash
flutter run -d <chrome,windows> --dart-define="APP=<path_to_file>"
```

To run Ginga-NCL application headless (no-GUI), do at `ncl_doc`:

```bash
dart ./lib/main.dart <path_to_file>
```

- For environment setup and technical architecture details, see [SETUP.md](SETUP.md).
- For instructions on running examples, see [EXAMPLES.md](EXAMPLES.md).
