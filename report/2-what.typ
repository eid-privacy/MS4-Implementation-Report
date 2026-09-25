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
on mobile hardware still needs some improvement (< 10s on a 2025 iPhone)

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


== Related Works and concurrent events (Cl)

During the period this project spanned, a number of high-profile publications, as well as key governance decisions have happended.

Interest towards production-deployable Zero-Knowledge solutions for digital identity
is clear, if only from the number of very strong publications that happened during
the course of this project. Among these, the most prominent results are:

- Longfellow @FS24, a very optimized proof system that has been field tested with Google and Deutsche Bank.
 We analyze it in comparison with Crescent in a blog post @EIDBlogCrescentLongfellow.
 It achieves most of our targets but we found the adaptability to be poor when it came to changing the circuits' implementation and lack auditability by non-experts.
- Crescent @FFL25 implements interesting ideas with commitments re-randomization as well as the modified ECDSA equation verification for holder binding.
 We analyze and compare it to Longfellow in a blog article @EIDBlogCrescentLongfellow.
 The main proof on the credential uses Groth16 @G16 which requires a public setup, something we wanted to avoid.
 Our implementation uses their holder binding technique to reduce the ECDSA verification cost and maximize the proving work that can be done in a pre-computed phase.
  - Vega @KS25 is an iteration on Spartan @S19.
   It introduces a folding of circuits yielding very fast proving time.
   In particular by optimizing the time spent on hashing credential blocks prior to signing or verification.
   Extending our work with Noir and Vega to provide a DSL that allows for folding would be a great follow-up to our work.
  - OpenAC @ENRT26 - Need to read before making comments

There are also talks from standardization body to include this work in standards recognized by the governing bodies in the EU:

- Standardisation efforts
  - The authors of Longfellow have proposed it as an IETF draft @IETFLongfellow.
  - ETSI is standardizing BBS, Longfellow-zk, Vega, and OpenAC for digital identity uses in ETSI 119 476 2 @ETSIZKP. In our opinion, the standardization of BBS is great but comes at a point in time when the convenience vs cost of rolling out BBS in a way that is compliant with eIDAS 2 is not attractive. Even less so with all the strong circuit-based ZKP contenders.
  - Yubico has also announced interest in piloting with Longfellow in the scope of Europe's Digital Identity project https://www.yubico.com/blog/piloting-europes-future-id-passkeys-securing-digital-wallets/
