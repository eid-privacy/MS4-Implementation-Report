#import "common.typ": *

= Appendix A - Work Packages and Milestones <app-wp-ms>

== WP4b - Unlinkable and anonymous credential signing

// D4.2a - Implementation of the algorithm to provide unlinkable and anonymous credential signing.
// D4.2b - Stretch goal: unlinkable pseudonyms bound to a service.

Our chosen solution works directly with the SD-JWT format used by the EUDI-Wallet and
Swiyu, which made us investigate how to improve the performance of checks
using the `noir` framework.

_D4.3 - A mathematical proof for the algorithm in D4.2_

See @holder-binding

_D4.4 - Example programs showing how a credential is issued to a holder, and how a verifier can test whether the signature is valid_

Our example circuit in #repo("spartan-backend", path: "circuits/c0200_swiyu_jwt")
shows how the issuer signature is proven by the credential holder.

== WP5b - Predicate Proofs - anonymous and unlinkable proofs of credential values

// D5.2a - Algorithm for an anonymous, unlinkable proof of predicates, including the information necessary for the hardware based holder binding.
// D5.2b - Stretch goal 1: proof bound to single verifier
// D5.2c - Stretch goal 2: deniable proof

With our approach to use ZKP circuits, predicate proofs in any combination
are possible.
The restriction is the complexity of the circuit created, but for most of
the challenges, a good optimisation can be found.

_D5.3 - A security proof and an implementation of D5.2_

To prove predicates in standard SD-JWT credentials, used by the EUDI-wallet
and Swiyu, we use the `noir` framework and a Spartan prover.
The proof of Spartan can be found in their paper @S19.

_D5.4 - Example programs for creation and verification of predicates_

Our example circuit in #repo("spartan-backend", path: "circuits/c0200_swiyu_jwt")
shows how to create predicate proofs directly on the credential.

== WP6b - Privacy-preserving revocation

Contrary to the current Swiyu proposal, we invert the
proof of the non-revocation: instead of the verifier having
to download and verify that the current credential is still
valid, we let the prover include the proof directly.
This also removes the need for batch issuance of credentials.

_D6.3 - A mathematical proof for the algorithm in D6.2_

As described in @why-opt-revocation, we did not use a
cryptographic approach to the revocation, but created
a simplified list, signed by the issuer.
The security review included our proposal, and
did not mark our list as problematic in any way.

_D6.4 - Proof of concept implementations of the revocations_

We have a circuit with an example of this revocation list
in our first proofs-of-concept, as circuit
#repo("zkp-pocs", path: "noir/c06_non_revocation").

== MS3 Goals

Here is the list of all the goals for MS3, which have been mostly
met by our external security review.

_G5.3 An external entity verifies that D5.3 is correct_

-> Done by the security review

_G6.3 An external entity verifies that D6.3 is correct_

-> Done by the security review

_G4.3 An external entity verifies that the proof for the unlinkable and anonymous credential signing is correct_

-> Done by the security review

_G3.3 An external entity verifies that the proof for the unlinkable proof of device binding is correct_

-> Done by the security review

== WP7 - Final hardened implementation of our choices

For all the applicable findings of the security review, we
include a fix in our latest code.
This code is available under an open source license, and
can be used for further experiments.

_D7.1 - Build the library_

Available on #link("https://github.com/eid-privacy/spartan-backend")[GitHub: eid-privacy/spartan-backend]

_D7.2 - Documentation is available and allows usage of the library_

Available in D7.1 repository. Guidance is given in this report as well.

_D7.3 - Speed / bandwidth considerations_

We reached good speed with precomputation despite using unmodified Swiyu SD-JWT and providing a human-readable
and auditable solution.
On a MacBook Pro M2 Max, the proving time after precomputation is 1.5s, while a mobile
phone from 2023 creates the proof after precomputation in 4.5s.
Follow-ups exist that could bring this further down (see @remaining-challenges) without invalidating the work from this grant.
Proof size is well below the limit of 1MB: our largest circuit (c0202_sicpa_backend_constant) results in proofs of 202KB.

_D7.4 - An external security review of the final implementation of the algorithms is performed_

We mandated #link("https://zksecurity.xyz/")[zkSecurity], a company specialized in ZKP implementations, to conduct the security audit of the
backend, circuit, and noir blackbox implementation.
The critical findings impacting the soundness of our implementation have been addressed.
The report will be made available shortly on the library's repository.

_D7.5 - Feedback from SICPA's Digital Trust Platform is integrated back into our library_

The library architecture and most of the synthesis was engineered by a member of SICPA's team, ensuring a good fit for integration
in a digital identity product.
It is likely that further quality improvements will be contributed to the library as integration progresses further.

== WP8 - Use the library in SICPA's Digital Trust Platform

We built a demonstrator of the proofs using the standard APIs
of SICPA's Digital Trust Platform.
While the code cannot be used yet as-is, we demonstrated
the way forward and will work further to get the code included
as a standard library in SICPA.

_D8.1 - Choice of two use-cases to be implemented in SICPA's software_

SICPA implemented an "over 18" use case and is planning to implement a set membership one.

_D8.2 - Implementation of use-cases using the library from WP7_

The "over 18" use-case is implemented using the library and its c0202 circuit.

== MS4 Goals

Here are the goals for the final milestone.

_G0.3 The final report is available_

Yes - This is the final report.

_G7.1 Open sourced library is available publicly, e.g., on GitHub, with a "popular" OSI approved license_

Available on #link("https://github.com/eid-privacy/spartan-backend")[GitHub: eid-privacy/spartan-backend]

_G7.2 The Digital Trust Platform in WP8 can be extended using the documentation_

Yes

_G7.3 The necessary operations are fast enough to be executed on a modern mobile device, and the size of the messages is well below 1MB_

With flat data, a fixed-sized structure representing a credential, we reached 0.9 seconds of proving time.

We reached good speed with precomputation despite using unmodified Swiyu SD-JWT and providing a human-readable
and auditable solution.
On a MacBook Pro M2 Max we get down to 1.5s of proving time.
On a mobile phone from 2023, the proof takes 11.0s without, and 4.5s with precomputation.
Follow-ups exist that could bring this further down (see @remaining-challenges) without dismissing the work from this grant.
Proof size is well below the limit of 1MB: our largest circuit (c0202_sicpa_backend_constant) results in proofs of 202KB.

_G7.4 The review shows the security of the library and its recommendations are integrated_

Yes, report to be made available on the repository soon.

_G7.5 SICPA's Digital Trust Platform successfully implements new functionality using the library_

Yes, the platform can request and present credentials using the ZKP circuits and proof system implemented in the library.

_G8.1 Confirmation of usefulness of use-cases by FOITT and FOJ_

A few exchanges confirmed the usefulness of our approach and of the nuances we exposed throughout the work.
The use cases were informally approved in discussions.
We believe the usefulness of the "over 18" use case no longer needs to be demonstrated given the widespread
media coverage it had and the amount of regulatory politics focusing on it.

The other use-cases described in @what-use-cases are not yet
possible, as the Swiyu platform has not been opened to the
public yet.
Also, currently only the governmental e-ID credential is
available, plus the driving license credential.
But so far no commune or high school has started issuing
credentials, for example for a proof of residency, diplomas,
work permits, or other information.

_G8.2 Demonstrator on Digital Trust Platform is available and performs the needed functions_

A demonstrator has been developed but due to the current cost of running a prover pod in our infrastructure,
the flow of the demonstration will be the object of a recording and voice-over to show how it works.

== All Blog Posts

#figure(
  table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 4pt, y: 3pt),
    align: left,
    fill: (_, y) => if calc.odd(y) { luma(93%) },
    table.hline(),
    table.header([*Date*], [*Title*]),
    table.hline(stroke: 0.5pt),
    [2025-05-07], [#link("https://eid-privacy.github.io/wp0/2025/05/07/welcome.html")[Welcome to our technical blog]],
    [2025-05-23], [#link("https://eid-privacy.github.io/wp1/wp2/2025/05/23/swiyu-demo-announcement.html")[Open Source SWIYU Demo application]],
    [2025-06-10], [#link("https://eid-privacy.github.io/wp1/2025/06/10/taxonomy-101.html")[Taxonomy 101]],
    [2025-09-17], [#link("https://eid-privacy.github.io/wp1/2025/09/17/taxonomy-of-digital-identity-systems.html")[Taxonomy of digital identity systems]],
    [2025-09-17], [#link("https://eid-privacy.github.io/wp2/2025/09/17/privacy-enhancing-resources.html")[Resources on Zero-knowledge Systems and Proofs]],
    [2025-10-20], [#link("https://eid-privacy.github.io/wp4/2025/10/20/overview.html")[Overview of Privacy and Unlinkability]],
    [2025-10-21], [#link("https://eid-privacy.github.io/wp1/2025/10/21/comparing-implemented-zk-systems.html")[Comparing ZK systems]],
    [2025-11-28], [#link("https://eid-privacy.github.io/wp0/2025/11/28/crescent-longfellow-showdown.html")[Crescent and Longfellow]],
    [2026-01-09], [#link("https://eid-privacy.github.io/2026/01/09/poc-report.html")[Proof-of-Concept for ZKPs]],
    [2026-01-27], [#link("https://eid-privacy.github.io/wp2/2026/01/27/docknetwork-crypto-library.html")[Choosing a Cryptographic Library for Anonymous Credentials]],
    [2026-04-22], [#link("https://eid-privacy.github.io/wp2/2026/04/22/zkp-vault.html")[Reading list for ZKP algorithms and implementations]],
    [2026-05-27], [#link("https://eid-privacy.github.io/wp2/2026/05/27/noir-benchmarking.html")[BoundedVec sizes vs. proving time in Noir]],
    [2026-06-19], [#link("https://eid-privacy.github.io/wp2/2026/06/19/noir-benchmarking-mobile.html")[Verifiable SD-JWT Credential on Mobile]],
    table.hline(),
  ),
  caption: [Blog posts published on #link("https://eid-privacy.github.io")[`eid-privacy.github.io`].],
) <tab-blog-posts>
