#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Specific Choices for Implementations

We chose Noir to write out circuits for the following reasons:

- Circuit accessibility to non-expert developers (with caveats)
- Circuit readability for auditing and review purposes
- Modular architecture allowing us to use it decoupled from the original proof system

Noir's default proof system is UltraHonk @UltraHONK, a system designed for the typical trade-offs seen in blockchain scenarions.
The resulting proofs are short, verifying is very fast, and prover time is less of a concern.
One of the main con of UltraHONK for our work is that it requires a public setup, a cryptographic ceremony that is delicate to setup properly for
a public use case.

This section will expose how we used Noir in conjunction with a proof system that had more of the properties we are after for the Swiss e-ID.

== Using noir

After MS2, we decided to pursue the ZKP-circuit venue instead of relying solely
on sigma proofs.
Noir is still the most complete and supported app to create ZKPs in a
user-friendly way.
It is also very extensible, which allowed us to change the prover backend,
and improve the speed to create a ZKP.

=== Circuit Implementation

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
#let salt_dob = $"DoBSalt"$
#let base64_dob = $"DoBBase64"$
#let pos_dob = $"DoBPos"$
#let revocation_list = $"Revocation List"$
#let timestamp_now = $"Current Date"$
#let timestamp_dob = $"Date of Birth"$
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
  [Secret inputs], [
    - #credential of the holder
    - #pos_dob - positions of the elements in the credential
    - #salt_dob - salt of the date of birth
    - #timestamp_dob
    - pre-computation of #Sig_cred
  ],
  [Public inputs], [
    - #Pub_issuer
    - #timestamp_now
    - pre-computation of #Sig_ch
  ],
  [Derived in the circuit], [
    - #Pub_holder from #credential
    - $#hash_credential = "Sha256"(#credential)$
    - $#hash_dob = "Sha256"(#salt_dob | #timestamp_dob)$
    - $#base64_dob = "base64.encode"(#hash_dob)$
  ],
  [Statements],[
    - #Sig_valid([#Pub_holder], [#Sig_ch], [#challenge])
    - #Sig_valid([#Pub_issuer], [#Sig_cred], [#hash_credential])
    - $#base64_dob == #credential [#pos_dob:]$
    - $#timestamp_dob + "18 years" <= #timestamp_now$
  ]
)

The code to write this proof is understandable by a software engineer without
having to understand the deep cryptographic improvements.
This is an important step to make ZKPs go from a
_magical cryptography problem_ to an actual use-case which can be implemented
and used in everyday's applications.
One thing we did not include in this code is the _revocation_, which is
described in @why-opt-revocation.

=== Compiler

Noir is originally written and equipped to perform proofs and verifications on Aztec's blockchain.
Noir comes with a default proof system and implementation: UltraHonk's implementation in Barretenberg.
This proof system comes from the line of work on Plonk-ish proof systems and relies on the bn254-Grumpkin curve cycle constructed following a publication on the construction of such cycles @CK24.

Our interest lies in circuits and proofs systems that are efficient to compute for ECDSA verifications of JSON-style data blobs as defined in @SDJWT.
We used Noir compiler's parametrized architecture to introduced a new compilation-time configuration to change Noir's output circuit (ACIR)
from using bn254-Grumpkin to using the scalar field of the Tom-256 curve @zkattest @tom256parameters.
An important note is that the P256 and Tom-256 curves do NOT form a cycle.
As such, some of Noir's architecture assumptions break down in local places.
This curve is especially designed to make computations in the P256 field (such as the ECDSA verification equation) efficient.
Our implementation is limited to elliptic curve addition and multi-scalar-multiplication, foregoing the Poseidon commitment as our circuits don't require this.
This implementation is only partial since a proper integration would imply a sizeable rework of Noir's architecture as well as of its standard library, both built mostly with bn254 and curve cycles in mind.

== Spartan Backend <why-spartan>

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

=== Build and proof chain

Here are the steps a prover would execute with noir when doing a ZKP
for example to prove their age is equal or above to 18 years:

- Prover receives verification requests for their age, including holder binding nonce
- Prover populates circuits input by mapping high-level function parameters of the Noir circuit description, using our modified `nargo-t256` tool, a build from our forked Noir compiler relying on Tom-256
- A preprocessor is used to compute the points defined by Crescent for holder bindings and augment the prover's input set
  this is necessary because to prove an ECDSA signature in Spartan, the inputs have to be modified
- Prover uses `nargo-t256 execute` to map the inputs into individual "witnesses"
- Prover uses `spartan-backend` to:
  - Read Noir's ACIR and synthesize an R1CS instance from it
  - Read Noir's witness mapping and instantiate the R1CS with them
  - Evaluate the circuit
  - Compute the Vega proof for this circuit instance

This proof can then be verified by any verifier in possession of the same R1CS instance (i.e., synthesizing the same code with our synthesizer).

== Optimisations Performed <how-opt>

During our work on the noir circuits, we encountered various places where
a normal implementation using standard programming techniques produced
very big circuits for the Spartan backend.
This is due to the way Spartan takes the ACIR code and converts it to
R1CS, specifically with regard to code which accesses variable-length
input arrays.

=== Index Passing as Private Input <how-opt-index>

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

=== Barrel Shifter <how-opt-barrel>

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

=== Base64 Encoder <how-opt-base64>

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

=== Brillig Circuits <how-opt-brillig>

Noir allows circuits to use external code whose results is put back
into the circuit.
This can improve circuit speed, but needs some special handling, as
the returned value needs to be checked to be correct.
A simple example is factorisation: given $c = a * b$, if $c$ is an
input to the circuit, it is very expensive to calculate $a$ and $b$.
However, an external circuit can do this calculation fast (depending
on the size of $c$ of course), and return $a$ and $b$ to the circuit.
Now the circuit can verify if $c == a * b$ and abort if this is not
the case.

In our circuit, the public key of the device is in the SD-JWT
credential and stored as base-64.
While encoding a binary stream into base64 is very fast, decoding produces
big circuits.
For this reason, our circuit does the following:

- private input: position of the public key
- call out to external program: verify the position and return the
  decoded key as a binary blob
- retrieve the decoded key, encode it again, and verify that it's
  the same

While it looks more complicated from an external view, the fact that
encoding is much cheaper than decoding makes this output a smaller
circuit.

=== Selective Disclosure Values <how-opt-sd>

In the SD-JWT standard, the signature of the issuer is not done on
the data itself, but on a hashed version of the salted data.
This allows a prover to selectively disclose values by providing
the credential holding the hashes, plus the salt and the data.
The verifier can then check that the hash is correct, and that the
issuer's signature on the hashes works out.

#let salt_dob = $"DoBSalt"$
#let timestamp_dob = $"Date of Birth"$

For our circuit, this is advantageous, as the hashed part of the SD-JWT
is fixed size, and only the values and salts change.
The signature of the issuer is only calculated over the fixed size,
so the circuit also only has to verify the signature over this fixed
part.
Our circuit uses the date of birth, which can be entered into the
circuit as a private input, together with its salt.
The circuit then calculates $"Sha256"(#salt_dob | #timestamp_dob)$ and
matches it against the corresponding line in the fixed part of the SD-JWT.
Given that $"Sha256"$ is a cryptographic hash, it is deemed impossible
for the prover to cheat and produce another value for the $#timestamp_dob$
than what the issuer signed.

=== Holder Binding <holder-binding>

We used the proposal from Crescent @FFL25 for holder binding. Making $R$ a public input and computing public points based on the verifier challenge allows for most
of the holder binding cost to be paid outside of the circuit -- a way more efficient
computation.
The verification functions as follows, this is borrowed directly from Crescent's
section on holder binding (Section 3.4.1, "ECDSA Signature Proof" in @FFL25).

==== Definitions

Following Crescent, the curve group is written multiplicatively:

- $G$, the generator of the NIST P--256 group, of order $n$.
- $d$, the device private key, generated and kept inside the secure element.
- $Q = G^d$, the device public key. This is what we aim at keeping secret to prevent linkability.
- $f(dot)$, the function taking a curve point and returning its $x$--coordinate.
- $M$, the message signed by the device during the presentation, i.e. the fresh
  challenge chosen by the verifier, already hashed and converted to an integer
  modulo the group order.
- $(r, s)$, the ECDSA signature produced by the secure element over $M$, with
  $r = f(R)$ and $R$ the nonce point sampled for this signature.

==== Modified verification equation

The original ECDSA verification equation is

$ r = f(Q^(r slash s) G^(M slash s)) $

Given $(R, s)$ instead of $(r, s)$, where $R = f^(-1)(r)$, the verifier can recompute
$r = f(R)$ itself and check the equivalent statement $R = Q^(r slash s) G^(M slash s)$,
which can be re-written as

$ T^s U = Q quad "where" quad T = R^(1 slash r) quad "and" quad U = G^(-M slash r) $

Since $M$ is public and $R$ is a random value that carries no information about the
private key, the prover can reveal $R$ and the verifier can recompute $(T, U)$ on its
own. The circuit is then only asked to check $T^s U = Q$ with the additional public
inputs $(T, U)$ and the private input $s$, which costs a single scalar multiplication
and a single point addition.

This is what makes the construction a good fit to optimize our proposal. Additionally,
as in Crescent, we instantiate this proof with Spartan over the Tom--256 curve @tom256parameters,
whose group order is the P--256 prime, so that all group operations have efficient arithmetic circuits and a
scalar multiplication takes approximately 2700 R1CS constraints @FFL25.

=== Revocation Lists <why-opt-revocation>

As described in [ref-MS2-revocation], we decided to not use any
advanced cryptographic accumulators because of the overhead
necessary by the clients to keep their witnesses up-to-date.
Instead we started to use the revocation lists in the Swiyu
project, but had to abandon their protocol because the list itself
was compressed, and decompression inflates the circuit size
too much.
For this reason we went with a simpler approach, keeping the
list uncompressed, but signed by the issuer.
Here is the format of this simplified revocation list:

#table(
  columns: (auto, auto, auto),
  table.header([Name], [Size [B]], [Description]),

  [`ID_START`], [8], [The first `CRED_ID` described in this list],
  [`EXPIRES_AT`], [8], [Seconds since the Unix Epoch where this list expires],
  [`REV_LIST`], [128], [Bit-field of revoked credentials - 0: non-revoked - 1: revoked],
  [`SIG`], [64], [ECDSA signature on the first part of this list]
)

In addition to this list, every credential now needs a unique
`CRED_ID`, ideally incrementally starting from 0.
As the credential itself is never revealed, this `CRED_ID`
does not pose a danger to the anonymity of our system.
When creating a prove, the client needs to download the
corresponding revocation list from the server.
We did not consider the privacy implication of this request,
but techniques like "Private Information Retrieval" can make
this retrieval oblivious to the server.
The circuit needs to perform the following tests so that the
verifier can be convinced of the non-revocation of this
credential:

- `ID_START` $<=$ `CRED_ID` $<$ `ID_START` $+$ `1024`
- `TIMESTAMP_NOW` < `EXPIRES_AT`
- `REV_LIST[CRED_ID - ID_START] == 0`
- `ECDSA_VERIFICATION(LIST, SIG, PUB_KEY) == TRUE`

The most expensive operation in this list is the ECDSA
verification, as it also contains a `SHA256` operation,
and both are very expensive.

== SICPA Implementation

SICPA's platform models users as agents in control of their own keys, which are not hosted within reach of the proving software we want to deploy.
This replicates closely the setup we have on a phone with the key in the Android's secure element.

One of the big question we're still trying to work on with this integration is the cost of operating such ZKP infrastructure at a reasonable speed.
Allocating a full vCPU and 10GB of RAM to the deployment of the ZKP tooling still results in proving and verification speed in the order of 30 seconds
each.
Therefore it is clear that a thorough follow-up analysis of the cost/speed trade-offs and types of deployment must be conducted based on each individual
use-cases.
The biggest divide being between high-volume-low-margins credential presentations industries and low-volume-high-margins ones.
Working on the integration with OpenId4VP was not a big hurdle as some of the structures can be conveniently extended with a new proof type but it also
became clear that a ZKP ecosystem needs a reliable distribution channel for circuits and acceptable public parameters ranges to prevent outdated or malicious circuits
execution (e.g., a verifier distributing a ZKP circuit that requests oversharing from the prover).
Such a distribution channel should complement the verifier's registry described in Swiyu @Swiyu.
A point we analyzed late in the project and would deserve more experimentation is the use of precomputation. While storing a large file of precomputation securely
on a phone is in the realm of realistic implementations, doing so for a high number of credentials, without risking leaking witness values, and ensuring that loading
the precomputation does come at a cost that offsets the benefit of precomputation is no trivial matter.

== Mobile

For our zero-knowledge proof system to have an impact in the real world, most notably as part of a future version of Switzerland's Swiyu app, we need to
demonstrate that it can be executed on a mobile device in realistic time.

The proof generation needs to be executed on the fly each time the holder wants to present their credential. It is therefore critical for user experience
and widespread adoption that its runtime remains low, i.e. a maximum of 1 second. As parts of the proof are common across different challenges and individual
credentials, we implemented an initial optimization that partially precomputes the proof, so that only the missing parts need to be computed when the
credential is used.

For the test device, we chose a consumer-grade device that is a few years old and running the Android operating system, as it is the most widespread mobile
operating system @android.

We created two Android apps, one for the UltraHonk/Barretenberg and one for the Spartan/Vega proof systems. For the former, we were able to use the Mopro
framework @mopro to connect the Rust library that instantiates and executes the zero-knowledge proofs with the Android platform. For the latter, we needed
to create the foreign-language bindings ourselves using Mozilla's UniFFI tool @mozillaUniFFI.

The resulting Android apps allow us to test individual circuits as well as to run benchmarks to gain insights into the expected average performance.
