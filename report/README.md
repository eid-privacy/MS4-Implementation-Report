# Report for Milestone 2

This directory contains the report for the first 9 months of the
Innosuisse grant 101.292 IP-ICT.
It is written in typst, and automatically generated with
every push to the `main` branch.
The finished PDF is found in the
[releases](https://github.com/eid-privacy/MS2-Minimal-Viable-Project/releases).
It can also be created using typst - either by installing typst
yourself, or by installing [DevBox](https://www.jetify.com/docs/devbox/installing-devbox)
and then running:

```bash
devbox shell
typst compile index.typ
```

Then the compiled report is available as `index.pdf`.

## Pre-commit hook

This repo ships a tracked git hook that verifies the report compiles with
typst before any commit touching `report/*.typ` or `report/*.bib` is
allowed through. To enable it, run once from the repo root:

```bash
git config core.hooksPath .githooks
```

From then on, `git commit` will run `devbox run compile` automatically
whenever a `.typ` or `.bib` file under `report/` is staged, and abort the
commit (printing the typst error) if compilation fails. Commits that don't
touch those files are not affected.

# CHANGELOG

- 2026/01/13

Patrick Amrein from Ubique suggested to use `--release` in the `cargo test`
for the docknetwork simulations.
This improved complete proving times for docknetwork by a factor of 15!
Now it is faster in all aspects than noir, which makes more sense.
