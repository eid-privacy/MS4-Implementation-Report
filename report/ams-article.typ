// Sizes used across the template.
#let script-size = 7.97224pt
#let footnote-size = 8.50012pt
#let small-size = 9.24994pt
#let normal-size = 10.00002pt
#let large-size = 11.74988pt

// This function gets your whole document as its `body` and formats
// it as an article in the style of the American Mathematical Society.
#let ams-article(
  // The article's title.
  title: [Paper title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The article's paper size. Also affects the margins.
  paper-size: "a4",

  // Whether to use narrow margins. Narrow margins (the default) give
  // a tighter, more compact layout. Wide margins (narrow: false) use
  // the full AMS-article margins, leaving room for review comments.
  narrow: false,

  // Number of body columns: 2 for the classic AMS-article look,
  // 1 for a single-column layout. `wide-figure` spans all columns
  // either way.
  columns: 1,

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The document's content.
  body,
) = {
  // Formats the author's names in a list with commas and a
  // final "and".
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  // Set document metadata.
  set document(title: title, author: names)

  // Set the body font. AMS uses the LaTeX font.
  set text(size: normal-size, font: "New Computer Modern")

  // Configure the page.
  set page(
    paper: paper-size,
    // The margins depend on the paper size, and are scaled down
    // (divided by 3) when `narrow` is true, leaving full-size,
    // comment-friendly margins when it is false.
    margin: {
      let divisor = if narrow { 3 } else { 1.5 }
      if paper-size != "a4" {
        (
          top: (116pt / 279mm) * 100% / divisor,
          left: (126pt / 216mm) * 100% / divisor,
          right: (128pt / 216mm) * 100% / divisor,
          bottom: (94pt / 279mm) * 100% / divisor,
        )
      } else {
        (
          top: 117pt / divisor,
          left: 118pt / divisor,
          right: 119pt / divisor,
          bottom: 96pt / divisor,
        )
      }
    },

    // Lay out the body in `columns` columns, AMS-article style. The
    // title/author block above uses `scope: "parent"` so it still
    // spans all columns instead of only the first one.
    columns: columns,

    // The page header should show the page number and list of
    // authors, except on the first page. The page number is on
    // the left for even pages and on the right for odd pages.
    header-ascent: 14pt,
    header: context {
      let i = counter(page).get().first()
      if i == 1 { return }
      set text(size: script-size)
      grid(
        columns: (6em, 1fr, 6em),
        align: (start, center, end),
        if calc.even(i) [#i],
        upper(
          if calc.odd(i) { title } else { author-string }
        ),
        if calc.odd(i) { [#i] }
      )
    },

    // On the first page, the footer should contain the page number.
    footer-descent: 12pt,
    footer: context {
      let i = counter(page).get().first()
      if i == 1 {
        align(center, text(size: script-size, [#i]))
      }
    }
  )

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 30pt,
    {
      show std.title: set align(center)
      show std.title: set par(leading: 0.5em)
      show std.title: set text(size: 24pt, weight: "regular")
      show std.title: set block(below: 8.35mm)
      std.title()

      // Display the authors list.
      set par(leading: 0.6em)
      for i in range(calc.ceil(authors.len() / 3)) {
        let end = calc.min((i + 1) * 3, authors.len())
        let is-last = authors.len() == end
        let slice = authors.slice(i * 3, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: 12pt,
          ..slice.map(author => align(center, {
            text(size: 11pt, author.name)
            if "department" in author [
              \ #emph(author.department)
            ]
            if "organization" in author [
              \ #emph(author.organization)
            ]
            if "location" in author [
              \ #author.location
            ]
            if "email" in author {
              if type(author.email) == str [
                \ #link("mailto:" + author.email)
              ] else [
                \ #author.email
              ]
            }
          }))
        )

        if not is-last {
          v(16pt, weak: true)
        }
      }
    }
  )

  // Configure headings.
  // The vertical spacing mimics LaTeX's \section, \subsection and
  // \subsubsection (3.5ex/2.3ex, 3.25ex/1.5ex, 3.25ex/1.5ex).
  set heading(numbering: "1.")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    // Space above and below each heading level.
    let (above, below) = (
      (2.4em, 1.3em),
      (1.9em, 0.9em),
      (1.6em, 0.8em),
    ).at(it.level - 1, default: (1.3em, 0.7em))

    // Level 1 headings are centered and smallcaps,
    // level 2 bold and the other ones italic.
    set text(size: normal-size, weight: 400)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      context if counter(heading).get().first() > 1 {
        colbreak(weak: true)
      }
      counter(figure.where(kind: "theorem")).update(0)
    }
    block(above: above, below: below, sticky: true, width: 100%, {
      if it.level == 1 {
        set align(center)
        smallcaps[#number#it.body]
      } else {
        let styled = if it.level == 2 { strong } else { emph }
        number
        styled(it.body)
      }
    })
  }

  // Leave some space around lists, like LaTeX's \topsep.
  show list: set block(above: 0.9em, below: 0.9em)
  show enum: set block(above: 0.9em, below: 0.9em)

  // Configure lists and links.
  // The list marker sits at the paragraph's first-line indent.
  set list(indent: 1.2em, body-indent: 0.5em)
  set enum(indent: 1.2em, body-indent: 0.5em)
  show link: set text(font: "DejaVu Sans Mono")

  // Block quotes like LaTeX's quote environment: indented on both sides,
  // no quotation marks, no first-line indent.
  show quote.where(block: true): set par(first-line-indent: 0em)
  show quote.where(block: true): set text(size: 0.95em)
  show quote.where(block: true): it => block(
    above: 1.2em, below: 1.2em, inset: (x: 2.5em), {
      it.body
      if it.attribution != none {
        [ #h(1fr) --- #it.attribution]
      }
    },
  )

  // Configure equations.
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)

  // Configure citation and bibliography styles.
  set std.bibliography(style: "springer-mathphys", title: [References])

  show table: set list(indent: 0pt, body-indent: 5pt)
  show table: set enum(indent: 0pt, body-indent: 5pt)
  show table: set block(above: 20pt, below: 20pt)
  set figure(gap: 17pt)
  show figure: set block(above: 12.5pt, below: 15pt)
  show figure: it => {
    // Customize the figure's caption.
    show figure.caption: caption => {
      v(-12pt)
      smallcaps(caption.supplement)
      if caption.numbering != none {
        [ ]
        numbering(caption.numbering, ..caption.counter.at(it.location()))
      }
      [. ]
      caption.body
    }

    // We want a bit of space around tables and images.
    show selector.or(table, image): pad.with(x: 13pt)

    // Display the figure's body and caption.
    it
  }

  // Theorems.
  show figure.where(kind: "theorem"): set align(start)
  show figure.where(kind: "theorem"): it => block(spacing: 11.5pt, {
    strong({
      it.supplement
      if it.numbering != none {
        [ ]
        it.counter.display(it.numbering)
      }
      [.]
    })
    [ ]
    emph(it.body)
  })

  // // Display the title and authors.
  // show std.title: set text(size: large-size, weight: 700)
  // v(35pt, weak: true)
  // align(center, upper({
  //   std.title()
  //   v(25pt, weak: true)
  //   text(size: footnote-size, author-string)
  // }))

  // Configure paragraph properties.
  set par(spacing: 0.85em, first-line-indent: 1.2em, justify: true, leading: 0.58em)

  // Display the abstract
  if abstract != none {
    v(20pt, weak: true)
    set text(script-size)
    show: pad.with(x: 35pt)
    smallcaps[Abstract. ]
    abstract
  }

  // Display the article's contents.
  v(29pt, weak: true)
  body

  // Display the bibliography, if any is given.
  if bibliography != none {
    show std.bibliography: set text(footnote-size)
    show std.bibliography: set block(above: 11pt)
    show std.bibliography: pad.with(x: 0.5pt)
    bibliography
  }
}

// The ASM template also provides a theorem function.
#let theorem(body, numbered: true) = figure(
  body,
  kind: "theorem",
  supplement: [Theorem],
  numbering: if numbered { n => counter(heading).display() + [#n] }
)

// And a function for a proof.
#let proof(body) = block(spacing: 11.5pt, {
  emph[Proof.]
  [ ]
  body
  h(1fr)

  // Add a word-joiner so that the proof square and the last word before the
  // 1fr spacing are kept together.
  sym.wj

  // Add a non-breaking space to ensure a minimum amount of space between the
  // text and the proof square.
  sym.space.nobreak

  $square.stroked$
})

// A figure that spans both columns in a two-column layout.
//
// This uses `figure`'s own `placement`/`scope` support rather than
// wrapping the figure in a separate `place`: `place` is not a
// referenceable element, so a label attached after a `place(figure(..))`
// call (`#wide-figure(..) <my-label>`) would bind to the `place` and
// `@my-label` would fail to resolve ("cannot reference place"). Letting
// `figure` itself float keeps the figure as the outermost, labelable
// element, exactly like a plain `figure(..) <label>` elsewhere in this
// report. In a one-column layout, floating across "parent" columns is a
// no-op (the column and the page have the same width), so the same call
// also produces a normal full-width figure there, and `wide-figure` can
// be used unconditionally regardless of the page's column count.
//
// Usage is the same as `figure()`, e.g.:
//   #wide-figure(image("diagram.svg"), caption: [A wide diagram]) <fig-label>
#let wide-figure(body, placement: top, ..args) = figure(
  body,
  placement: placement,
  scope: "parent",
  ..args,
)

// A bare table that spans both columns, for the places in this report
// that use `table(...)` directly (no caption/numbering) rather than
// `figure(table(...))`. Same floating mechanism as `wide-figure`, and
// likewise a no-op fallback to a normal full-width table in a
// one-column layout.
//
// A bare `table()` is not a referenceable element in Typst (with or
// without this wrapper), so if you need `@my-label` to point at the
// table, use `wide-figure(table(...), caption: [...]) <my-label>`
// instead.
//
// Usage is the same as `table()`, e.g.:
//   #wide-table(columns: 2, [A], [B], [1], [2])
#let wide-table(..args) = place(
  top,
  float: true,
  scope: "parent",
  clearance: 1.5em,
  table(..args),
)
