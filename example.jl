using Texbles
using RDatasets
using DataFrames
using DataFramesMeta
using Statistics

cars = dataset("datasets", "mtcars")

meanmpg = @linq cars |> 
    groupby([:Gear, :Cyl]) |> 
    orderby([:Gear, :Cyl]) |>
    based_on(MeanMPG = mean(:MPG)) |> 
    transform(Gear=map(x -> string(x), :Gear),
              Cyl=map(x -> string(x), :Cyl),
              MeanMPG=map(x -> round(x), :MeanMPG))

tab = Tabular(meanmpg)

save(tab, "example.svg")

