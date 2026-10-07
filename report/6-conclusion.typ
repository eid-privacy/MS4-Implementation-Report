#import "common.typ": *

= Conclusion <conclusion>

We are satisfied with the way the project concluded.
Part of it was hard, because big players like Google and Microsoft were
working on the same things.
But in the end we believe we found an interesting niche where we were able to
show a difference in how things work.

In the beginning we were focused on creating a new description of the
credentials to optimise proving time.
But it turned out that nobody wants to change the structures and
standards in use, as this is a long process, which requires collaboration
with governments, policy actors, and other big companies.
For this reason we concentrated on using the standards currently chosen for
the EUDI-wallet and Swiyu.
We were lucky to have support from the blockchain community, who did a great
job working on `noir` to create a framework which was powerful, yet
also capable of extension.

After MS2, we decided to concentrate on `noir`, and combine it with one
of the fastest ZKPs at the time, Spartan from Microsoft.
Another good candidate would have been the paper @ENRT26 from the Ethereum Foundation,
which showed an even better way forward than what we implemented using the
Spartan framework from Microsoft.

The paper from the Ethereum Foundation shows another approach by
creating so-called _Hyrax commitments_, which allow the prover to present
two proofs: one about the correctness of these commitments, and a second one about
the statement actually required by the verifier: age verification, living region,
or any other required predicate.

== Acknowledgements

- C4DT team beyond the authors
- SICPA team beyond the authors
- EPFL and the professors who supported us with their advice, their courses,
  and answering our questions: Alessandro Chiesa, and Edouard Bugnion
- Andreas Freysang and Rolf Rauschenbach from the Federal Office of Justice,
  and all their colleagues who participated in the discussions on how to create
  good ZKPs for the e-ID
- Matteo Frigo for informed opinions and debate on ZKP solutions for digital identity
- Patrick Amrein from Ubique for discussions on the general approach to
  privacy-preserving e-ID as well as suggestions to strengthen the
  security guarantees of our circuits and running Rust with `--release`
- The zkSecurity team for thorough work on short notice
