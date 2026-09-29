#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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
- We had to change the revocation (see @follow-up-revocation) [ref-MS4]
- Easy to understand and extend by IT professionals [ref-MS4]
- On laptop hardware acceptable performance (< 1s for a proof),
on mobile hardware still needs some improvement (< 10s on a 2025 iPhone)

== Comparison with Other Solutions (L)

As discussed in our first report [ref-MS2], we distinguish the
following families of ZKPs for our project:

#table(
  columns: (auto, auto, auto, auto, auto),
  table.header([Family], [Efficiency / Performance], [Proof Input], [Extensibility], [Examples]),

  [Sigma-proof], [high], [Specialised credentials], [difficult to reason about without high
    cryptographic knowledge], [BBS+, ZKAttest],
  [ZKP circuits], [medium], [Standard SD-JWT], [based on simplified languages (rust-like, C-like)
    which only needs moderate efforts to modify], [noir, SNARKS, SNARGS],
  [ZKVMs], [low], [Standard SD-JWT], [simulates any program as a ZKP, so very simple to
    extend], [SP1, OpenVM]
)

This table shows that there is a trade-off between efficiency, measured as
proving-time and proof-size, and extensibility, measured as the possibility
for non-domain-experts to change the inputs and tests of a ZKP.
Another important point is that even though sigma-proof based ZKPs are very
efficient, they need a credential in a format which is not in use by any of
the governmental E-ID solutions proposed in Europe [ref-EU-ARF] [ref-Swiyu].

=== Sigma-proofs

The term has been introduced for the first time by [ref-Cra97] and describes
the interaction between a prover and a verifier.

#figure(
  diagram(
    spacing: (3em, 2.2em),
    node-stroke: 1pt,
    node((0, 0), [Prover], name: <prover>),
    node((2, 0), [Verifier], name: <verifier>),
    edge((0, 0), (0, 3.5), "-", stroke: 0.5pt + gray),
    edge((2, 0), (2, 3.5), "-", stroke: 0.5pt + gray),
    edge((0, 1), (2, 1), "->", [commitment $t$]),
    edge((2, 2), (0, 2), "->", [challenge $c$]),
    edge((0, 3), (2, 3), "->", [response $s$]),
  ),
  caption: [Sigma-protocol: the prover commits, the verifier challenges, and
    the prover responds.],
) <fig-sigma-protocol>

With some imagination, one can interpret the @fig-sigma-protocol as a
greek $Epsilon$ - the paper indicates further that:

#quote[Spelled out, the first part of _Sigma_ refers to "zig-zag" symbolising
  the three moves, while the last part is an abbreviation of "Merlin-Arthur".]

These proofs are very specialised to a specific proof type - [ref-CM99] gives
a list which has been updated since then, but still gives an idea what
can be done with these types of proofs:

- Proving the knowledge of a discrete logarithm xo f a group element y
  to a base g
- Proving the knowledge of a representation of an element y to
  the bases $g_1,...,g_l$
- Proving the equality of the discrete logarithms of elements y1 and y2 to the bases
  g and h, respectively
- Proving the knowledge of (at least) one out of the discrete logarithms of
  the elements $y_1$ and $y_2$ to the base g (proof of OR)
- Proving the knowledge of a discrete logarithm that lies in a given range,
  that is, $2^(ℓ_1) − 2^(ℓ_2) < log(g_y) < 2^(ℓ_1) + 2^(ℓ_2)$ , for some parameters
  $ℓ_1$ and $ℓ_2$

Over time, other sigma proofs have been defined, which led to [ref-CFQW19]
describing a method of combining different families of sigma-proofs together
in an optimized way.
This method has been further optimised and is proposed for example by [ref-FHLL25]
to be applied to electronic credentials.

While these types of proofs are often the fastest and most concise way to
create a proof, the main disadvantages are:

- only people with specialized cryptographic knowledge can apply these
  proofs to new credentials
- these proofs only work with new formats for the electronic credentials,
  so the EU-ARF and Swiyu projects would need to be rewritten

=== ZKP-Circuits



- different types of ZKPs: sigma-proof, circuits, VMs
- advantages / disadvantages of each solution (complexity / speed tradeof)
- examples of each type
- Longfellow / Crescent / OpenAC

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

== SICPA Integration (Cl)

SICPA has its own implementation of standardized formats and protocols for digital identity, including Swiyu-mandated SD-JWT and OpenId4VCi/VP.
This makes our work on the SD-JWT of the Swiss e-id a very good candidate for integration in that implementation.


SICPA's implementation is designed for so-called "Cloud Wallets".
Keys reside in a key management system that lies outside of the solution's perimeter, modelled the same way an HSM is, i.e., no access to user's private keys.
Platform users can, using the same set of keys, act as holders, provers, and verifiers.
The integration we demonstrate for this work makes use of two distinct users: one who receives an e-id (outside of the scope of this work) and proves
its possession and being over 18 years old using the zero-knowledge proof developed during the grant. The other user is a verifier able to use the zero-knowledge
tooling to verify the holder's claim.
We assume the issuer to be known and considered trustworthy, the implementation does not include going to the base registry.
The interaction happens "in the cloud", and despite both user being hosted by the same platform, perform a proper OpenId4VP verification process across
the internet.

To support such a verification, we extend from the OpenId4VP specification by adding a "proof_type" that suits our ZKP.
This proof types allows communicating the public parameters selected by the verifier to the holder/prover, and the prover to return
a base64 encoding of its zero-knowledge proof.

At a high-level (see @fig-sicpa-architecture), our OpenId component receives a verification requests with a new 
`proof_type` and delegates its creation to new components that embed the artifacts 
implemented for this work.
The OpenId flow is unchanged and communication happen agent-to-agent, over the internet,
as for "normal" proof requests.

#let openid-fill = rgb("#e8f0fe") // existing, standard OpenId4VP components
#let zkp-fill = rgb("#e9f7ef") // new components introduced by this work
#let data-fill = rgb("#fff4e5") // credential storage

#figure(
  diagram(
    spacing: (26mm, 15mm),
    node-stroke: 0.6pt,
    node-corner-radius: 2pt,
    node-inset: 6pt,
    edge-stroke: 0.6pt,
    node-defocus: 0,

    // --- holder / prover side (left column) -----------------------------
    node((-0.2, -0.85), text(size: 0.85em, fill: gray)[*Holder / prover*], stroke: none, fill: none),
    node((0, 0), align(center)[OpenId4VP component \
      #text(size: 0.85em)[handles the new `proof_type`]], fill: openid-fill, name: <holder-oid>),
    node((-.75, 1), align(center)[Credential store \
      #text(size: 0.85em)[SD-JWT e-ID]], fill: data-fill, name: <credentials>),
    node((0, 2), align(center)[ZKP prover component \
      #text(size: 0.85em)[
        Compute proof with public parameter \
        \+ witness from credential
      ]], fill: zkp-fill, name: <prover>),
    edge(<credentials>, <prover>, "->", label: text(size: 0.8em)[],
      label-side: left, label-sep: 2pt),
    edge(<holder-oid>, <prover>, "->", bend: 25deg,
      label: text(size: 0.8em)[3. public parameters], label-side: left, label-sep: 1pt),
    edge(<prover>, <holder-oid>, "->", bend: 25deg,
      label: text(size: 0.8em)[4. base64 proof], label-side: left, label-sep: 1pt),

    // --- verifier side (right column) -----------------------------------
    node((1, -0.85), text(size: 0.85em, fill: gray)[*Verifier*], stroke: none, fill: none),
    node((1, 0), align(center)[OpenId4VP component \
        #text(size: 0.85em)[chooses the public parameters]
      ],
      fill: openid-fill, name: <verifier-oid>),
    node((1, 2), align(center)[ZKP verifier component \
      #text(size: 0.85em)[synthesizes the R1CS,\
      verify proof and public parameters]
    ], fill: zkp-fill, name: <verifier-zkp>),
    edge(<verifier-oid>, <verifier-zkp>, "->", bend: 25deg,
      label: text(size: 0.8em)[6. proof], label-side: left, label-sep: 2pt),
    edge(<verifier-zkp>, <verifier-oid>, "->", bend: 25deg,
      label: text(size: 0.8em)[7. result], label-side: left, label-sep: 2pt),

    // --- the two sides talk plain OpenId4VP over the internet ------------
    edge(<verifier-oid>, <holder-oid>, "->", bend: -20deg, label-side: right, label-sep: 2pt,
      label-fill: white, label: align(center, text(size: 0.8em)[1. authorization request 
    ])),
    edge(<holder-oid>, <verifier-oid>, "->", bend: -20deg, label-side: right, label-sep: 2pt,
      label-fill: white, label: align(center, text(size: 0.8em)[5. VP token \ with the ZKP])),
    edge((0.5, -1.2), (0.5, 2.6), stroke: (dash: "dashed", paint: gray),
      label: text(size: 0.8em, fill: gray)[internet], label-pos: 0, label-side: right),
  ),
  caption: [High-level architecture of the integration. The
    #box(fill: openid-fill, stroke: 0.4pt, inset: 2pt, outset: 1pt, radius: 1pt)[blue]
    OpenId4VP components orchestrate the exchange as per specifications, and delegate the
    zero-knowledge work to the
    #box(fill: zkp-fill, stroke: 0.4pt, inset: 2pt, outset: 1pt, radius: 1pt)[green]
    components introduced by this work. Both users are hosted by the same cloud-wallet
    platform, but the presentation exchange still crosses the internet.],
) <fig-sicpa-architecture>

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
