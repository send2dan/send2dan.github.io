// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#let brand-color = (
  background: rgb("#ffffff"),
  black: rgb("#231f20"),
  blue: rgb("#005eb8"),
  blue-aqua: rgb("#00a9ce"),
  blue-bright: rgb("#0072ce"),
  blue-dark: rgb("#003087"),
  blue-light: rgb("#41b6e6"),
  cyan: rgb("#00a9ce"),
  danger: rgb("#da291c"),
  dark: rgb("#425563"),
  foreground: rgb("#231f20"),
  green: rgb("#009639"),
  green-aqua: rgb("#00a499"),
  green-dark: rgb("#006747"),
  green-light: rgb("#78be20"),
  grey-dark: rgb("#425563"),
  grey-mid: rgb("#768692"),
  grey-pale: rgb("#e8edee"),
  indigo: rgb("#003087"),
  info: rgb("#41b6e6"),
  light: rgb("#e8edee"),
  orange: rgb("#ed8b00"),
  pink: rgb("#ae2573"),
  pink-dark: rgb("#7c2855"),
  primary: rgb("#005eb8"),
  purple: rgb("#330072"),
  red: rgb("#da291c"),
  red-dark: rgb("#8a1538"),
  secondary: rgb("#425563"),
  success: rgb("#009639"),
  teal: rgb("#00a499"),
  tertiary: rgb("#e8edee"),
  warning: rgb("#ffb81c"),
  white: rgb("#ffffff"),
  yellow: rgb("#fae100"),
  yellow-warm: rgb("#ffb81c")
)
#set page(fill: brand-color.background)
#set text(fill: brand-color.foreground)
#set table.hline(stroke: (paint: brand-color.foreground))
#set line(stroke: (paint: brand-color.foreground))
#let brand-color-background = (
  background: color.mix((brand-color.background, 15%), (brand-color.background, 85%)),
  black: color.mix((brand-color.black, 15%), (brand-color.background, 85%)),
  blue: color.mix((brand-color.blue, 15%), (brand-color.background, 85%)),
  blue-aqua: color.mix((brand-color.blue-aqua, 15%), (brand-color.background, 85%)),
  blue-bright: color.mix((brand-color.blue-bright, 15%), (brand-color.background, 85%)),
  blue-dark: color.mix((brand-color.blue-dark, 15%), (brand-color.background, 85%)),
  blue-light: color.mix((brand-color.blue-light, 15%), (brand-color.background, 85%)),
  cyan: color.mix((brand-color.cyan, 15%), (brand-color.background, 85%)),
  danger: color.mix((brand-color.danger, 15%), (brand-color.background, 85%)),
  dark: color.mix((brand-color.dark, 15%), (brand-color.background, 85%)),
  foreground: color.mix((brand-color.foreground, 15%), (brand-color.background, 85%)),
  green: color.mix((brand-color.green, 15%), (brand-color.background, 85%)),
  green-aqua: color.mix((brand-color.green-aqua, 15%), (brand-color.background, 85%)),
  green-dark: color.mix((brand-color.green-dark, 15%), (brand-color.background, 85%)),
  green-light: color.mix((brand-color.green-light, 15%), (brand-color.background, 85%)),
  grey-dark: color.mix((brand-color.grey-dark, 15%), (brand-color.background, 85%)),
  grey-mid: color.mix((brand-color.grey-mid, 15%), (brand-color.background, 85%)),
  grey-pale: color.mix((brand-color.grey-pale, 15%), (brand-color.background, 85%)),
  indigo: color.mix((brand-color.indigo, 15%), (brand-color.background, 85%)),
  info: color.mix((brand-color.info, 15%), (brand-color.background, 85%)),
  light: color.mix((brand-color.light, 15%), (brand-color.background, 85%)),
  orange: color.mix((brand-color.orange, 15%), (brand-color.background, 85%)),
  pink: color.mix((brand-color.pink, 15%), (brand-color.background, 85%)),
  pink-dark: color.mix((brand-color.pink-dark, 15%), (brand-color.background, 85%)),
  primary: color.mix((brand-color.primary, 15%), (brand-color.background, 85%)),
  purple: color.mix((brand-color.purple, 15%), (brand-color.background, 85%)),
  red: color.mix((brand-color.red, 15%), (brand-color.background, 85%)),
  red-dark: color.mix((brand-color.red-dark, 15%), (brand-color.background, 85%)),
  secondary: color.mix((brand-color.secondary, 15%), (brand-color.background, 85%)),
  success: color.mix((brand-color.success, 15%), (brand-color.background, 85%)),
  teal: color.mix((brand-color.teal, 15%), (brand-color.background, 85%)),
  tertiary: color.mix((brand-color.tertiary, 15%), (brand-color.background, 85%)),
  warning: color.mix((brand-color.warning, 15%), (brand-color.background, 85%)),
  white: color.mix((brand-color.white, 15%), (brand-color.background, 85%)),
  yellow: color.mix((brand-color.yellow, 15%), (brand-color.background, 85%)),
  yellow-warm: color.mix((brand-color.yellow-warm, 15%), (brand-color.background, 85%))
)
#let brand-logo-images = (
  nhsr-logo: (
    alt: "logo",
    path: "logo\\full-colour-logo.jpg"
  )
)
#let brand-logo = (
  large: (
    alt: "logo",
    path: "logo\\full-colour-logo.jpg"
  ),
  medium: (
    alt: "logo",
    path: "logo\\full-colour-logo.jpg"
  ),
  small: (
    alt: "logo",
    path: "logo\\full-colour-logo.jpg"
  )
)
#set text(weight: 400, )
#set par(leading: 0.75em)
#show heading: set text(font: ("Frutiger W01",), weight: 700, fill: rgb("#005eb8"), )
#show heading: set par(leading: 0.5em)
#show link: set text(fill: rgb("#005eb8"), )

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)
#set page(background: align(left+top, box(inset: 0.75in, image("logo\\full-colour-logo.jpg", width: 1.5in, alt: "logo"))))

#show: doc => article(
  title: [Dr Daniel Weiand],
  authors: (
    ( name: [Daniel Weiand],
      affiliation: [Newcastle upon Tyne Hospitals NHS Foundation Trust],
      email: [] ),
    ),
  date: [Thursday, 26 February, 2026],
  font: ("Frutiger W01",),
  heading-family: ("Frutiger W01",),
  heading-weight: 700,
  heading-color: rgb("#005eb8"),
  heading-line-height: 0.5em,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= About
<about>
My name is #strong[Dr Daniel Weiand MBChB FRCPath RCPathME MClinEd MBCS PGCertClinicalDataScience] and I work as a Consultant Medical Microbiologist at #link("https://www.newcastle-hospitals.nhs.uk/")[Newcastle upon Tyne Hospitals NHS Foundation Trust];.

- I joined Newcastle upon Tyne Hospitals NHS Foundation Trust (NUTH) as a Consultant in 2015, with special interests in nephrology, urology, solid organ transplantation (kidney and pancreas), vascular surgery, medical education, clinical informatics (#link("https://twitter.com/hashtag/RStats")[\#RStats] #link("https://twitter.com/NHSrCommunity")[#cite(<NHSrCommunity>, form: "prose");];) and quality improvement.
- Before moving to the North East of England, I trained in Aberdeen, Sheffield, York, Hull and Leeds.
- My additional roles and responsibilities include:
  - Clinical Informatics Lead for Clinical and Diagnostic Services (Board 8) at NUTH
  - Associate Clinical Lecturer at Newcastle University
  - Examiner for the Royal College of Pathologists (RCPath)
  - "Q" fellow at The Health Foundation
  - Member of The British Computer Society (BCS)
  - Member of the Data Access Committee (DAC) for the #link("https://northeastnorthcumbria.nhs.uk/our-work/secure-data-environment/")[North East and North Cumbria (NENC) Secure Data Environment (SDE)]
- In 2025, I was awarded the Postgraduate Certificate (PGCert) in Clinical Data Science by the University of Manchester.

= Favourite Quote
<favourite-quote>
"All models are wrong, but some are useful." - George Box

= Links
<links>
- #link("https://laboratories.newcastle-hospitals.nhs.uk/")[Integrated Laboratory Medicine at Newcastle upon Tyne Hospitals NHS Foundation Trust]
- #link("https://twitter.com/send2dan?lang=en")[Twitter/X: \@send2dan]
- #link("https://github.com/send2dan/public/")[GitHub: send2dan]
- #link("https://orcid.org/0000-0001-5854-3452")[ORCiD: 0000-0001-5854-3452]
- #link("https://scholar.google.co.uk/citations?user=MlVn2FQAAAAJ&hl=en")[Google Scholar]
