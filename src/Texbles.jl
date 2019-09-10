module Texbles
    import DataFrames
    export Tabular, AbstractTable, sparsify, sparsify!, show, save, display, string

    include("sparsify.jl")
    include("open.jl")
    include("convert.jl")
    include("types.jl")

    # Table types
    abstract type AbstractTable end

    """
        Tabular(data::DataFrame; spec::Union{Nothing, AbstractString} = nothing, sparse::Bool=true)

    Create a new tabular object.

    # Arguments:
    - `data::DataFrame` data to represent as tabular
    - `spec::Union{Nothing, AbstractString` spec for table alignment. If `nothing`, it is inferred from types using `inferspec`
    - `sparse::Bool` indicates if repetitions in strings should be removed. This will make a table more readable in some instances.
    ```
    """
    mutable struct Tabular <: AbstractTable
        data::DataFrame
        spec::AbstractString
        function Tabular(data::DataFrame; spec::Union{Nothing, AbstractString} = nothing, sparse::Bool = true)
            if isnothing(spec)
                spec = inferspec(data)
            end
            if sparse
                data = sparsify(data)
            end
            new(data, spec)
        end
    end

    """
        string(table::AbstractTable, filename::AbstractString, full::Bool=false) 

    Return the tabular as a string representation.

    # Arguments:
    - `table::AbstractTable` a table
    - `full::Bool` indicates whether `table` should be represented as a full LaTeX file or just a tabular environment.
    """
    function Base.string(table::AbstractTable; full::Bool=false)
        (r, c) = size(table.data)
        head = join(names(table.data), " & ") * "\\\\"
        rows = Array{String, 1}(undef, r)
        for (i, row) in enumerate(eachrow(table.data))
            rows[i] = join(row, " & ")*"\\\\"
        end
        main = join(rows, "\n")
        str = """
        \\begin{tabular}{$(table.spec)}
        \\toprule
        $head
        \\midrule
        $main
        \\bottomrule
        \\end{tabular}
        """
        if full
            str = """
            \\documentclass{standalone}
            \\usepackage[T1]{fontenc}
            \\usepackage{booktabs} % This is needed for the \\(top|mid|bottom)rule
            \\begin{document}
            $str
            \\end{document}
            """
        end
        return str
    end

    function Base.display(table::AbstractTable)
        print("$(typeof(table)) {$(table.spec)}:\n")
        display(string(table))
    end

    """
        save(table::AbstractTable, filename::AbstractString)

    Save the table to file specified by `filename`.
    Type of the target file is inferred from the filename's ending.
    """
    function save(table::AbstractTable, filename::AbstractString)
        # We first figure out where to put a tex file
        tempbase = tempname()
        tempfile = tempbase * ".tex"
        # We save the tabular text to the temporary file
        open(tempfile, "w") do file
            tab_text = string(table, full=true)
            write(file, tab_text)
        end
        # Now figure out what to do with the tex
        extension = splitext(filename)[2]
        if extension == ".tex"
            # Here we just copy
            result = cp(tempfile, filename)
        elseif extension == ".svg"
            # Here we need to first pandoc, then pdf2svg
            intermediate_pdf = tempbase * ".pdf"
            tex2pdf(tempfile, intermediate_pdf)
            result = pdf2svg(intermediate_pdf, filename)
            rm(intermediate_pdf)
        elseif extension == ".pdf"
            result = tex2pdf(tempfile, filename)
        else
            # Here we just try to convert and hope for the best
            result = pandoc(tempfile, filename)
        end
        rm(tempfile)
        return result
    end

    """
        show(table::AbstractTable, format::AbstractString="svg")

    Show the `table` in `format`. This saves the table as a temporary file in
    format `format`, and then tries to open the file for user interaction.
    """
    function show(table::AbstractTable; format::AbstractString="svg")
        # This function will compile a table and show it
        tempbase = tempname()
        filename = "$tempbase.$format"
        save(table, filename)
        xdg_open(filename)
    end
end

# Let's define the functionality I want.
# - Take a dataframe
# - Convert dataframe to tabular.
# - Save tabular as pdf, tex, svg, ...
#
#
# Proposal:
# - Object tabular stores dataframe.
# - save() saves files. Format is inferred from file ending.
# - use pandoc as much as possible to avoid dealing with pdflatex and the mess that it leaves behind.
# - Alternatively don't use pandoc as I want to use the `standalone` documentclass
# - Pandoc probably allows you to change the documentclass as well.
