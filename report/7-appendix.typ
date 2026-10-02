#import "common.typ": *

= Appendix

=== WP4b - Unlinkable and anonymous credential signing

// D4.2a - Implementation of the algorithm to provide unlinkable and anonymous credential signing.
// D4.2b - Stretch goal: unlinkable pseudonyms bound to a service.

Our chosen solution works directly with the SD-JWT format by the EUDI-Wallet and
Swiyu, which made us investigate how to improve the performance of checks
using the `noir` framework.
We ported the Spartan-proof for ECDSA and implemented the conversion of the ECDSA
signature according to the formulas described in

#todo[Link to formula description]

D4.3 - A mathematical proof for the algorithm in D4.2.

-> ECDSA of Crescent
#todo[Copy the mathematical proof we wrote on the napkin]

D4.4 - Example programs showing how a credential is issued to a holder, and how a verifier can test whether the signature is valid.

Our example circuit in [c0200_swyiu_jwt](https://github.com/eid-privacy/spartan-backend/tree/main/circuits/c0200_swiyu_jwt)
shows how the issuer signature is proven by the credential holder.

=== WP5b - Predicate Proofs - anonymous and unlinkable proofs of credential values

// D5.2a - Algorithm for an anonymous, unlinkable proof of predicates, including the information necessary for the hardware based holder binding.
// D5.2b - Stretch goal 1: proof bound to single verifier
// D5.2c - Stretch goal 2: deniable proof

D5.3 - A security proof and an implementation of D5.2.

To prove predicates in standard SD-JWT credentials, used by the EUDI-wallet
and Swiyu, we use the `noir` framework and a Spartan prover.
The proof of Spartan can be found in their paper [ref-Spartan-proof].

D5.4 - Example programs for creation and verification of predicates.

Our example circuit in [c0200_swyiu_jwt](https://github.com/eid-privacy/spartan-backend/tree/main/circuits/c0200_swiyu_jwt)
shows how to create predicate proofs directly on the credential.

=== WP6b - Privacy-preserving revocation

// D6.2 - A privacy-preserving (non-linkable) algorithm for the holder to prove that their credential has not been revoked.

D6.3 - A mathematical proof for the algorithm in D6.2.
D6.4 - Proof of concept implementations of the revocations.

== MS3 Goals

G5.3 An external entity verifies that D5.3 is correct

-> Done by the security review

G6.3 An external entity verifies that D6.3 is correct

-> Done by the security review

G4.3 An external entity verifies that the proof for the unlinkable and anonymous credential signing is correct.

-> Done by the security review

G3.3 An external entity verifies that the proof for the unlinkable proof of device binding is correct.

-> Done by the security review

=== WP7 - Final hardened implementation of our choices (Cl)

D7.1 - Build the library

Available on #link("https://github.com/eid-privacy/spartan-backend")[Github: eid-privacy/spartan-backend]

D7.2 - Documentation is available and allows usage of the library.

Available in D7.1 repository. Guidance is given in this report as well.

D7.3 - Speed / bandwidth considerations.

We reached very good speed with precomputation despite using unmodified Swiyu SD-JWT and providing a human-readable
and auditable solution.
On a M4 Mac we get down to 1.5s of proving time.
Phone implementation hangs around the 10s mark.
Follow-ups exist that could bring this further down (see @remaining-challenges) without dismissing the work from this grant.
Proof size is well below the limit of 1MB: our largest circuit (c0202_sicpa_backend_constant) results in proofs of 202KB.

D7.4 - An external security review of the final implementation of the algorithms is performed

We mandated #link("https://zksecurity.xyz/")[ZkSecurity], a company specialized in ZKP implementations, to conduct the security audit of the
backend, circuit, and noir blackbox implementation.
The critical findings impacting the soundness of our implementation have been addressed.
The report will be made available shortly on the library's repository.

D7.5 - Feedback from SICPA's Digital Trust Platform is integrated back into our library.

The library architecture and most of the synthesis was engineered by a member of SICPA's team, ensuring a good fit for integration
in a digital identity product.
It is likely that further quality improvements will be contributed to the library as integration progresses further.

=== WP8 - Use the library in SICPA's Digital Trust Platform (Cl)

D8.1 - Choice of two use-cases to be implemented in SICPAs software.

SICPA implemented an "over 18" use case and is planning to implement a set membership one.

D8.2 - Implementation of use-cases using the library from WP7.

The "over 18" use-case is implemented using the library and its c0202 circuit.

== MS4 Goals

G0.3 The final report is available

Here we go...

G7.1 Open sourced library is available publicly, e.g., on GitHub, with a "popular" OSI approved license

Available on #link("https://github.com/eid-privacy/spartan-backend")[Github: eid-privacy/spartan-backend]

G7.2 The Digital Trust Platform in WP8 can be extended using the documentation

Yes

G7.3 The necessary operations are fast enough to be executed on a modern mobile device, and the size of the messages is well below 1MB.

With flat data, a fixed-sized structure representing a credential, we reached 0.9 second of prover speed.

We reached very good speed with precomputation despite using unmodified Swiyu SD-JWT and providing a human-readable
and auditable solution.
On a M4 Mac we get down to 1.5s of proving time.
Phone implementation hangs around the 10s mark.
Follow-ups exist that could bring this further down (see @remaining-challenges) without dismissing the work from this grant.
Proof size is well below the limit of 1MB: our largest circuit (c0202_sicpa_backend_constant) results in proofs of 202KB.

G7.4 The review shows the security of the library and its recommendations are integrated

Yes, report to be made available on the repository soon.

G7.5 SICPA's Digital Trust Platform successfully implements new functionality using the library.

Yes, the platform can request and present credentials using the ZKP circuits and proof system implemented in the library.

G8.1 Confirmation of usefulness of use-cases by FOITT and FOJ

A few exchanges confirmed the usefulness of our approach and of the nuances we exposed throughout the work.
The usecases were informally approved in discussions.
We believe the usefulness of the "over 18" usecase is not to be demonstrated anymore given the widespread
media coverage it had and the amount of regulatory politics focusing on it.

G8.2 Demonstrator on Digital Trust Platform is available and performs the needed functions.

A demonstrator has been developed but due to the current cost of running a prover pod in our infrastructure,
the flow of the demonstration will be the object of a recording and voice-over to show how it works.

== All Blog Posts (Ca)

At least the links...
