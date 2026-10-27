# MS4 - Implementation and Report

> [!NOTE]
> This report has moved to [eid-privacy/zkp-reports](https://github.com/eid-privacy/zkp-reports/tree/main/ms4-report),
> where all reports of the project are collected and built.
> This repository is kept for its history and will be archived.

Final report for the Innosuisse grant 101.292 IP-ICT -
_Secure and Privacy-Preserving Credentials for E-ID_ - between EPFL and SICPA SA.

## Deliverable - 2026-10-07

The [final report](https://github.com/eid-privacy/MS4-Implementation-Report/releases/download/2026-10-07_14-50/eid_privacy-101.292-IP-ICT-ms4-report-2026-10-07_14-50.pdf) covers all goals of MS4, see its appendix
_Work Packages and Milestones_.

- G0.3 The final report is available
  - Done: [final report](https://github.com/eid-privacy/MS4-Implementation-Report/releases/download/2026-10-07_14-50/eid_privacy-101.292-IP-ICT-ms4-report-2026-10-07_14-50.pdf)
- G7.1 Open sourced library is available publicly, e.g., on GitHub, with a "popular" OSI approved license
  - Done: [spartan-backend](https://github.com/eid-privacy/spartan-backend)
- G7.2 The Digital Trust Platform in WP8 can be extended using the documentation
  - Done: documentation in [spartan-backend](https://github.com/eid-privacy/spartan-backend) and the report chapter _If you want to use our code_
- G7.3 The necessary operations are fast enough to be executed on a modern mobile device, and the size of the messages is well below 1MB
  - Partially: age proof on an unmodified Swiyu SD-JWT incl. holder binding: 1.5s on a MacBook Pro M2 Max,
    4.5s on a 2023 mobile phone (Samsung Galaxy A54) with precomputation, 11.0s without.
    0.9s with a flat credential.
    The largest proof (c0202_sicpa_backend_constant) is 202kB.
    See the report section _Benchmarks_ and the Android apps
    zkp-android-spartan (not public yet) and [zkp-android](https://github.com/eid-privacy/zkp-android)
- G7.4 The review shows the security of the library and its recommendations are integrated
  - Done: the [security review](https://github.com/eid-privacy/zkp-reports/tree/main/security-review) by [zkSecurity](https://zksecurity.xyz/) and our answers are in the report section _Security Review_;
    the critical findings have been fixed
- G7.5 SICPA's Digital Trust Platform successfully implements new functionality using the library
  - Done: the platform can request and present credentials using the ZKP circuits of the library,
    see the report section _SICPA Integration_
- G8.1 Confirmation of usefulness of use-cases by FOITT and FOJ
  - Done informally in discussions, see the report section _Use case examples_
- G8.2 Demonstrator on Digital Trust Platform is available and performs the needed functions
  - Done: "over 18" demonstrator using the c0202 circuit, to be shown as a recording

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
