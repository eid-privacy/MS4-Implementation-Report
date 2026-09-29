#import "common.typ": *

= Next Steps (\*)

== Who can use it?

Taking into account the assumptions in ..., here is what you can (not)
do with the code.

== Taxonomy Paper

== Remaining Challenges and follow-ups <remaining-challenges>

=== Cryptography

The main shortcoming of our proposal is shared with most others, short of Longfellow.
Spartan is not post-quantum secure as it relies on the hardness of the discrete logarithm problem.

Our backend does not leverage Vega's capabilities for fold-and-reuse circuits that would dramatically reduce the proving
time for credential presentation.
Using this would diminish the cost of sha-256 hashing, and therefore the cost brought by the size of the credentials themselves.
As such, this is the natural follow-up when it comes to performance improvements. This would involve designing new primitives
in Noir's standard library and/or compiler to express the semantic of _fold-and-reuse_ in circuit code.

=== Engineering

Next engineering steps would include:
- A more complete backend, our implementation has deliberately left aside Noir blackboxes and opcodes that were not relevant for the work.
- A way to audit Noir, or at least the parts relevant to us. Noir has its own testing strategy regarding security but its very active codebase is difficult
  to assess for soundness.
- A few changes in Noir's architecture would likely be needed to accommodate for curves that don't form a cycle and contribute our changes back to the upstream
  repository.

=== Swiyu <follow-up-revocation>

Regarding the standards we tried to preserve, OpenId4VP is untouched if for the non-breaking addition of a proof type.
Following the workgroup's meetings and evolution would inform on how such proof mechanisms are meant to extend the original specification.


 Our proof circuit does not include revocation. The IETF standard for revocation lists includes either a compression pass, or a very lengthy bit string representation
both causing prohibitive explosion of the circuit size, and therefore proving time.
We propose an alternative approach in c06 that would add a flat cost to the proof.
Designing such a ZKP-friendly approach to revocation would be a logical next step for a complete proposal.

== Productization follow-ups

While the integration of the proof components was not an obstacle, there are more structural and contextual items to be addressed for production-grade integration.

On the technical side, finding out the most cost-effective way to reduce the proof costs is the top priority and might come with some of the items in @remaining-challenges.
A better interface between elements of the toolchain as well as friendlier interfaces for existing backend stacks is another item (e.g., bindings for the JVM).
Exploring whether existing cloud offering such as Amazon S3 are a viable way to exploit pre-computation despite the size and sensitivity of intermediate proofs.

For ecosystem and specification integrations there would be need to design a way to distribute and version circuits in a secure way to
avoid discrepencies preventing proofs from functioning or downgrade attack when a circuit gets updated for security reasons.
Specification of ZKPs is active in most standard bodies and how they adapt to the emergence of many proof systems remains to be seen.

