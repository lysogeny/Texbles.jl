Texbles.jl
==========

Basic module to create tables within julia.

Installation
------------

1. Check that your system meets the requirements (see below). If it doesn't install the necessary components.
2. Since this is not a registered package, in the julia REPL (by entering pkg mode using `]`:

    pkg> add https://github.com/lysogeny/Texbles.jl

Requirements
------------

- Julia ≥ 1.1
- A LaTeX installation that understands `standalone` documentclasses for `.pdf` outputs.
- `pdf2svg` for `.svg` outputs.
- `pandoc` for any output that is not `.tex`

Usage
-----

This is most useful for summary tables.

```julia
using Texbles
using RDatasets
using DataFrames
using DataFramesMeta
using Statistics

cars = dataset("datasets", "mtcars")

# Compute a summary table
meanmpg = @linq cars |> 
    groupby([:Gear, :Cyl]) |> 
    orderby([:Gear, :Cyl]) |>
    based_on(MeanMPG = mean(:MPG)) |> 
    transform(Gear=map(x -> string(x), :Gear),
              Cyl=map(x -> string(x), :Cyl),
              MeanMPG=map(x -> round(x), :MeanMPG))

tab = Tabular(meanmpg)

show(tab)
```

(See also example.jl)

This opens the following image in your browser:

![](example.svg)

Todo
----

- [ ] Implement checking for characters that latex cannot understand to convert using `Latexify.jl`
- [ ] Implement better unit tests
- [ ] Write short usage examples
- [ ] Check Windows and Mac OS functionality.
