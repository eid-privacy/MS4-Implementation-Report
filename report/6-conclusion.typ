#import "common.typ": *

= Conclusion <conclusion>

We are very satisfied with the way the project concluded.
Part of it was very hard, because big players like Google and Microsoft were
working on the same things.
But in the end I believe we found an interesting niche where we were able to
show a difference in how things work.

In the beginning we were very focused on creating a new description of the
credentials to optimise proving time.
Very quickly it turned out that nobody wants to change the structures and
standards in use, as this is a very long process, which requires collaboration
with governments, policy actors, and other big companies.
For this reason we concentrated on using the standards currently chosen for
the EUDI-wallet and Swiyu, without wanting to change them.
We were lucky to have support from the blockchain community, who did a great
job working on `noir` to create a framework which was powerful, yet
also capable of extension.

After MS2, we did decide to concentrate on `noir`, and combine it with one
of the fastest ZKPs at the time, Spartan from Microsoft.
One thing we closely missed was the paper @ENRT26 from the Ethereum foundation,
which showed an even better way forward than what we implemented using the
Spartan framework from Microsoft.
The problem with our current approach in @how-precomputation is that the
pre-computation is a very powerful tool, but the intermediate proof is 1.5GB,
which reduces most of the gain, because reading that amount of data takes
longer than to create the rest of the proof.
The paper from the Ethereum foundation showed how to overcome this problem by
creating so called `Hyrax Commitments`, which allow the prover to present
two proofs: one about the correctness of these commitments, and a second about
the proof actually required by the verifier: age verification, living region,
or any other required predicate.

== Acknowledgements

- C4DT team beyond the authors
- SICPA team beyond the authors
- Matteo Frigo for informed opinions and debate on ZKP solutions for digital identity
- Andreas Freysang and Rolf Rauschenback from the Office Federal of Justice,
  and all their colleagues who participated in the discussions on how to create
  good ZKPs for the e-ID
- Patrick Amrein from Ubique for discussions on the general approach to
  privacy-preserving e-ID as well as suggestions to strengthen the
  security guarantees of our circuits and running rust with `--release`
- The ZkSecurity team for thorough work on short notice
