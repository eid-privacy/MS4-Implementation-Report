#import "common.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Overview of our Solution <what>

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

== Comparison with Other Solutions

As discussed in our first report @MS2-rep, we distinguish the
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

In order to open ZKP for problems which are difficult to solve with a
combination of sigma protocols, e.g., proving that a JSON witness
has the correct form, it is necessary to describe the problem in a more
abstract form.
[ref-BCGTV13] creates a modified C-compiler which can compile a subset
of C instructions to be run on a random-access machine called `TinyRAM`.
The novelty in this approach is that this allows to express _any_ algorithm
which can be written in C to be proven as a ZKP.
In addition, the number of engineers knowing how to write C programs is
vastly superior compared to the number of engineers knowing how to
use sigma protocols.

#figure(
  diagram(
    spacing: (3em, 2em),
    node-stroke: 1pt,
    node((0, 0), [C program], name: <c-program>),
    node((0, 1), [TinyRAM], name: <tinyram>),
    node((0, 2), [R1CS], name: <r1cs>),
    node((0, 3), [zk-SNARK], name: <zksnarg>),
    edge(<c-program>, <tinyram>, "->"),
    edge(<tinyram>, <r1cs>, "->"),
    edge(<r1cs>, <zksnarg>, "->"),
  ),
  caption: [Compilation pipeline from a C program down to a `zk-SNARK` proof.],
) <fig-zkp-circuit-pipeline>

The figure @fig-zkp-circuit-pipeline shows the pipeline showing how a C
program is compiled to the `TinyRAM` virtual architecture, which is
rewritten as a `R1CS` circuit, and finally proven using a `zk-SNARK`.
This model from 2013 has been much refined in the meantime, specifically
the following elements have been updated:

- input: instead of a subset of the C language, tools like `noir` allow
  a much higher-level input
- intermediate representation: the `TinyRAM` has been optimised and replaced
  by various other representations. `noir` uses `ACIR`, which is already
  closer to `R1CS` than `TinyRAM`. `R1CS` is still widely used as the
  representation which is then fed to the prover
- prover: while this early prover was based on a `zk-SNARK` using PCP,
  the landscape has become much more diverse with new additions which
  need less setup and have faster proving and verification times

=== ZKVMs

While ZKP-circuits are based on a specific language which is compiled
with a special compiler, ZK Virtual Machines (ZKVM)s go one step further
and implement a full von Neumann architecture with the possibility to
create a ZKP.
OpenVM [ref-OpenVM] goes one step further and proposes a
_modular no-CPU architecture_ - modules can be added to provide
RISC-V support, but also specific operations often used in ZKPs.
This setup allows the combination of the best of circuits and
sigma proofs: using circuits, OpenVM provides support for generic
programming, using sigma proofs (or other) modules, OpenVM allows
optimised proofs where it matters, e.g., ECDSA signatures, hashing,
and other specialised cryptographic primitives.

The latest benchmarks we found shows that a signature verification using
OpenVM is only 10x slower than the same verification with `noir`
or a special sigma-proof.

== Use case examples <what-use-cases>

This section is an exploration of possible use-cases with ZKPs
on standard SD-JWT credentials.
During this project, we only implemented the age verification and the
non-revocation (see @why-opt-revocation) as circuits (see @what-code),
and SICPA integrated the age verification in its cloud wallet
(see @what-sicpa).
The other examples are not implemented, but they all rely on the same
building blocks: parsing the SD-JWT, verifying the signature of the
issuer, checking the holder binding, and the non-revocation.
Only the statement on the disclosed values changes from one use case
to the other.
One missing building block which is not yet clear is how to link several
credentials together:
If you have a credential from your commune, it needs to be tied to your
governmental e-ID.
Will this be done using the full name and the birthdate?
Or using the AHV number?
This is not yet clear in the current implementations, and future use
cases will show how this is done.

The Swiyu project itself lists the following uses which are expected from the
introduction of the e-ID onwards @SwiyuCh:

- Proof of age
- Open a bank account
- Obtain electronic signatures
- Register in the organ and tissue donation register
- Subscribe to a mobile plan
- Use the nationwide government login
- Order an extract from the criminal record
- Found a company

Possible future uses are ordering a debt collection register extract,
and electronically signing popular initiatives and referendums.

Many of these uses, like opening a bank account or subscribing to a
mobile plan, require by law a full identification of the holder, so
a ZKP does not bring much there.
But the proof of age is the first one in the list, and the
extracts from the criminal record and the debt collection register
will become credentials themselves.
These credentials are then shown to third parties, e.g., a future
employer or a landlord, and a ZKP allows to show only what the
third party needs to know.
The table @tbl-use-cases lists the types of statements we identified,
starting with the most probable ones.
It is to be noted that this supposes that the user has the needed
additional credentials, because the governmental e-ID does not contain
most of the information described in this table.

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    table.header([Statement type], [Examples]),

    [Threshold on a date],
    [Over 18 or over 16 for buying alcohol or accessing online platforms,
      e.g., to comply with the Swiss youth protection law for films and
      video games.
      Under 26 for youth tariffs, over 65 for senior reductions.
      Driving license held for more than 2 years for renting a car.
      Credential is not expired, without revealing the expiry date.],

    [Empty or negative statements],
    [The criminal record extract has no entries, e.g., for a job
      application.
      The debt collection register extract has no entries, e.g., for
      renting an apartment.
      The credential is not on the revocation list.],

    [Pseudonyms and uniqueness],
    [One signature per person and per popular initiative or referendum:
      the circuit proves the Swiss nationality, the age over 18 and the
      residence in the commune, and outputs a pseudonym derived from
      the credential and the initiative.
      The same pseudonym can be used for one account per person on a
      platform, or for anonymous polls.],

    [Set membership],
    [The postal code belongs to a commune, e.g., for resident
      discounts at the swimming pool or for a parking permit.
      The nationality is in the EU/EFTA.
      The residence permit is a B or C permit, without revealing the
      nationality.
      The driving license includes category B.],

    [Threshold on a number],
    [The taxable income is below a limit, e.g., for health insurance
      premium reductions, the KulturLegi, or daycare tariffs.
      The salary is above a given amount, e.g., for renting an
      apartment.
      These examples are speculative, as there are no plans for tax or
      employer credentials yet.],
  ),
  caption: [Types of statements which could be proven with a ZKP on
    SD-JWT credentials, starting with the most probable ones.],
) <tbl-use-cases>

The examples in @tbl-use-cases involve credentials from many different
issuers: the federal e-ID as root of trust, other federal services like
the criminal record and the driving license, the cantons and communes
for the address and the debt collection register, schools and
universities, health insurances and employers.

This is where the ZKP circuits show their strength compared to
sigma proofs.
With sigma proofs, every row of @tbl-use-cases needs a different
protocol: range proofs for the thresholds, accumulators or
OR-proofs for the set membership, verifiable random functions for the
pseudonyms, and equality proofs for linking credentials.
Combining these protocols in a secure and efficient way needs
specialised cryptographic knowledge, and every new issuer would have
to adopt a new credential format.
With Noir, every row is a small function on top of the common
building blocks, which an IT professional can write and an auditor
can review.
The pseudonym for popular initiatives, for example, is a hash
of a secret from the credential and the identifier of the
initiative, computed in a few lines of code next to the checks for
the nationality, the age, and the commune.

== SICPA Integration <what-sicpa>

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

== Benchmarks

For this report, we benchmarked the performance of the proof creation step of two implementations of a Swiyu SD-JWT age proof,
including issuer and holder binding but excluding non-revocation.

Both implementations are written in Noir: one using the default proof system UltraHonk as implemented in Barretenberg,
and the other using the Spartan proof system, now known as Vega.

=== Mac

On desktop, we evaluated the two implementations on a MacBook Pro from 2023 with an Apple M2 Max CPU and 64 GB of RAM. While
the zero-knowledge proof is ultimately destined to be integrated into the Swiyu mobile application, the performance measured
on such a machine gives us an idea of what to expect on a less powerful device.

==== UltraHonk/Barretenberg

UltraHonk, as implemented by Barretenberg, is the default proof system used by Noir. It was therefore an obvious first
step to evaluate the performance of such circuits.

#table(
  columns: 2,
  [Noir test], [create_proof [s]],
  [d10_swiyu_jwt], [3.10],
)

Surprisingly, the overall performance on the MacBook for this
circuit is not significantly worse than that of the circuit using the Spartan/Vega proof system. However, we notice
considerable differences in performance on mobile devices between the two circuits, suggesting that the underlying system
architecture may play a role.

==== Spartan/Vega

For the Spartan and Vega proof systems, we evaluated the `c0200_swiyu_jwt` circuit from our `spartan-backend` Rust module at
commit 4229482.

#table(
  columns: 4,
  [], [Average of 5 runs [s]], [Best [s]],
  [c0200_swiyu_jwt], [3.774], [3.692],
  [c0200_swiyu_jwt (partially precomputed)], [2.889], [2.833],
)

Precomputing the partial proof takes on average about 5 seconds and generates a file of about 1.5 GB. This has important
practical implications, not only for devices with limited storage, but it also means that the finalisation of the proof
is dominated by the time spent reading the data from the device, about 2 seconds on average, or over a third of the
total runtime of this step. While overall a significant speedup is achieved (23% on the MacBook), we will see that this
has a considerable impact on the user experience on the mobile phone.

=== Mobile

While measuring the performance of our circuits on a mobile phone might at first glance seem like the next logical
step, it is in reality a major milestone in our efforts to add zero-knowledge proofs to the Swiss e-ID ecosystem.

The existing privacy-preserving digital credentials, Crescent and Longfellow, rely on specialised credential formats
to achieve their impressive proof verification times of under one second. We, on the other hand, are able to use the
standard SD-DWT through a Noir circuit, which is a major prerequisite for integrating zero-knowledge proofs into the
Swiss e-ID.

For both the UltraHonk/Barretenberg and Spartan/Vega implementations, we used a Samsung Galaxy A54 running Android 16 ("Baklava")
with 8 GB of RAM and an octa-core CPU @galaxy-a54.

==== UltraHonk/Barretenberg

We evaluated the circuit `d10_swiyu_jwt` from the `zkp-pocs` library (commit d58bc79) @EIDBlogMobile. In addition to the proofs
of concept, this library contains a variety of example circuits, one of which is `d10_swiyu_jwt`, a full Swiyu SD-JWT age proof
with issuer and holder binding, but excluding the non-revocation proof.

#table(
  columns: 4,
  [], [Average of 100 runs [s]], [Best [s]], [Worst [s]],
  [d10_swiyu_jwt], [18.419], [16.154], [21.013],
)

With an average runtime of 18.5 seconds, the verifiable SD-JWT credential clearly leaves much to be desired in terms of user
experience. However, successfully generating an SD-JWT credential proof on a mobile device marked a major step in moving our
endeavour from a theoretical undertaking to a practically applicable result.

==== Spartan/Vega

We evaluated the circuit `c0200_swiyu_jwt` from the `spartan-backend` Rust module (commit 4229482). Drawing on our previous
experience with the UltraHonk/Barretenberg-based Noir mobile application, we decided that five runs are sufficient to obtain a
clear picture of the average performance. Since the runtime lies in the range of several seconds, it can be assumed that is
dominated by the proof-generation computation itself rather than by brief load spikes caused by other processes.

#table(
  columns: 4,
  [], [Average of 5 runs [s]], [Best [s]], [Worst [s]],
  [c0200_swiyu_jwt], [11.793], [11.777], [11.813],
  [c0200_swiyu_jwt (partially precomputed)], [9.468], [9.329], [9.905],
)

As can be seen, precomputation reduces the average proof generation time during presentation by 2.446 seconds, or just below 20%,
which is a considerable speed-up. While this is impressive, it comes at a cost: the precomputed circuit takes up about 1.5 GB,
which is a considerable amount of space on consumer-grade mobile devices. Its initial precomputation takes up a little over 18
seconds, which is however not a problem, as it only has to be executed once during initial setup.

Furthermore, we also observed that the total proof generation time is dominated by the time spent reading from disk
(around 6 seconds). While this means that the proof generation itself is actually well over 20% faster, it also means that the
very approach used to achieve this improvement diminishes its benefit. Combined with the large size, this makes this particular
optimization rather impractical for user devices; however, it is a good indicator of the direction future optimizations may take.

== Related Works and concurrent events

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
- OpenAC @ENRT26 is a transparent anonymous-credential design that, like our work, requires no trusted
  setup and no modification of the issuer's credential-issuance flow.
  It follows the same prepare-and-prove paradigm as Vega, with a lightweight and reusable offline
  phase and device binding performed in-circuit.
  Its proof mechanism is based on sum-check with Hyrax-style vector commitments, which makes it the
  closest design to ours in terms of trust assumptions.
  The authors position their work against the other contenders along two axes: user experience and
  deployment (@tbl-openac-ux), and performance (@tbl-openac-perf).

#figure(
  table(
    columns: (auto, auto, auto, auto),
    table.header([Approach], [Offline phase], [Device binding], [Reusability]),

    [BBS/BBS+], [None], [Optional], [No],
    [Longfellow], [None], [Included], [No],
    [Crescent], [Lightweight, reusable prepare], [Optional], [Yes],
    [zk-creds], [Lightweight, reusable precompute & membership part],
    [Optional, clone resistance / anti-sharing], [Yes],
    [Vega], [Lightweight, reusable prepare], [Included], [Yes],
    [OpenAC], [Lightweight, reusable prepare], [Integrated (in-circuit)], [Yes],
  ),
  caption: [Comparison of related approaches with respect to user experience and deployment,
    reproduced from Table 2 of OpenAC @ENRT26.],
) <tbl-openac-ux>

#figure(
  block[
    #set text(size: 0.85em, hyphenate: false)
    #table(
      columns: 9,
      align: (left, right, right, right, right, right, right, right, center),
      table.cell(rowspan: 2)[Scheme],
      table.cell(colspan: 4, align: center)[Latency (ms)],
      table.cell(colspan: 3, align: center)[Size (kB)],
      table.cell(rowspan: 2)[Trans.],
      [Setup], [Precomp.], [Prove], [Verify], [Proof], [pk], [vk],

      [Longfellow], [7~235], [---], [680], [324], [325], [202], [202], [#sym.checkmark],
      [Crescent], [172~437], [14~725], [237], [118], [16], [710~565], [1], [#sym.times],
      [Vega#sub[SC]], [3~689], [238], [247], [55], [99], [6~562], [6~561], [#sym.checkmark],
      [Vega#sub[MC]], [193], [109], [212], [51], [150], [436], [436], [#sym.checkmark],
      [OpenAC], [4~193], [3~442], [102], [83], [149.7], [433~664], [433~664], [#sym.checkmark],
    )
  ],
  caption: [Performance comparison for a 1920-byte MSO, reproduced from Table 3 of
    OpenAC @ENRT26, which itself adapts the comparison published in Vega @KS25.
    The _Trans._ column indicates whether the setup is transparent.
    The Longfellow, Crescent and Vega figures were measured on an Azure Standard F16as v6 VM
    (16 vCPUs, 64 GB RAM), while the OpenAC figures were measured on a MacBook Pro M4
    (14-core GPU, 24 GB RAM), so the numbers are only indicative.],
) <tbl-openac-perf>

As with every cross-paper comparison, these numbers should be read with care: the measurements
were not taken on the same hardware, and the setup and pre-computation costs are amortized very
differently depending on how often a credential is presented.
What they do show is that the transparent, prepare-and-prove designs (Vega and OpenAC) reach
online proving times in the order of a hundred milliseconds on desktop hardware, at the cost of
substantially larger proving and verifying keys.

=== Governance, standardization

There are also talks from standardization body to include this work in standards recognized by the governing bodies in the EU:

- Standardisation efforts
  - The authors of Longfellow have proposed it as an IETF draft @IETFLongfellow.
  - ETSI is standardizing BBS, Longfellow-zk, Vega, and OpenAC for digital identity uses in ETSI 119 476 2 @ETSIZKP. In our opinion, the standardization of BBS is great but comes at a point in time when the convenience vs cost of rolling out BBS in a way that is compliant with eIDAS 2 is not attractive. Even less so with all the strong circuit-based ZKP contenders.
  - Yubico has also announced interest in piloting with Longfellow in the scope of Europe's Digital Identity project https://www.yubico.com/blog/piloting-europes-future-id-passkeys-securing-digital-wallets/

== New Risks <what-risks>

- Have new risks been identified which could affect the future development activities?
