# MS4 - Implementation and Report

Final report for the Innosuisse grant 101.292 IP-ICT -
_Secure and Privacy-Preserving Credentials for E-ID_ - between EPFL and SICPA SA.

## Deliverable - 2026-10-07

The report is written in [typst](https://typst.app) and lives in [report/](report/).
Every push to `main` builds the PDF and publishes it in the
[releases](https://github.com/eid-privacy/MS4-Implementation-Report/releases).

## Building locally

With [DevBox](https://www.jetify.com/docs/devbox/installing-devbox) installed:

```bash
devbox run compile   # report/index.pdf
devbox run html      # report/index.html
devbox run watch     # recompile on change
devbox run test      # markdown link and prettier checks
```

To check that the report compiles before each commit, enable the tracked git hook:

```bash
git config core.hooksPath .githooks
```

See [report/README.md](report/README.md) for more details.
