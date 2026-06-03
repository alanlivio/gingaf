# gingaf

Ginga is the interactive midleware for TV systems standadise by ITU-T and SBTVD.
Gingaf is a multi-platform flutter-based Ginga implementation, which supports Ginga-NCL and Ginga-HTML runtimes.

To run applications:

```powershell
flutter run -d <device> --dart-define="APP=<path_to_file>"
```

- **`APP`**: Path to the `.ncl` or `.html` file, relative to `gingaf/`.

- For environment setup and technical architecture details, see [SETUP.md](SETUP.md).
- For instructions on running examples, see [EXAMPLES.md](EXAMPLES.md).
