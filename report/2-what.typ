= WHAT - Overview of our Solution (L)

When we started the project to work on Zero-Knowledge-Proofs (ZKPs)
in the context of electronic identities, we looked for new structures
to describe electronic credentials.
We did an extended literature review and looked at various programming
libraries which implement the necessary cryptographic primitives
during the first part of this project [ref].
After the first half of the project, we concluded the following:

- Standardisation is very important for governments, so it will be
very difficult to get adoption for a new format [ref]
- ZKPs made a lot of progress, and the circuit-based ZKPs are much
easier to reason about and are catching up with respect to performance
to other types of ZKPs [ref]

This made us adjust the direction for the second half of the project:
instead of creating a new type of ZKP based on a new credential format,
we decided to work on a circuit-based ZKP and do the minimum changes
necessary to the standard SD-JWT credentials.
During our project various new propositions for ZKPs were published
[ref], [ref], [ref]. To our knowledge, our proposition and measurements
are the first ones to be done on a real credential from a real
E-ID project (Swiyu), with code available as Open Source and
understandable by somebody without specific knowledge of the
algorithms.
Our solution is based on the standard SD-JWT used in Swiyu, with the
following important points:

- Using ZKP, there is no need for batch emission [ref-swiyu] anymore
- We had to change the revocation [ref-MS4]
- Easy to understand and extend by IT professionals [ref-MS4]
- On laptop hardware acceptable performance (< 1s for a proof),
on mobile hardware still needs some improvement (<10s on a 2025 iPhone)

== Comparison with Other Solutions (L)

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

- We integrated the proof system implementation in a solution providing issuance, verification, and could wallet capabilities.
  - issuance is untouched, verification changes by adding new openid4vp proof type, same on wallet side
- integration point within OpenId4VP
  - new proof format
- high-level architecture with our OpenId component fetching credentials as usual but delegating proof cration to ZKP component

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

- [zkp-vault](https://github.com/eid-privacy/zkp-vault) - most of the research
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
  - Longfellow - best in class for requirements, no setup, PQ, very fast. Bad circuit writeability/readability and therefore auditing. A more accessible way to write circuit would be required for a proper rollout
  - Crescent - useful ideas but public setup and the stack is "big" (Groth + Spartan + Commitments). Bellpepper is a better interface than Longfellow's to write circuits but still requires in-depth knowledge
  - Vega @KS25 - Upgrade to Spartan, folding of circuits yields very fast proving, particularly by optimizing the hashing time. Bringing a nice-to-use DSL on top of it (e.g., Noir) would be a great follow-up to our work.
  - OpenAC @ENRT26 - Need to read before making comments
- Standardisation efforts
  - ETSI is standardizing BBS, Longfellow-zk, Vega, and OpenAC for digital identity uses in ETSI 119 476 2 (https://portal.etsi.org/webapp/workProgram/Report_WorkItem.asp?wki_id=74931)
  - In our opinion, the standardization of BBS comes too late and the convenience vs cost of rollout of BBS is not in its favor anymore. Especially with all the strong circuit-based ZKP contenders.
  - Yubico is doing stuff as well (find citation)
