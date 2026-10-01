#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= HOW - If you want to use our code

== Assumptions / Caveats (Cl / Li)<how-assumptions>

- issuer is trustworthy
- issuer is authoritative on the data being signed (it does not sign or use input from an adversarial holder).

== Code Repositories / Documentation (Ca)

How to use which repository for what job.

== Use in Mobile (Ca)

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

== Technical Limitations (\*)

- speed depending on model
- pre-computation storage space

=== Complexity of Circuits

- circuits are great and easy to understand
- some patterns used in everyday language can lead to very inefficient circuits
- Claude knew at least in one instance how to overcome this

== Optimisations Performed

During our work on the noir circuits, we encountered various places where
a normal implementation using standard programming techniques produced
very big circuits for the Spartan backend.
This is due to the way Spartan takes the ACIR code and converts it to
R1CS, specifically with regard to code which accesses variable-length
input arrays.

=== Index Passing as Private Input

In @how-assumptions we assume that the input JSON is correctly formatted
by the issuer, before it is signed.
For this reason we don't do a full JSON syntax check in our circuit, and
take advantage of this correctly formatted JSON to do the following:
instead of parsing the JSON and extracting various values, our circuit
let's the prover give the _position_ of the values to be extracted
as a private input.
The verifier can trust this position, even though it ignores it, as the
circuit makes sure that the JSON field pointed to at the position has
the required name.
This trick is also used in Spartan, and allows to avoid a full parsing
of the JSON, while preventing the prover from giving a wrong position
in the private input.

=== Barrel Shifter

In a circuit, "array index" isn't a pointer lookup like in normal code —
the compiler has to turn it into arithmetic constraints.
If the index is a compile-time constant, that's free:
it's just wiring `out[3] = src[1]`, decided at compile time.
But if the index is a runtime value (a witness, unknown until the prover runs),
the circuit can't "jump" to that slot.
It has to build logic that says, for every possible index value, "is this the one? if
so, copy it" — effectively a scan over all N positions for every single output element.

A standard for-loop uses `src[k - shift]` where `shift` is a runtime input.
That's a variable index, so for each of the N output bytes, the compiler emits
an ~N-sized selector over all possible source positions.
N outputs × N-sized lookup each ≈ O(N²) constraints.
Our input array is in the thousands of bytes, so N² blows up fast.

A barrel shifter never does a variable-index read.
It decomposes the shift into its bits (LOG of them, since shift is bounded —
here at most 128, i.e. 8 bits).
At each bit-step it shifts by a fixed power of two (1, 2, 4, 8, ...),
and those are compile-time constants baked into the unrolled loop (step
doubles each iteration, LOG is a compile-time generic, so the outer loop
is fully unrolled at compile time).
Indexing by a constant offset is free.
The only "runtime" part is a cheap `if bit == 1 { from } else { cur[i] }`
select per byte per step — O(N) work, done LOG times, so O(N·LOG) total —
roughly N·8 instead of N².

Instead of one big variable shift (expensive random access),
this does log2(max_shift) small conditional shifts by
fixed powers of two (cheap, since each is a constant-offset copy plus a select).

=== Base64 Encoder

The standard `noir_base64`
encoder uses a 192-cell alphabet lookup table per output character, which
dominates the cost of circuits that base64-encode kilobyte-scale buffers
(e.g. c0200's full SD-JWT payload).

Our base64 encoder emits plain integer arithmetic over a
statically-unrolled loop, so every byte access is a *constant* array
index and resolves to a direct witness reference rather than a memory
op.
Per 3-byte chunk we pay only the bit decomposition (a few u8 div /
mod ops) plus four 6-bit -> ASCII conditional selects.

=== Unconstrained Circuits

`device_pub_x_field` is an untrusted claim from an
unconstrained base64 decode; it is constrained below by re-encoding
with `fast_base64` and asserting the result matches
`device_key_x_bytes` byte-for-byte. Base64url is injective on
fixed-length byte arrays, so a matching encoding can only come from
the correct value -- the same soundness as an in-circuit decode,
without the cost of `noir_base64`'s decoder (which indexes a lookup
table by a witness; see OPTIMIZE.md).

=== Selective Disclosure Values

== Methodology (Ca / Li)

- measurements / platforms

== Security Review (Cl / Li)
