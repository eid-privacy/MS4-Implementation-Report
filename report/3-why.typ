#import "common.typ": *

= WHY - Specific Choices for Implementations

We chose Noir to write out circuits for the following reasons:
#list(
  [Circuit accessibility to non-expert developers (with caveats)],
  [Circuit readability for auditing and review purposes],
  [Modular architecture allowing us to use it decoupled from the original proof system],
)

Noir's default proof system is UltraHonk @UltraHONK, a system designed for the typical trade-offs seen in blockchain scenarions.
The resulting proofs are short, verifying is very fast, and prover time is less of a concern.
One of the main con of UltraHONK for our work is that it requires a public setup, a cryptographic ceremony that is delicate to setup properly for
a public use case.


This section will expose how we used Noir in conjunction with a proof system that had more of the properties we are after for the Swiss e-ID.

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
This implementation is only partial since a proper integration would imply a sizeable rework of Noir's architecture as well as of its standard library, both built mostly with bn254 and curve cycles in mind.

== Spartan Backend (Cl)

Producing Noir's ACIR with Tom-256 representing values of the circuits enables us to use work from Srinath Setty on Spartan @S19 (and then Vega @KS25).
Spartan is attractive for its prover cost as well as capability to work with Tom-256.
Notably, it is used for holder binding in Crescent @FFL25 and we reproduce this approach in our work.
Spartan relies on bellpepper to synthesize R1CS instances of circuits.
Our contribution with the spartan-backend is the synthesis of Noir's compiled artifacts into R1CS instances.
Our backend then uses this R1CS instance to produce or verify a zero-knowledge proof as implemented by Vega.
R1CS being one of the most common ways to express NP-statements for zero-knowledge proofs, the synthesizer is some implementation away from
being able to interface with other proof systems ingesting such statements.

This architecture creates a lot of flexibility in the chain: Noir's ACIR could be synthesized by another piece of software (nothing exists at the time of writing)
and mathematically speaking, the R1CS instance resulting of the synthesis and instantiation could be ingested by other proving backends reyling on R1CS.

=== Noir's artifacts and bytecode

- ACIR Json files
  - Caveat on comparing ACIR number of constraints and R1CS. They are not 1-to-1
- Input 

=== Build and proof chain

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
