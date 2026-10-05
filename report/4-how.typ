#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= If you want to use our code <how>

This chapter gives some pointers how to use our work and what the
restrictions are.
We hope that our work can be used by other people to test out how
good ZKPs are currently for use-cases like e-ID.

== Assumptions / Caveats <how-assumptions>

It is important to understand what generic assumptions we make
with regard to the credentials and usage:

- the issuer is trustworthy - specifically, once an issuer signs
  an SD-JWT, we can suppose that this data structure is correct,
  and does not need to be verified in the circuit
- the issuer is authoritative on the data being signed - there is
  no user input which is taken as-is and put into the SD-JWT - so
  any attacks where the user can use a free-form field to enter
  hash values or other parts of a normal SD-JWT are not feasible
- the verifier and the prover agree on the circuit to be executed,
  and this circuit is secure and privacy preserving - we don't allow
  for any random circuit by the verifier, which could reveal more
  information than the prover is willing to release to the
  verifier

== Code Repositories / Documentation <how-code>

We have two main repositories, one for each of the proof systems that we examined: Noir with the default
UltraHonk/Barretenberg system, and Noir with the Spartan/Vega proof system that we investigated as an
optimization.

Mirroring this, we also provide a test mobile app for each of the proof systems to benchmark the Swiyu SD-JWT
circuits on a phone.

These four repositories each contain extensive README files with instructions as well as Devbox
configurations to ease reproducibility. They also contain AGENTS files to guide AI coding agents.

Furthermore, we published blog posts throughout the course of the grant to report on our progress, all of
which are tracked in a separate repository.

Finally, we included related work in a separate repository.

All repositories are published under
#link(gh-org)[`github.com/eid-privacy`], as listed in @tab-repos.
In every repository you'll find a main `README.md`, followed
by other files which describe how to use the code in your
own projects.

#let cat(body) = table.cell(colspan: 2, fill: luma(93%), strong(body))

#figure(
  table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 4pt, y: 3pt),
    align: left,
    table.hline(),
    cat[Main work],
    repo("spartan-backend"), [Noir with the Spartan/Vega proof system],
    repo("zkp-pocs"), [Collection of circuits (Docknetwork and Noir with UltraHonk/Barretenberg)],
    repo("flakes"), [Precompiled packages for Nix and Devbox],
    cat[Benchmarks (Android)],
    repo("zkp-android"), [Test app for Noir with UltraHonk/Barretenberg],
    repo("zkp-android-spartan"), [Test app for Noir with Spartan/Vega],
    cat[Publications],
    repo("eid-privacy.github.io"), [Blog posts (#link("https://eid-privacy.github.io")[`eid-privacy.github.io`])],
    cat[Related work],
    repo("zkp-vault"), [Collection of related work],
    table.hline(),
  ),
  caption: [Code repositories and documentation.],
) <tab-repos>

== Use in Mobile

To know whether our chosen platform is really usable by today's mobile
phones, we implemented a proof-of-concept mobile app which simply
creates a proof, and then verifies it.
We did not implement the full protocol of interacting with the government
services like base and trust registry, but simply executed the code
necessary to create a cryptographic proof.
Given that this time is much longer than most network communication, we
suppose that this gives us a good measurement on the feasibility of our
solution.

If you want to create your own mobile app, the UniFFI bindings in
`zkp-android-spartan` provide everything you need.
They are used to generate bindings for the Kotlin language, which you can
then include in your own app as you see fit.
The repository contains detailed instructions for both humans and AI
coding agents to guide you through the process.

@how-mobile-uniffi shows a summary of how the different parts of
our libraries work together in a mobile system.
Rust is often used in mobile devices for time-critical
elements, or to allow to have the same code base for the
frontend and the backend.
Using UniFFI, it is easy to create an API which can be used
from mobile apps, for Android as well as for iOS.

#wide-figure(
  diagram(
    mark-scale: 150%,
    spacing: (6mm, 8mm),
    node-stroke: 0.6pt,
    node((0, 0), [*Kotlin app* \ App code (MainActivity.kt: \ Compose UI + benchmarks)]),
    edge("d", "->", [calls the exported API]),
    node((0, 1), [*UniFFI* \ Generated Kotlin bindings \ (noir_spartan.kt)]),
    edge("d", "->"),
    node((0, 2), [*UniFFI* \ JNA / JNI]),
    edge("d", "->"),
    node((0, 3), [*UniFFI* \ Rust FFI surface \ #raw("#[uniffi::export]") functions]),
    edge("d", "->"),
    node((0, 4), [*noir_spartan* \ Public Rust API \ for spartan_backend ]),
    edge("d", "->"),
    node((0, 5), [*spartan_backend* \ Underlying implementation]),
    node((1, 5), [Circuit files on disk \ #raw("filesDir/circuits/<circuit>/")]),
    edge((0, 4), (1, 5), "->", [re-reads files on every call]),
    edge((0.3, 4), (0.2, 1), "-->", [build time: uniffi-bindgen \ generates bindings + FFI surface], bend: -40deg),
  ),
  caption: [Including rust code in a mobile app using UniFFI.
    The *UniFFI* blocks are provided by the library or auto-generated.]
)<how-mobile-uniffi>

== Proof and verification pipelines

In @why-spartan-build, we describe the overall protocol how a proof
is created, starting from the verifier, to the prover.
Once a proof is created, this proof can then be verified by any verifier
in possession of the same R1CS instance (i.e., synthesizing the same code with our synthesizer).

@fig-proof-pipeline summarizes the pipeline visually.

#let step-fill = rgb("#e8f0fe") // processing steps run by our tooling
#let data-fill = rgb("#fff4e5") // intermediate artefacts
#let check-fill = rgb("#e9f7ef") // final verification

#wide-figure(
  diagram(
    spacing: (10mm, 10mm),
    node-stroke: 0.6pt,
    node-corner-radius: 2pt,
    node-inset: 6pt,
    edge-stroke: 0.6pt,
    node-defocus: 0,

    // --- 1. the verifier asks for a proof -------------------------------
    node((0, 0), align(center)[Verification request \
      #text(size: 0.85em)[public, verifier-chosen parameters \
        (incl. holder-binding nonce)]], fill: data-fill),
    edge("->"),

    // --- 2. the prover builds the circuit inputs ------------------------
    node((0, 1), align(center)[Map to circuit inputs \
      #text(size: 0.85em)[high-level parameters of the \
        Noir circuit description in `Prover.toml`]], fill: step-fill),
    edge("->"),
    node((0, 2), align(center)[Preprocessor \
      #text(size: 0.85em)[computes the Crescent holder-binding \
        points, augments the circuit input file]], fill: step-fill),
    edge("->"),

    // --- 3. compilation: one input set, two outputs ---------------------
    node((0, 3), align(center)[`nargo-t256 execute` \
      #text(size: 0.85em)[Noir compiler using Tom-256]],
      fill: step-fill, name: <nargo>),
    node((-0.8, 4), [ACIR], fill: data-fill, name: <acir>),
    node((0.8, 4), [Witness mapping], fill: data-fill, name: <witnesses>),
    edge(<nargo>, <acir>, "->"),
    edge(<nargo>, <witnesses>, "->"),

    // --- 4. spartan-backend: R1CS, evaluation, proof --------------------
    node((-0.8, 5), align(center)[Synthesize \ R1CS instance], fill: step-fill, name: <synth>),
    edge(<acir>, <synth>, "->"),
    node((0.4, 6), align(center)[Instantiate R1CS \ and evaluate circuit],
      fill: step-fill, name: <evaluate>),
    edge(<synth>, <evaluate>, "->"),
    edge(<witnesses>, <evaluate>, "->"),
    node((0, 7), [Compute Vega proof], fill: step-fill, name: <proof>),
    edge(<evaluate>, <proof>, "->"),

    // --- 5. any verifier re-synthesizes the R1CS and checks the proof ---
    node((2.7, 5), align(center)[Verifier synthesis], fill: step-fill, name: <re-synth>),
    edge(<synth>, <re-synth>, "..", label: text(size: 0.8em)[same circuit code],
      label-side: left),
    node((2.7, 7), align(center)[Verify proof against \ the R1CS instance],
      fill: check-fill, name: <verify>),
    edge(<re-synth>, <verify>, "->"),
    edge(<proof>, <verify>, "->", label: text(size: 0.8em)[proof + public inputs],
      label-side: right),

    // --- the prover-side steps, boxed together --------------------------
    node(enclose: (<nargo>, <acir>, <witnesses>, <synth>, <evaluate>, <proof>, (0, 1), (0, 2)),
      stroke: (dash: "dashed", paint: gray), fill: none, inset: 9pt, snap: false),
  ),
  caption: [Proof and verification pipeline, from the verifier's request down to the
    verification of the Vega proof against an independently synthesized R1CS instance.
    The dashed box groups the steps run by the prover.
    Boxes in
    #box(fill: data-fill, stroke: 0.4pt, inset: 2pt, outset: 1pt, radius: 1pt)[orange]
    are intermediate artefacts.],
) <fig-proof-pipeline>

== Precomputation <how-precomputation>

Around July 2026, Microsoft updated and renamed the source code distributed under the name of `spartan` to align it with the more recent Vega publication @KS25 under the name `vega-prover`. These changes introduced a clearer API to allow for partial instantiation of circuits and thus, pre-computation of partial proofs.

We cascaded this capability to `spartan-backend` by adding a configuration file documenting which inputs of a circuit are expected to change at every circuit instantiation. As an example: the credential for a given holder is always the same, the challenger nonce is not. Our backend uses this to compute the partition of constraints that does not depend on these inputs. This partition represents the portion of the proof that can be pre-computed.

Concretely, the configuration file marks a few input wires as volatile, and the taint
propagates forward: a constraint is volatile as soon as one of its inputs is.
@fig-taint-partition illustrates this propagation on a _simplified_ view of the
swiyu_jwt circuit.

#wide-figure(
  text(size: 0.9em, diagram(
    spacing: (6mm, 8mm),
    node-stroke: 0.6pt,
    node-corner-radius: 2pt,
    node-inset: 5pt,
    edge-stroke: 0.6pt,
    node-defocus: 0,

    // --- stable inputs, left; volatile input, right ----------------------
    node((0, 0), align(center)[SD-JWT credential], fill: check-fill, name: <cred>),
    node((1.4, 0), align(center)[Device key], fill: check-fill, name: <dev>),
    node((2.9, 0), align(center)[Verifier nonce], fill: data-fill, name: <nonce>),

    // --- untainted sub-tree ---------------------------------------------
    node((-0.1, 1), align(center)[Issuer signature], fill: check-fill, name: <sig>),
    node((1.1, 1), align(center)[Claim extraction], fill: check-fill, name: <claims>),
    edge(<cred>, <sig>, "->"),
    edge(<cred>, <claims>, "->"),
    node((0.5, 2), align(center)[Claims commitment], fill: check-fill, name: <commit>),
    edge(<sig>, <commit>, "->"),
    edge(<claims>, <commit>, "->"),

    // --- tainted sub-tree -----------------------------------------------
    node((2.4, 1), align(center)[Holder binding], fill: data-fill, name: <hb>),
    edge(<nonce>, <hb>, "->"),
    edge(<dev>, <hb>, "->"),
    node((2.4, 2), align(center)[ECDSA check], fill: data-fill, name: <ecdsa>),
    edge(<hb>, <ecdsa>, "->"),

    // --- the root inherits the taint ------------------------------------
    node((1.45, 3), align(center)[Proof root], fill: data-fill, name: <root>),
    edge(<commit>, <root>, "->"),
    edge(<ecdsa>, <root>, "->"),

    // --- the two partitions ---------------------------------------------
    node(enclose: (<cred>, <sig>, <claims>, <commit>),
      stroke: (dash: "dashed", paint: gray), fill: none, inset: 8pt, snap: false,
      name: <pre-box>),
    node(enclose: (<nonce>, <hb>, <ecdsa>, <root>),
      stroke: (dash: "dashed", paint: gray), fill: none, inset: 8pt, snap: false,
      name: <live-box>),
    node((0.5, 3.1), [pre-computed], stroke: none, fill: none),
    node((2.9, 3.6), [presentation time], stroke: none, fill: none),
  )),
  caption: text(size: 0.9em)[Taint propagation through the constraint graph.
    Nodes in
    #box(fill: check-fill, stroke: 0.4pt, inset: 2pt, outset: 1pt, radius: 1pt)[green]
    depend only on inputs that are stable across presentations and belong to the
    pre-computable partition; nodes in
    #box(fill: data-fill, stroke: 0.4pt, inset: 2pt, outset: 1pt, radius: 1pt)[orange]
    are tainted, i.e. at least one of their parents is tainted, and must be recomputed at
    every presentation. The device key is stable, but combining it with the nonce taints the
    holder-binding branch, and the root inherits the taint.],
) <fig-taint-partition>

With this in place we can optionally pre-compute e-ID presentations and at presentation
time compute only the part that depends on the verifier's challenge for holder binding.
While the first, naive implementation of storing the pre-computer circuit
generated multi-GB sized files, we managed to reduce this by applying
the following techniques:

- not store the full structure, as parts of it is not used in the finalisation -
  this reduces the file size from 2GB to 1GB
- apply a compression algorithm to the structure - there is a lot of repetition
  in the structure - reduction from 1GB to 40MB
- don't verify the data upon load - as the data is created by the prover, and
  then re-read by that same prover, we can trust it's the same - this reduces
  the loading time even further

Applying these steps makes the storing and loading of the pre-computation
not only feasible, but creates a real advantage compared to a full
proof creation!
It is to be noted as well that this intermediate proof contains sensitive
information of the holder and needs to be stored in accordance.

== Technical Limitations <how-technical>

While sigma proofs are faster and often produce smaller messages, we decided
to use a circuit based proof system to make it easier for
non-cryptographers to create their own proofs.
During our project we saw that this actually works great, and that the
engineers at SICPA were able to update our proposed circuit to
enable new functionality.

However, we also saw one big downside of this openness: some programming
patterns produce very big circuits, and as a non-cryptographer it is
often difficult to understand why our code is not good.
One example we encountered was the @how-opt-barrel, where a software
engineer used a for loop to copy data from one array into another.
But as the indexes were part of the private inputs, the circuit had
to take into account all possible sizes - which are a lot.

There is the possibility to introduce more optimisations in the noir
backend to allow for automatic improvements of these cases.
But there will be a lot of these patterns which create very big
circuits, and thus are not optimal to be used.
As of September 2026, LLMs like Claude were very helpful in detecting
the reason for these big circuits, and proposing solutions.
But as always, if you cannot judge if the proposed solution is actually
good, it's difficult to avoid errors.

== Use of LLMs <how-llms>

Our work would not have been possible without the use of LLMs.
We did exploratory work with different LLMs, mostly Claude,
Copilot, and open-weight models like Qwen and DeepSeek.
This allowed us to create a lot of boiler-plate code like
benchmark scripts, mobile UIs, but towards the end of the
project also more extensive optimisation tests.
Even during the 18 months of this project, it was interesting
to see the improvement of these tools.
It is incredible the power we have nowadays to go from idea
to realisation in a very short timeframe.

With all that power comes a big responsibility: as we're all
senior professionals, we do know the basics of software engineering,
and can steer the LLMs in the right direction.
For our more junior colleagues, we spent quite some time explaining
to them how to change what they implement, and why they should
ask other tasks from the LLMs.

In this reports, LLMs did cleanup, formatting tables and lists,
grammatical reviews.
But the first writing of the report has been done manually,
as writing a report is also a way to re-visit everything we
did, and discover shortcomings, and possible improvements!

== Security Review <how-security>

On the 24th of August, #link("https://zksecurity.xyz")[zkSecurity] started
the security review of our proof-of-concept code.
We wrote the requirement for the review to include:

- our inclusion of the Spartan prover as a backend for noir
- the circuits we wrote for the proof-of-concept
  - for the Swiyu SD-JWT credential
  - for the SICPA case
- our proposal for the revocation list, including the circuit

After the allotted time, zkSecurity came back to us with the
report of their findings, summarized in @tbl-security-findings.
Findings marked as _out of scope_ are either outside of what we asked
to be reviewed, or only relevant in a different attacker model than ours.

#figure(
  findings-summary(),
  caption: [Findings of the zkSecurity review and their current status.],
) <tbl-security-findings>

In the following we list all findings, using the numbering of the zkSecurity
report, together with our answers.

=== High

#finding("00", [Prover-controlled offsets allow reads beyond the signed payload],
  fix: commit("spartan-backend", "29e81b3"))[
  The offsets given by the prover are now limited to the range of the signed payload.
  This affected the circuits `c0200_swiyu_jwt` and `c0202_sicpa_backend_constant`.
]

#finding("01", [Zero inverse scalar and infinity point bypass issuer authentication],
  fix: commit("spartan-backend", "fe635c1"))[
  The values `s_inv_jwt` and `R_jwt` are now restricted to the range accepted by ECDSA.
  This affected the circuits `c0200_swiyu_jwt` and `c0202_sicpa_backend_constant`.
]

#finding("02", [Non-revocation circuit does not authenticate the credential identifier],
  status: "scope")[
  This is expected: the circuit `c06` is specifically created to measure _only_ the
  non-revocation part of the full proof.
  As such it is normal that it doesn't verify the validity of the credential itself.
  However, the circuit `c06` _does_ verify that the revocation list itself is signed
  by the issuer.
  The goal of this circuit is to show the time necessary to add a revocation check
  directly in the proof.
]

#finding("03", [Range decomposition values are not constrained to be Boolean],
  fix: [#commit("spartan-backend", "936c819"), #commit("spartan-backend", "794b920")])[
  The bit values of the `RANGE` decomposition are now constrained,
  using `to_bits_le_strict` to enforce the value range.
]

#finding("04", [Noncanonical scalar decompositions change MSM results])[
  Fixed.
]

#finding("05", [An infinity and zero x coordinate collision produces false MSM results],
  fix: commit("spartan-backend", "d4e2caf"))[
  The infinity branches for the EC addition are now properly selected.
]

#finding("06", [Point at infinity handling breaks valid curve operations],
  fix: commit("spartan-backend", "166aba3"))[
  The infinity handling has been fixed for the ACIR to Spartan conversion and for the MSM.
]

// TODO: the comments say "To Be Fixed"
#finding("07", [Constant folding compiles P256 MSMs to incorrect results], status: "open")[
  To be fixed, does not apply to our proof-of-concept circuits c0200 and c0202.
]

=== Medium

// TODO: no answer in the comments yet
#finding("08", [Fixed base MSM offset collisions can produce incorrect results],
  severity: "medium", status: "open")[
  Affects `allocated_point.rs`, `constant_point.rs`, and
  `blackbox/multi_scalar_multiplication.rs` in `spartan-backend/src/noir/synthesis`.

  Does not affect our proof-of-concept circuits c0200 and c0202, but might
  pose problem in more generic circuits.
]

#finding("09", [Missing digest reduction prevents some valid issuer signatures from being verified],
  severity: "medium", fix: commit("spartan-backend", "30ed18e"))[
  The digest is now reduced.
  While fixing this, we found two additional issues:
  - `Fields::lt` in our `noir-t256` code, which hasn't been used before, was wrong.
    This is fixed now.
  - `R.x` is a P-256 point coordinate, so it is already $< p$.
    It can still land in $[n, p)$ and be rejected as a non-canonical scalar,
    but only with probability $(p-n)/p approx 2^(-130)$.
    As this is negligible, unlike the $approx 2^(-32)$ probability of the digest case,
    it is left unreduced.
]

// TODO: the comments say "To Be Fixed"
#finding("0a", [MSM accepts scalars outside the canonical P256 domain],
  severity: "medium", status: "open")[
    Does not affect our proof-of-concept circuits c0200 and c0202, but might
    pose problem in more generic circuits.
]

#finding("0b", [Public return values are treated as private witnesses],
  severity: "medium", status: "scope")[
  This would be nice to have, but is not relevant in our setting.
]

=== Low

#finding("0c", [Birth date parsing and age checks do not enforce calendar semantics],
  severity: "low", status: "scope")[
  The cutoff date should be handed in as a public argument, calculated by the prover.
  This allows to prove different ages, and keeps the control in the prover app.
]

#finding("0d", [Prepared proving state and debug logs expose private witness data],
  severity: "low", status: "scope")[
  This needs to be noted in the assumptions: the mobile device must store the proving
  state in a private data part.
  It remains to be seen if the
  #link("https://developer.android.com/training/data-storage#filesInternal")[Internal Storage]
  is big enough, or if External Storage and encryption is needed.
]

=== Informational

#finding("0e", [Partial base64url chunks use bytes beyond the logical payload],
  severity: "info", fix: commit("spartan-backend", "9f91bfa"))[
  The bytes beyond `in_len` are now replaced with 0.
]

=== Known Issues

#finding("0f", [Curve operations do not enforce P256 point membership],
  severity: "known", fix: commit("spartan-backend", "85bdc3e"))[
  The P256 membership of the points is now constrained.
]

#finding("10", [The demonstration verifier does not enforce policy or presentation freshness],
  severity: "known", status: "scope")[
  The verifier is only a demonstration and is not part of our attacker model.
]

// TODO: the comments say "To Be Fixed with other issues"
#finding("11", [Unchecked P256 points can be folded into false curve statements],
  severity: "known", status: "open")[
  To be fixed together with the other P256 issues.
]
