// Shared helpers for every chapter of the report.
// Each chapter file is its own Typst module, so it must import this file itself.
#import "ams-article.typ": theorem, proof

#let todo(body, assignee: none) = block(
  fill: luma(95%),
  stroke: (left: 3pt + orange),
  inset: 8pt,
  radius: 2pt,
)[
  #text(fill: orange, weight: "bold")[TODO]
  #if assignee != none [
    #text(fill: black, size: 0.85em)[(@#assignee)]
  ]
  — #body
]
