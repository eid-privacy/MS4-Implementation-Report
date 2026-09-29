#import "common.typ": *

= Next Steps (\*)

== Who can use it?

Taking into account the assumptions in ..., here is what you can (not)
do with the code.

== Taxonomy Paper

== Remaining Challenges <remaining-challenges>

- post-quantum
- more complete backend
- use latest vega results
- include revocation
- standardisation
- noir auditing
- easier noir blackboxes
- PR into noir

== Productization follow-ups

While the integration of the proof components was not an obstacle, there are more structural and contextual items to be addressed for production-grade integration.

On the technical side, finding out the most cost-effective way to reduce the proof costs is the top priority and might come with some of the items in @remaining-challenges. A better interface between elements of the toolchain as well as friendlier interfaces for existing backend stacks is another item (e.g., bindings for the JVM). Exploring whether existing cloud offering such as Amazon S3 are a viable way to exploit pre-computation despite the size and sensitivity of intermediate proofs.

For ecosystem and specification integrations there would be need to design a way to distribute and version circuits in a secure way to avoid discrepencies preventing proofs from functioning or downgrade attack when a circuit gets updated for security reasons. Specification of ZKPs is active in most standard bodies and how they adapt to the emergence of many proof systems remains to be seen.

