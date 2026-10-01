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

-> Based on Spartan
-> Done by the security review

// D6.2 - A privacy-preserving (non-linkable) algorithm for the holder to prove that their credential has not been revoked.

D6.3 - A mathematical proof for the algorithm in D6.2.
D6.4 - Proof of concept implementations of the revocations.

== MS3 Goals

G5.3 An external entity verifies that D5.3 is correct
G6.3 An external entity verifies that D6.3 is correct
G4.3 An external entity verifies that the proof for the unlinkable and anonymous credential signing is correct.
G3.3 An external entity verifies that the proof for the unlinkable proof of device binding is correct.

=== WP7 - Final hardened implementation of our choices

D7.1 - Build the library
D7.2 - Documentation is available and allows usage of the library.
D7.3 - Speed / bandwidth considerations.
D7.4 - An external security review of the final implementation of the algorithms is performed
D7.5 - Feedback from SICPA's Digital Trust Platform is integrated back into our library.

=== WP8 - Use the library in SICPA's Digital Trust Platform

D8.1 - Choice of two use-cases to be implemented in SICPAs software.
D8.2 - Implementation of use-cases using the library from WP7.

== MS4 Goals

G0.3 The final report is available
G7.1 Open sourced library is available publicly, e.g., on GitHub, with a "popular" OSI approved license
G7.2 The Digital Trust Platform in WP8 can be extended using the documentation
G7.3 The necessary operations are fast enough to be executed on a modern mobile device, and the size of the messages is well below 1MB.
G7.4 The review shows the security of the library and its recommendations are integrated
G7.5 SICPA's Digital Trust Platform successfully implements new functionality using the library.
G8.1 Confirmation of usefulness of use-cases by FOITT and FOJ
G8.2 Demonstrator on Digital Trust Platform is available and performs the needed functions.

== All Blog Posts
