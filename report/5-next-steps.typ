#import "common.typ": *

= Next Steps

== Who can use it?

Our code and other artifacts can be used by different target
audiences:

- For researchers, and people interested in the topic, we published
  several #link("https://eid-privacy.github.io/")[Blog Posts] and a
  #link("https://eid-privacy.github.io/zkp-vault")[List of Resources],
  for which we already got feedback of people having used it to
  start their own journey into ZKPs.
- Our results are reproducible, thanks to the
  #link("https://www.jetify.com/devbox")[Devbox] tool which runs
  on Mac, Linux, and Windows. This applies to the earlier
  #link("https://github.com/eid-privacy/zkp-pocs")[zkp-pocs], as
  well as to the latest
  #link("https://github.com/eid-privacy/spartan-backend")[spartan-backend]
  code with our improvements.
  You can also test the performance of the mobile code by running the
  benchmarks on your own phone using
  #link("https://github.com/eid-privacy/zkp-android-spartan")[zkp-android-spartan]
  and running it with Android Studio.

== Remaining Challenges and follow-ups <remaining-challenges>

There are a couple of improvements which are possible and can lead our
solution to be used and competitive with others like Longfellow itself.

=== Cryptography

*Post-Quantum*:
The main shortcoming of our proposal is shared with most others, short of Longfellow.
Spartan is not post-quantum secure as it relies on the hardness of the discrete logarithm problem.

*Optimisations*:
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

Regarding the standards we preserved, OpenId4VP is untouched if for the non-breaking addition of a proof type.
Following the workgroup's meetings and evolution would inform on how such proof mechanisms are meant to extend the original specification.

Our proof circuit does not include revocation. The IETF standard for revocation lists includes either a compression pass, or a very lengthy bit string representation
both causing prohibitive explosion of the circuit size, and therefore proving time.
We propose an alternative approach in @why-opt-revocation that would add a flat cost to the proof.
Designing such a ZKP-friendly approach to revocation would be a logical next step for a complete proposal.

== Optimisations we didn't do

The current Spartan implementation creates a matrix of size $2^N$, where $N$ is
a natural number.
For our age-proving circuit, the size of this matrix is $2^22$, but this
is only because the size got rounded up.
We are very close to $2^21$, which would improve the performance of the proof
a lot.
Here are some tasks we could do to get below that threshold:
- better range-checks with lookup tables - currently each range-check is
  individual
- multi scalar multiplications - the multiplication ladders are very
  expensive, and as there are at least two places where two scalar multiplications
  happen in a row, this is an optimisation which might improve the performance
- optimise Spartan conversion to automatically do barrel-shifter - currently,
  a software engineer wanting to write a circuit, must be aware of some of the
  pitfalls when creating a circuit. If Spartan can take care of this optimisation
  automatically, it will be even easier to create these circuits.

== Productization follow-ups <next-productisation>

While the integration of the proof components was not an obstacle, there are more structural and contextual items to be addressed for production-grade integration.

On the technical side, finding out the most cost-effective way to reduce the proof costs is the top priority and might come with some of the items in @remaining-challenges.
A better interface between elements of the toolchain as well as friendlier interfaces for existing backend stacks is another item (e.g., bindings for the JVM).
Exploring whether existing cloud offering such as Amazon S3 are a viable way to exploit pre-computation despite the size and sensitivity of intermediate proofs.

For ecosystem and specification integrations there would be need to design a way to distribute and version circuits in a secure way to
avoid discrepencies preventing proofs from functioning or downgrade attack when a circuit gets updated for security reasons.
Specification of ZKPs is active in most standard bodies and how they adapt to the emergence of many proof systems remains to be seen.

// Clement: make sure that the following is all here:
//
// - Status of the implementation plan (i.e., the required steps from project end to the realization or market launch of the product/service by the implementation partner/s).
// - What implementation scenario is being considered (e.g., product/service, market, etc.)?
// - What are the main milestones and decision-making points for implementation?
// - How is the necessary know-how transfer ensured? How were the implementation partners been able to strengthen and expand its knowledge, technology and innovation base through cooperation with research partners?
// - What quantitative economic results can be expected from the implementation (e.g., turnover, profit, market positioning, social value creation)?
// - Have new risks been identified which could affect the future commercialisation activities?
// - IPR strategy and measures to ensure commercial exploitation (FTO - Freedom to Operate)
