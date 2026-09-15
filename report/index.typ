#import "ams-article.typ": ams-article
#show link: underline
#show: ams-article.with(
  title: [Secure and Privacy-Preserving Credentials for E-ID - #linebreak()
    Final Report],
  paper-size: "a4",
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
  abstract: [We describe the ongoing work for the Innosuisse grant 101.292 IP-ICT -
  Secure and Privacy-Preserving Credentials for E-ID - between EPFL's C4DT and SICPA SA.
  This is the final Report.],
  bibliography: bibliography("references.bib", style: "ieee"),
)
// #set page(margin: (inside: 2cm, outside: 1.5cm, y: 1.75cm))

#include "1-intro.typ"
#include "2-what.typ"
#include "3-why.typ"
#include "4-how.typ"
#include "5-next-steps.typ"
#include "6-conclusion.typ"
#include "7-appendix.typ"
