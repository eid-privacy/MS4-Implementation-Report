#import "common.typ": *

= HOW - If you want to use our code

== Assumptions / Caveats (Cl / Li)

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

#todo(assignee: "Cl")[Add a figure to show the steps visually]

== Technical Limitations (\*)

- speed depending on model
- pre-computation storage space

=== Complexity of Circuits

- circuits are great and easy to understand
- some patterns used in everyday language can lead to very inefficient circuits
- Claude knew at least in one instance how to overcome this
- Explain Barrel Shifter

== Methodology (Ca / Li)

- measurements / platforms

== Security Review (Cl / Li)
