# ncl_doc

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)

Logic package handling the "Intelligence" of the document.

## Run Headless (no-UI) Ginga-NCL applications

All example NCL documents are stored in the `examples/` folder at the root of the workspace.

To run headless NCL simulation:

```bash
cd gingaf/ncl_doc
dart lib/main.dart ../examples/video.ncl
```

For easy, you can use `make run`. See below.

```bash
cd gingaf/ncl_doc
make run-example app=video.ncl
```
