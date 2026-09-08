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

# CHANGELOG

- 2026/01/13

Patrick Amrein from Ubique suggested to use `--release` in the `cargo test`
for the docknetwork simulations.
This improved complete proving times for docknetwork by a factor of 15!
Now it is faster in all aspects than noir, which makes more sense.
