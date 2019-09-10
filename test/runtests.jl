using DataFrames
using Test

# Prepare a dataset
channels = ["red", "green", "blue"]
names = [
    "GreenYellow", "Chartreuse", "LawnGreen", "Lime", "LimeGreen", "PaleGreen",
    "LightGreen", "MediumSpringGreen", "SpringGreen", "MediumSeaGreen",
    "SeaGreen", "ForestGreen", "Green", "DarkGreen", "YellowGreen",
    "OliveDrab", "Olive", "DarkOliveGreen", "MediumAquamarine", "DarkSeaGreen",
    "LightSeaGreen", "DarkCyan", "Teal",
]
values = [
    0xADFF2F, 0x7FFF00, 0x7CFC00, 0x00FF00, 0x32CD32, 0x98FB98, 0x90EE90,
    0x00FA9A, 0x008080, 0x00FF7F, 0x3CB371, 0x2E8B57, 0x228B22, 0x008000,
    0x006400, 0x9ACD32, 0x6B8E23, 0x808000, 0x556B2F, 0x66CDAA, 0x8FBC8B,
    0x20B2AA, 0x008B8B
]

reds = map(x -> x >> 16, 0xff0000 .& values) |> x -> convert(Array{UInt8, 1}, x)
greens = map(x -> x >> 8, 0x00ff00 .& values) |> x -> convert(Array{UInt8, 1}, x)
blues = map(x -> x >> 0, 0x0000ff .& values) |> x -> convert(Array{UInt8, 1}, x)

entries = collect(zip(Iterators.product(names, channels)...))
colours = DataFrame(name=collect(entries[1]), channel=collect(entries[2]))
colours.value = [reds; greens; blues]
colours = @orderby(colours, :name, :channel)

tab = Tabular(colours)

@test typeof(tab) <: AbstractTable
@test typeof(tab) <: Tabular
@test typeof(tab.data) <: DataFrame
@test typeof(tab.spec) <: AbstractString

# Test that various file types can be produced
# Problematically doesn't test if the various files are in fact the files that
# we want.
map(["tex", "svg", "pdf", "md", "html"]) do ending
    mktempdir() do dir
        filename = joinpath(dir, "test.$ending")
        save(tab, filename)
        @test isfile(filename)
    end
end
