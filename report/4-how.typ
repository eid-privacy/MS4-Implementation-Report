#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= If you want to use our code

== Assumptions / Caveats <how-assumptions>

#todo[Write]
- issuer is trustworthy
- issuer is authoritative on the data being signed (it does not sign or use input from an adversarial holder).
- copy from security report

<<<<<<< Updated upstream
== Code Repositories / Documentation

#todo[Write]
=======
== Repositories (Ca)

// DRAFT
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

=== Main work

- [spartan-backend](https://github.com/eid-privacy/spartan-backend): Noir with the Spartan/Vega proof system
- [zkp-pocs](https://github.com/eid-privacy/zkp-pocs): Collection of circuits (Noir with UltraHonk/Barretenberg)
- [flakes](https://github.com/eid-privacy/flakes): Utility repository with precompiled packages for Nix and Devbox

=== Benchmarks

- [zkp-android](https://github.com/eid-privacy/zkp-android): Mobile test app for benchmarking Noir with UltraHonk/Barretenberg
- [zkp-android-spartan](https://github.com/eid-privacy/zkp-android-spartan): Mobile test app for benchmarking Noir with the Spartan/Vega proof system

=== Publications

- [eid-privacy](https://github.com/eid-privacy/eid-privacy.github.io): Our blog posts

=== Related work

- [zkp-vault](https://github.com/eid-privacy/zkp-vault): Collection of related work
>>>>>>> Stashed changes


== Use in Mobile

#todo[Write]

If you want to use it.

== Proof and verification pipelines

- Prover receives verification requests containing public, verifier chosen parameters (including holder binding nonce)
- Prover populates circuits input by mapping high-level function parameters of the Noir circuit description
- A preprocessor is used to compute the points defined by Crescent for holder bindings and augment the prover's input set
- Prover uses `nargo-t256` a build from our forked Noir compiler relying on Tom-256 to map the inputs into individual "witnesses"
- Prover uses `spartan-backend` to:
  - Read Noir's ACIR and synthesize an R1CS instance from it
  - Read Noir's witness mapping and instantiate the R1CS with them
  - Evaluate the circuit
  - Compute the Vega proof for this circuit instance

This proof can then be verified by any verifier in possession of the same R1CS instance (i.e., synthesizing the same code with our synthesizer).

@fig-proof-pipeline summarizes the pipeline visually.

#let step-fill = rgb("#e8f0fe") // processing steps run by our tooling
#let data-fill = rgb("#fff4e5") // intermediate artefacts
#let check-fill = rgb("#e9f7ef") // final verification

#figure(
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

== Precomputation

Around July 2026, Microsoft updated and renamed the source code distributed under the name of `spartan` to align it with the more recent Vega publication @KS25 under the name `vega-prover`. These changes introduced a clearer API to allow for partial instantiation of circuits and thus, pre-computation of partial proofs.

We cascaded this capability to `spartan-backend` by adding a configuration file documenting which inputs of a circuit are expected to change at every circuit instantiation. As an example: the credential for a given holder is always the same, the challenger nonce is not. Our backend uses this to compute the partition of constraints that does not depend on these inputs. This partition represents the portion of the proof that can be pre-computed.

Concretely, the configuration file marks a few input wires as volatile, and the taint
propagates forward: a constraint is volatile as soon as one of its inputs is.
@fig-taint-partition illustrates this propagation on a simplified view of the c0200 circuit.

#figure(
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


With this in place we can optionally pre-compute e-ID presentations and at presentation time compute only the part that depends on the verifier's challenge for holder binding. This leads to a noticeable reduction in proving time but depending on the device computing the proof, loading precomputation is costly. For our c0200-swiyu-jwt circuit, precomputation's file size is around 1.5GB. It is to be noted as well that this intermediate proof contains sensitive information of the holder and needs to be stored in accordance.

== Technical Limitations

#todo[Write]

- speed depending on model
- pre-computation storage space

=== Complexity of Circuits

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

== Methodology

#todo[Write]

- measurements / platforms

== Security Review <how-security>

On the 24th of August, [zkSecurity](https://zksecurity.xyz) started
the security review of our proof-of-concept code.
We wrote the requirement for the review to include:

- our inclusion of the Spartan prover as a backend for noir
- the circuits we wrote for the proof-of-concept
  - for the Swiyu SD-JWT credential
  - for the SICPA case
- our proposal for the revocation list, including the circuit

After the allotted time, zkSecurity came back to us with the
report of their findings [ref?]:

- 8 high security findings which can allow a prover to cheat
  - 7 got fixed in the latest release of `spartan-backend`
  - 1 was deemed a misunderstanding of the scope
- 4 medium security findings which can produce incorrect results
  - 2 got fixed
  - 2 were not relevant for our work
- 2 low security findings
  - only relevant in a different attacker model than ours
- 1 informational finding which got fixed
- 3 known issues
  - 1 got fixed
  - 1 is not in our attacker model
  - 1 is not yet fixed
