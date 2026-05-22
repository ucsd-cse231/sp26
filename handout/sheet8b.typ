#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show raw.where(block: true, lang: "lisp"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "asm"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "sh"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "rust"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show raw.where(block: true, lang: "clojure"): it => block(
  stroke: 0.5pt + luma(150),
  inset: (x: 0.75em, y: 0.65em),
  radius: 2pt,
  width: 100%,
  it,
)

#show: assignment.with(
  course: smallcaps[CSE 231 Spring 2026],
  title: "Worksheet 8B",
  authors: (
    (name: "NAME _________________________ ", id: ""),
    (name: "SID _________________________ ", id: ""),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 5, day: 21),
)


#quiz(name: "Garbage in the middle")[

  #grid(
    columns: (0.3fr, 1fr),
    gutter: 1em,
    [
      Which cells are garbage?

      1. `0x00` and `0x08`
      2. `0x08` and `0x10`
      3. `0x18` and `0x20`
      4. None
      5. All

    ],
    [
      #image("img/gc1.png", width: 60%)
    ],
  )

]

#quiz(name: "Garbage in the middle with Stack")[
  #grid(
    columns: (0.3fr, 1fr),
    gutter: 1em,
    [
      Which cells are garbage?

      1. `0x00` and `0x08`
      2. `0x08` and `0x10`
      3. `0x10` and `0x18`
      4. None
      5. All
    ],
    [
      #image("img/gc2.png", width: 60%)
    ],
  )
]

#quiz(name: "Recursive Data")[
  What is the heap when `range(0, 3)` _returns_?
  #grid(
    columns: (0.9fr, 1fr),
    gutter: 1em,
    [
      #image("img/gc3a.png", width: 100%)
    ],
    [
      #image("img/gc3b.png", width: 115%)
    ],
  )
]

#colbreak()


#quiz(name: "Recursive Data")[


  #grid(
    columns: (0.23fr, 0.3fr),
    gutter: 1em,
    [
      #image("img/gc4.png", width: 90%)
    ],
    [
      What is the value of `l` at the point indicated by the red arrow?

      1. `0x30`
      2. `0x31`
      3. `0x50`
      4. `0x51`
      5. `0x60`

    ],
  )
]

#quiz(name: "Live Cells")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #image("img/gc5.png", width: 80%)
    ],
    [
      #image("img/gc7.png", width: 80%)
    ],
  )
]

#quiz(name: "What should be printed?")[
  #image("img/gc6.png", width: 40%)
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 2.5cm, stroke: 0.5pt)
]
