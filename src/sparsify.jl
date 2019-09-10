using DataFrames
"""
    sparsify(obj)

`sparsify` removes repetitions of objects from arrays and strings.
This is useful for printing tables with `tabular`.
"""
function sparsify!(obj::CategoricalArray{T, 1, S}) where {T <: AbstractString,  S <: Number}
    dupl = [false; obj[1:end-1] .== obj[2:end]]
    obj[dupl] .= ""
    obj
end
function sparsify!(obj::Array{T}) where T <: AbstractString
    # lagged equality is used to check for duplicates.
    dupl = [false; obj[1:end-1] .== obj[2:end]]
    obj[dupl] .= ""
    obj
end
function sparsify!(obj::Array{T}) where T <: Number
    # Numbers are not processed.
    obj
end
function sparsify!(obj::DataFrame)
    for col in 1:size(obj, 2)
        sparsify!(obj[!,col])
    end
    return obj
end
function sparsify(obj)
    sparsify!(copy(obj))
end
