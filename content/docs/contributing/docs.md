# Contributing to the Documentation

## Documentation Git Repo

The source for the documentation on this website lives at:
[https://github.com/purpleidea/mgmtconfig.com/](https://github.com/purpleidea/mgmtconfig.com/).
You'll also need to the website theme which requires git submodules:

```
$ git clone https://github.com/purpleidea/mgmtconfig.com/
$ cd mgmtconfig.com/
$ git submodule update --init
```

## Building and Viewing Documentation

To view documentation locally and to review any changes you might make, you'll
want to render them. Rendering transforms the website's markdown into an html
website.

You'll need [hugo]([https://gohugo.io/]).

From the toplevel directory of this repo, run `hugo serve -D` and this should
render the documentation locally and serve it at http://localhost:1313/

## Drawings and Diagrams

If you want to add diagrams to existing or new documentation, please include
both the original project file and a rendered image (example: png) so that
future changes may be more easily made.

If you aren't sure what tools to use for diagrams or drawings, you can try:

* In your browser:  [https://app.diagrams.net/]
* On your computer: [Inkscape](https://inkscape.org/)

## Links

Use absolute links when reasonable, rather than `../` variants which are harder
to review and follow.

## Reflow

Please reflow docs to 80 characters.

## Comments

When showing source code snippets, use the ideal form when possible. As with
most source code, comments should be full sentences and be capitalized and
punctuated accordingly, or they should be one-liners, and should not contain
either of those benefits.

## Whitespace

Make sure to run `git diff --check` to make sure you don't have erroneous
whitespace in your contributions.

## Line breaks

You should likely not need to see three newlines in a row. You can fix these by
replacing `\n\n\n` with `\n\n\` with no adverse effects.

## Special characters

Try to avoid using special characters in the documentation. Keeping things to
basic ASCII keeps it more accessible for everyone that isn't using a fancy
editor.

## Resource Examples

In mcl resource examples, list parameters in the same order as the resource
definition and resource documentation. For example, put `state` before
`content` in a `file` resource and before `startup` in a `svc` resource.

Put metaparameters, including relationship parameters such as `Before`,
`Depend`, `Notify`, and `Listen`, after the resource-specific parameters.
Separate the two groups with a blank line.

Examples presented as runnable should parse and type-check. Clearly identify
schematic examples that use placeholders and examples that intentionally
produce an error.

## Project Names

The name `mcl` is always lowercase. The name `mgmt` is lowercase except that
`Mgmt` is acceptable when it begins a full sentence. In general when writing
about `mcl` you should use emphasis by surrounding it with backticks or
underscores.
