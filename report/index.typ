#import "ams-article.typ": ams-article
#import "common.typ": *

#show link: underline
#show: ams-article.with(
  title: [Secure and Privacy-Preserving Credentials for E-ID - #linebreak()
    Final Report],
  paper-size: "a4",
  // narrow: true,
  // columns: 2,
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
      url: "ineiti.ch"
    ),
  ),
  abstract: [We describe the work done for the Innosuisse grant 101.292 IP-ICT -
  Secure and Privacy-Preserving Credentials for E-ID - between EPFL and SICPA SA.
  This is the final report.],
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
