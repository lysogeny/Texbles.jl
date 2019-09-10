"""
    xdg_open(filename::AbstractString)

This function calls xdg_open on a given filehandle.
"""
function xdg_open(filename::AbstractString)
    cmd = `xdg-open $(filename)`
    return run(cmd)
end
# Todo: implement this for macos and windows. Plots.jl has a similar function.
