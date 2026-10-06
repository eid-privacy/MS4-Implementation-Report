#import "ams-article.typ": ams-article
#import "common.typ": *

#show link: underline
#show: ams-article.with(
  title: [Secure and Privacy-Preserving Credentials for E-ID - #linebreak()
    Final Report],
  paper-size: "a4",
  narrow: true,
  columns: 2,
  authors: (
    (
      name: "Carine Dengler",
      organization: [EPFL],
      email: "carine.dengler@epfl.ch",
    ),
    (
      name: "Clement Humbert",
      organization: [SICPA],
      email: "clement.humbert@sicpa.com",
    ),
    (
      name: "Linus Gasser",
      organization: [EPFL],
      email: "linus.gasser@epfl.ch",
      url: "ineiti.ch",
    ),
  ),
  abstract: [With the large-scale deployment of state-backed digital identity
    systems, e-ID, fast approaching in Europe (Swiyu @Swiyu and EUDI-ARF @EUDI-ARF),
    we investigated how holders' privacy can be improved in the proposed
    technological stack of Swiyu.
    During the 18 months of this project, we researched how to use
    Zero-Knowledge-Proofs, ZKPs, to preserve privacy when using e-ID systems.
    After having evaluated existing solutions, we created an improved,
    simplified ZKP to prove any predicate of an e-ID in reasonable time.

    Our solution allows to use standard SD-JWT @RFC9901 @SDJWT credentials like they
    are used in Swiyu and the EUDI-ARF, and create proofs on any
    random predicate.
    All of this with acceptable performance: 4.3s on a 2023 mobile
    phone @galaxy-a54 for an age verification, including holder binding @EIDBlogMobile!
    We achieved this performance and flexibility by linking
    Microsoft's Spartan prover @S19 to Noir @noir_lang, and optimising for
    ECDSA @NIST186-5 signature verification and low mobile performance.
  ],
)
// #set page(margin: (inside: 2cm, outside: 1.5cm, y: 1.75cm))

#include "1-intro.typ"
#include "2-what.typ"
#include "3-why.typ"
#include "4-how.typ"
#include "5-next-steps.typ"
#include "6-conclusion.typ"

#bibliography("references.bib", style: "ieee")

#pagebreak()

#counter(heading).update(0)
#set heading(numbering: (..nums) => {
  if nums.len() == 1 {
    numbering("A", nums.at(0))
  } else {
    numbering("A.1", ..nums)
  }
})

#include "7-appendix-a.typ"
#include "8-appendix-b.typ"
