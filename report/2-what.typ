= WHAT - Overview of our Solution (L)

- Based on standard SD-JWT, changing only the revocation
- No need for batch emission
- Easy to extend and change

== Use case examples (L)

- different kind of credentials:
  - state e-ID credential (root of trust, name, dob, picture)
  - governmental services (drivers license, electronic health dossier, IV)
  - commune and cantonal credentials (address)
  - employer (job title, salary)
  - commercial (abonnements, entries)
- age verification (duh)
- drivers license verification
- rights for reduction (PLZ verification, salary verification)

== SICPA Frontend (Cl)

- explain SICPA integration

== Benchmarks (Ca)

- Run time on Macs / Mobile
- Detail (c01 or just c200)

== Code Repositories (L)

=== Main Work

- [spartan-backend](https://github.com/eid-privacy/spartan-backend) - using
  Spartan as a proving backend for noir
- [zkp-pocs](https://github.com/eid-privacy/zkp-pocs) - a collection of circuits
  created during the grant

=== Discussions

- [zkp-valut](https://github.com/eid-privacy/zkp-vault) - most of the research
  papers we read
- [eid-privacy](https://github.com/eid-privacy/eid-privacy.github.io) - blog
  of our work

=== Benchmarks

- [zkp-android](https://github.com/eid-privacy/zkp-android) - mobile test app
  for benchmark measurements
- [zkp-android-spartan](https://github.com/eid-privacy/zkp-android) - mobile test app
  for benchmark measurements using the spartan backend

=== Utilities

- [flakes](https://github.com/eid-privacy/flakes) - pre-compiled packages for
  nix and devbox


== Related Works (Cl)

- Longfellow / Crescent
- Standardisation efforts
