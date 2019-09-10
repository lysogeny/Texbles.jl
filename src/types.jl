"""
    inferspec(table::DataFrame)

Infer table specification based on dataframe column types.
Types inheriting `Number` get assigned a "r", any others an "l"
"""
function inferspec(table::DataFrame)
    types = map(x -> eltype(table[:,x]), names(table))
    spec = map(t -> t <: Number ? "r" : "l", types)
    spec = join(spec)
end
# Todo: Make this more versatile.
