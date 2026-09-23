= WHY - Specific Choices for Implementations

== Using noir (L / Cl)

=== Circuit Implementation (L)

- explain the goal of the full circuit
- public inputs
- witnesses
- issuer is trustworthy
- revocation (-> Appendix)

=== Compiler (Cl)

As our interest is in optimizing circuit evaluation and proof computation for ECDSA verifications,
we introduced a new compilation-time configuration to have Noir produce its intermediary circuit representation (ACIR)
using the scalar field of the Tom-256 curve (cite ZKAttest, neuromancer.sk), especially designed for ECDSA's field arithmetic to be efficient.
This change also requires the implementation of a "blackbox" used for circuit evaluation by noir.
This stage evaluates the whole circuits a populates the prover's witness and public inputs.
Our blackbox implementation is limited to elliptic curve addition and multi-scalar multiplication, foregoing the Poseidon commitment implementation.

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
