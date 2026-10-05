// Shared helpers for every chapter of the report.
// Each chapter file is its own Typst module, so it must import this file itself.
#import "ams-article.typ": theorem, proof, wide-figure, wide-table

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

#let gh-org = "https://github.com/eid-privacy/"
// Link to a repository (optionally a path inside it) of the eid-privacy org.
#let repo(name, path: none) = link(
  gh-org + name + if path != none { "/tree/main/" + path } else { "" },
  raw(if path != none { path.split("/").last() } else { name }),
)

// Link to a commit of a repository of the eid-privacy org.
#let commit(name, sha) = link(gh-org + name + "/commit/" + sha, raw(name + "@" + sha))

// Security review findings: severity and status, with their label and color.
#let finding-severities = (
  high: ([High], rgb("#c0392b")),
  medium: ([Medium], rgb("#e67e22")),
  low: ([Low], rgb("#b7950b")),
  info: ([Informational], rgb("#2471a3")),
  known: ([Known issue], luma(40%)),
)
#let finding-statuses = (
  fixed: ([Fixed], rgb("#1e8449")),
  scope: ([Out of scope], luma(45%)),
  open: ([Open], rgb("#c0392b")),
)

#let badge(body, color) = box(
  fill: color.lighten(85%),
  stroke: 0.5pt + color,
  radius: 2pt,
  inset: (x: 3pt, y: 1.5pt),
  baseline: 20%,
  text(size: 0.8em, weight: "bold", fill: color.darken(20%), body),
)

// One finding of the security review, with our answer as body.
// `fix` is optional content shown next to the status, e.g. a link to the fixing commit.
#let finding(id, title, severity: "high", status: "fixed", fix: none, body) = {
  let (slabel, scolor) = finding-severities.at(severity)
  let (tlabel, tcolor) = finding-statuses.at(status)
  [#metadata((severity: severity, status: status)) <finding>]
  block(
    width: 100%,
    breakable: true,
    stroke: (left: 2pt + scolor),
    inset: (left: 6pt, y: 3pt),
    spacing: 1em,
  )[
    #badge(upper(slabel), scolor) #h(2pt) *\##id* — #title \
    #badge(tlabel, tcolor) #if fix != none [ #h(2pt) #text(size: 0.85em)[#fix] ]
    #v(-0.3em)
    #set par(justify: true, first-line-indent: 0pt)
    #body
  ]
}

// Table counting all `finding`s of the document by severity and status.
#let findings-summary() = context {
  let fs = query(<finding>).map(m => m.value)
  let count(sev, st) = str(
    fs.filter(f => (sev == none or f.severity == sev) and (st == none or f.status == st)).len(),
  )
  let statuses = finding-statuses.keys()
  table(
    columns: 2 + statuses.len(),
    align: (left,) + (right,) * (1 + statuses.len()),
    table.header([Severity], [Findings], ..finding-statuses.values().map(s => s.at(0))),
    ..finding-severities
      .pairs()
      .map(((k, s)) => (s.at(0), count(k, none), ..statuses.map(st => count(k, st))))
      .flatten(),
    table.hline(),
    [*Total*], strong(count(none, none)), ..statuses.map(st => strong(count(none, st))),
  )
}
