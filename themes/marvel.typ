// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "../src/exports.typ": *

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
/// 
/// 

#let footer-a(self, mono: false) = {
  let im = if mono {
    "assets/marvel/snf_white_on_transparent.png"
  } else {
    "assets/marvel/snf_color_on_transparent.png"
  }
  image(im, height: 1em)
}
#let footer-b(self, mono: false) = {
  let f = if mono {
    self.colors.neutral-lightest
  } else {
    self.colors.primary
  }
  text(fill: f, weight: "bold", size: 0.6em, "NCCR MARVEL - Slide " + utils.slide-counter.display())
}

#let footer-c(self, mono: false) = {
  let im = if mono {
    "assets/marvel/marvel_hexagons_white_on_transparent.png"
  } else {
    "assets/marvel/marvel_hexagons_color_on_transparent.png"
  }
  image(im, height: 1em)
}

#let default-footer(self, mono: false) = {
  set std.align(center + bottom)
  {
    let cell(..args, it, align: none) = components.cell(
      ..args,
      std.align(horizon + align, text(fill: white, it)),
    )

    show: block.with(width: 100%, height: auto)
    grid(
      columns: (1fr, 1fr, 1fr),
      cell(align: left, utils.call-or-display(self, footer-a(self, mono: mono))),
      cell(align: center, utils.call-or-display(self, footer-b(self, mono: mono))),
      cell(align: right, utils.call-or-display(self, footer-c(self, mono: mono))),
    )
    v(0.5em)
  }
}
#let default-header(self) = {
  set std.align(top)
  v(1.25em)
  let title = utils.call-or-display(self, self.store.header)

  grid(
    rows: (auto),
    row-gutter: 3mm,
    block(
      text(fill: self.colors.primary, weight: "bold", size: 1.5em, title),
    ),
    components.bar(height: 2pt, self.colors.primary)
  )
}

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {

  if align != auto {
    self.store.align = align
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: default-header(self),
      footer: default-footer(self, mono: false),
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: marvel-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
  )
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    if info.logo != none {
      place(right, text(fill: self.colors.primary, info.logo))
    }
    std.align(
      center + horizon,
      {
        block(
          inset: 0em,
          breakable: false,
          {
            text(size: 2em, fill: self.colors.primary, strong(info.title))
            if info.subtitle != none {
              parbreak()
              text(size: 1.5em, fill: self.colors.primary, info.subtitle)
            }
          },
        )
        grid(
          columns: (1fr,) * calc.min(info.authors.len(), 3),
          column-gutter: 1em,
          row-gutter: 1em,
          ..info.authors.map(author => text(weight: "bold", fill: self.colors.neutral-darkest, author))
        )
        v(-1.7em)
        if info.institution != none {
          linebreak()
          text(size: .8em, info.institution)
        }
        parbreak()
        if info.event != none {
          text(size: .8em, info.event, fill: self.colors.neutral-darkest)
        }
        if info.location != none {
          if info.event != none {
            text("  |  ", fill: self.colors.neutral-darkest)
          }
          text(size: .8em, info.location, fill: self.colors.neutral-darkest)
        }
        if info.date != none {
          if info.event != none or info.location != none {
            text("  |  ", fill: self.colors.neutral-darkest)
          }
          text(size: .8em, utils.display-info-date(self), fill: self.colors.neutral-darkest)
        }
      },
    )
  }
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
/// 
/// - level (int, none): is the level of the heading.
///
/// - numbered (boolean): is whether the heading is numbered.
///
/// - body (auto): is the body of the section. This will be passed automatically by Touying.
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {

  let args = (:)
  args.fill = rgb(self.colors.primary)

  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    set text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold")
    stack(
      dir: ttb,
      spacing: .65em,
      utils.display-current-heading(level: level, numbered: numbered),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.bar(height: 2pt, self.colors.neutral-lightest),
      ),
    )
    body
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      footer: default-footer(self, mono: true),
      ..args,
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - background-color (color, none): is the background color of the slide. Default is the primary color.
///
/// - background-img (string, none): is the background image of the slide. Default is none.
#let focus-slide(config: (:), background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, std.align(horizon, body))
})


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
#let matrix-slide(config: (:), columns: none, align: left + horizon, rows: none, ..bodies) = touying-slide-wrapper(self => {

  self = utils.merge-dicts(
    self,
    config-page(header: default-header(self), footer: default-footer(self, mono: false)),
  )
  touying-slide(self: self, config: config, composer: components.checkerboard.with(columns: columns, rows: rows, alignment: align, color1: white, color2: white), ..bodies)
})


#let marvel-red = rgb("#ff2600")
#let marvel-lightred = rgb("#ff8d7d")
#let marvel-grey = rgb("#7c7c7c")

/// Touying marvel theme.
///
/// Example:
///
/// ```typst
/// #show: marvel-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. Default is `16-9`.
/// 
/// - align (alignment): is the alignment of the slides. Default is `top`.
///
/// - progress-bar (boolean): is whether to show the progress bar. Default is `true`.
///
/// - header (content, function): is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - header-right (content, function): is the right part of the header. Default is `self.info.logo`.
///
/// - footer-columns (tuple): is the columns of the footer.
///
/// - footer-a (content, function): is the left part of the footer.
///
/// - footer-b (content, function): is the middle part of the footer.
///
/// - footer-c (content, function): is the right part of the footer.
#let marvel-theme(
  aspect-ratio: "16-9",
  align: top,
  header: utils.display-current-heading(level: 2),
  header-right: self => utils.display-current-heading(level: 1) + h(.3em) + self.info.logo,
  footer-columns: (1fr, 1fr, 1fr),
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.5em, bottom: 3em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 18pt)
        show heading: set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: marvel-red,
      secondary: marvel-lightred,
      tertiary: marvel-grey,
      neutral-lightest: rgb("#ffffff"),
      neutral: rgb("#7c7c7c"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
    ),
    ..args,
  )

  body
}