# gingaf

Ginga is the interactive midleware for TV systems standadise by ITU-T and SBTVD.
Gingaf is a multi-platform flutter-based Ginga implementation, which supports Ginga-NCL and Ginga-HTML runtimes.

To run Ginga-NCL or Ginga-HTML applications with GUI, run:

```bash
flutter run -d <device> --dart-define="APP=<path_to_file>"
```

- **`APP`**: Path to the `.ncl` or `.html` file, relative to `gingaf/`.

To run Ginga-NCL application headless (no-GUI), run:

```bash
dart ./ncl_doc/lib/cli.dart <path_to_file>
```

- For environment setup and technical architecture details, see [SETUP.md](SETUP.md).
- For instructions on running examples, see [EXAMPLES.md](EXAMPLES.md).
