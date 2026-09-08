#import "ams-article.typ": ams-article
#show link: underline
#show: ams-article.with(
  title: [Secure and Privacy-Preserving Credentials for E-ID - #linebreak()
    Final Report],
  paper-size: "a4",
  authors: (
    (
      name: "Linus Gasser",
      organization: [EPFL],
      email: "linus.gasser@epfl.ch",
      url: "ineiti.ch"
    ),
    (
      name: "Clement Humbert",
      organization: [SICPA],
      email: "clement.humbert@sicpa.com",
    ),
  ),
  abstract: [We describe the ongoing work for the Innosuisse grant 101.292 IP-ICT -
  Secure and Privacy-Preserving Credentials for E-ID - between EPFL's C4DT and SICPA SA.
  This is the final Report.],
  bibliography: bibliography("references.bib", style: "ieee"),
)
// #set page(margin: (inside: 2cm, outside: 1.5cm, y: 1.75cm))

#include "ms4.typ"

// Re-arrange MS2 a bit
#include "ms2.typ"
