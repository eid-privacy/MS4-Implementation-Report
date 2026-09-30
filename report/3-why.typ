#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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

The figure @fig-zkp-overview shows an illustration of the different parts
of a ZKP.
It is important to note that there is information known to both
the prover and the verifier, namely the statement itself, as well
as a set of public inputs, e.g., the public key of the issuer.
Other inputs are private and will not be available to the verifier -
only the final proof is available to the verifier, and the properties
of the ZKPs make that the verifier cannot learn more information about
the private data than the statement reveals.
So if the statement tests if the given credential has a birthdate of
more than 18 years in the past, the proof reveals that fact, but not
more.

#figure(
  diagram(
    mark-scale: 1.5,
    spacing: (1.5em, 1.1em),
    node-stroke: 1pt,
    node((-1.5, -0.5), [*Prover*], stroke: none),
    node((1.5, -0.5), [*Verifier*], stroke: none),
    // Invisible node to keep the prover and verifier halves symmetric
    node((2, 2.4), [], stroke: none),
    edge((0, -0.8), (0, 6.5), "--", stroke: 1pt, layer: -1),
    node((0, 0.5), [Public data], fill: white, name: <public>),
    node((0, 2), [Statement], stroke: none, name: <stmt-label>),
    node((-0.5, 2.8), height: 1cm, [Derived #linebreak() data], fill: white, stroke: (dash: "dashed"), name: <derived>),
    node(
      enclose: ((-0.8, 2), (0.8, 2), <stmt-label>, <derived>),
      fill: luma(240),
      name: <statement>,
    ),
    edge(<public>, <statement>, "->"),
    node((-2, 2.4), [Secret data], stroke: none, name: <secret>),
    edge(<secret>, <statement>, "->"),
    edge((-0.5, 3.15), (1.3, 3.15), "->", bend: -50deg, label: [Proof $pi$], label-side: right),
  ),
  caption: [High-level overview of a ZKP: the prover proves a statement over
    secret and public data, possibly deriving new data inside the statement,
    and sends the resulting proof to the verifier.],
) <fig-zkp-overview>

#let Pub_holder = $"Pub"_"holder"$
#let Pub_issuer = $"Pub"_"issuer"$
#let challenge = $"Challenge"$
#let credential = $"Credential"$
#let hash_credential = $"CredHash"$
#let hash_dob = $"DoBHash"$
#let revocation_list = $"Revocation List"$
#let timestamp_now = $"Current Date"$
#let timestamp_dob = $"Date of Birth"$
#let salt_dob = $"Salt DoB"$
#let Sig_cred = $"Sig"_"cred"$
#let Sig_ch = $"Sig"_"ch"$
#let Sig_list = $"Sig"_"list"$
#let Pr_holder = $"proof"_"holder"$
#let Pr_sig_ch = $"proof"_#Sig_ch$
#let Pr_Pub_holder = $"proof"_#Pub_holder$
#let Pr_sig_cred = $"proof"_#Sig_cred$
#let Pr_predicate = $"proof"_"predicate"$
#let Pr_non-rev = $"proof"_"non-rev"$
#let Sig_valid(pub, sig, msg) = $"signature_valid"( #pub, #sig, #msg )$

The different parts of the ZKP we produced for this projects
are the following:

#table(
  columns: 2,
  table.header([Argument], [Elements]),
  [Secret], [
    - #credential of the holder
    - positions of the elements in the credential
    - #salt_dob - salt of the date of birth
    - #timestamp_dob
    - pre-computation of #Sig_cred
  ],
  [Public], [
    - #Pub_issuer
    - #timestamp_now
    - pre-computation of #Sig_ch
  ],
  [Derived], [
    - #Pub_holder from #credential
    - $#hash_credential = "Sha256"(#credential)$
    - $#hash_dob = "Sha256"(#salt_dob | #timestamp_dob)$
  ],
  [Statement],[
    - #Sig_valid([#Pub_holder], [#Sig_ch], [#challenge])
    - #Sig_valid([#Pub_issuer], [#Sig_cred], [#hash_credential])
    - $#timestamp_dob + "18 years" <= #timestamp_now$
  ]
)

- explain the goal of the full circuit c0200
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

For our zero-knowledge proof system to have an impact in the real world - most notably as part of a future version of Switzerland's Swiyu app - we need to
demonstrate that it can be executed on a mobile device in a realistic time.

The two steps of the zero-knowledge proof system that are executed on a user's phone are the generation of the proof and its verification. Both the generation
as well as the verification will need to be executed on the fly each time the holder wants to present their credential. It is therefore critical for user
experience and widespread adoption that their runtime remains low. To this end, we optimized proof generation: as parts of it are common across
different challenges and specific credentials, the proof can be partially precomputed and only the missing part computed on the fly.

For the test device, we choose a consumer-grade device of medium age and the Android operating system as it is the most widespread mobile phone operating
system @android.

We created two Android apps, one for each of the backends. For the Barretenberg backend, we were able to use the Mopro framework @mopro to make the link
between the Rust library instantiating and executing the zero-knowledge proofs and the Android platform. For the Spartan/Vega backend, we needed to create
the foreign-language bindings ourselves using Mozilla's UniFFI tool @mozillaUniFFI.

The resulting Android apps allow us to test individual circuits as well as running benchmarks to gain insights into the average expected performance.
