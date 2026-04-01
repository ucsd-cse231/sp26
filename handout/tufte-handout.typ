// Size of the left "margin" (note area)
// #let margin-size = 23.5%
#let margin-size = 35%

// Spacer so that main content and notes don't rub up against each other
#let margin-space = 0.2in

/*
 * Inserts a margin note containing `content`
 *  `dy` can be used to adjust the note content vertically
 */
#let margin-note(dy: -1em, content) = {
  place(
    right,
    dx: margin-size + margin-space,
    dy: dy,
    block(width: margin-size, {
      set text(size: 0.75em)
      set align(left)
      content
    }),
  )
}

/*
 * Renders `content` with the module's text styling.  This is useful for content
 *  that is outside of the `template` container but which should be visually consistent.
 */
#let apply-text-styles(content) = {
  set text(
    font: "TeX Gyre Pagella",
  )
  show heading.where(level: 1): it => text(
    font: "TeX Gyre Pagella",
    size: 12pt,
    weight: "extralight",
    style: "italic",
    {
      v(1em)
      it.body
    },
  )
  show heading.where(level: 2): it => text(
    font: "TeX Gyre Pagella",
    size: 10pt,
    style: "italic",
    it.body,
  )
  content
}


/* Call to wrap `doc` in the handout layout
 *  `title` will be rendered in the page header
 *  `wrapper` should be either `none` or a function that takes `doc` and returns
 *    content.  This can be used to inject custom styles.
 */
#let template(
  title: none,
  author: none,
  date: none,
  wrapper: apply-text-styles,
  doc,
) = {
  set page(header: {
    set text(size: 7pt, weight: "semibold", tracking: 1.25pt)
    h(1fr)
    upper(title)
  })

  let title-block = {
    set text(font: "TeX Gyre Pagella")
    if title != none {
      text(size: 16pt, weight: "bold", title)
      linebreak()
    }
    if author != none or date != none {
      v(0.3em)
      text(size: 10pt, style: "italic", {
        if author != none { author }
        if author != none and date != none { h(1em) }
        if date != none { date }
      })
      linebreak()
    }
    v(0.5em)
  }

  grid(
    columns: (100% - margin-size, margin-size),
    if wrapper != none {
      wrapper(title-block + doc)
    } else {
      title-block + doc
    },
  )
}
