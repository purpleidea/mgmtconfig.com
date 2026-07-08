# Contributing to the Documentation

## Documentation Git Repo

The source for the documentation on this website lives here: https://github.com/purpleidea/mgmtconfig.com - You'll also need to the website theme which requires git submodules:

```
$ git clone https://github.com/purpleidea/mgmtconfig.com
$ cd mgmtconfig.com
$ git submodule update --init
```

## Building & Viewing Documentation

To view documentation locally and to review any changes you might make, you'll want to render them. Rendering transforms the website's markdown into an html website.

You'll need [hugo]([https://gohugo.io/]).

From the toplevel directory of this repo, run `hugo serve -D` and this should render the documentation locally and serve it at http://localhost:1313

## Drawings and Diagrams

If you want to add diagrams to existing or new documentation, please include both the original project file and a rendered image (example: png) so that future changes may be more easily made.

If you aren't sure what tools to use for diagrams or drawings, you can try:

* In your browser:  [https://app.diagrams.net/]
* On your computer: [Inkscape](https://inkscape.org/)
