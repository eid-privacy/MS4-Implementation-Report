= WHY - Specific Choices for Implementations

== Using noir (L / Cl)

=== Circuit Implementation (L)

- explain the goal of the full circuit
- public inputs
- witnesses
- issuer is trustworthy
- revocation (-> Appendix)

=== Compiler (Cl)

Noir is originally written and equipped to perform proofs and verifications on Aztec's blockchain.
Noir comes with a default proof system and implementation: UltraHonk's implementation in Barretenberg.
This proof system comes from the line of work on Plonk-ish proof systems and relies on the bn254-Grumpkin curve cycle constructed following a publication on the construction of such cycles @CK24.

Our interest lies in circuits and proofs systems that are efficient to compute for ECDSA verifications of JSON-style data blobs as defined in @SDJWT.
We used Noir compiler's parametrized architecture to introduced a new compilation-time configuration to change Noir's output circuit (ACIR)
from using bn254-Grumpking to using the scalar field of the Tom-256 curve @zkattest @tom256parameters.
An important note is that the P256 and Tom-256 curves do NOT form a cycle.
As such, some of Noir's architecture assumptions break down in local places.
This curve is especially designed to make computations in the P256 field (such as the ECDSA verification equation) efficient.
Our implementation is limited to elliptic curve addition and multi-scalar-multiplication, foregoing the Poseidon commitment as our circuits don't require this.
This implementation is only partial since a proper integration would imply a sizeable rework of Noir's achitecture as well as of its standard library, both build mostly with bn254 and curve cycles in mind.

== Spartan Backend (Cl)

- Noir default proof system is UltraHonk, a system with tradeoffs typical of blockchain scenarios: public setup, very short proofs, very fast verifications
- We elected to write a circuit synthesizer taking in Noir's ACIR to produce R1CS instances for Microsoft's Vega (Spartan at the time we started this work).
- include optimisations proposed by Cloudflare and Ubique

== SICPA Implementation (Cl)

- learnings from SICPA integration
- OpenId4VP can be conveniently extended
- Deploying prover/verifier requires more resources than typical micro-service pods (RAM + CPU)
- Precomputation costs a lot of storage and might not be an option for some providers
- There is need for formalizing the circuit distribution and certification channels for an actual deployment beyond embedding a circuit in the official builds.
== Mobile (Ca)

- Noir with MoPro (Barretenberg)
- Noir with Spartan
- Noir with Spartan and pre-computation
