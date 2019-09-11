"""
    pdf2svg(in::AbstractString, out::AbstractString)

Call `pdf2svg` to convert `in` to `out` from pdf to svg.
"""
function pdf2svg(in::AbstractString, out::AbstractString=splitext(in)[1]*".svg")
    cmd = `pdf2svg $in $out`
    run(cmd)
    return out
end

"""
    tex2pdf(in::AbstractString, out::AbstractString)

Convert a tex file to a pdf using pdflatex.
"""
function tex2pdf(in::AbstractString, out::AbstractString=splitext(in)[1]*".pdf")
    base_name = basename(in)
    name_base = splitext(base_name)[1]
    mktempdir() do dir
        temp_file = joinpath(dir, base_name)
        temp_out = joinpath(dir, name_base*".pdf")
        cp(in, temp_file)
        output = cd(dir) do
          outpipe = Pipe()
          ret = run(pipeline(`pdflatex $temp_file -interaction nonstopmode -halt-on-error`, outpipe))
          close(outpipe.in)
          if ret.exitcode != 0
            lines=readlines(outpipe)
            error("call to pdflatex failed: $lines")
          end
        end
        cp(temp_out, out, force=true)
    end
    return out
end

"""
    tex2svg

Convert tex to svg using tex2pdf and then pdf2svg
"""
tex2svg = pdf2svg ∘ tex2pdf

"""
    pandoc(in::AbstractString, out::AbstractString)

Call `pandoc` to convert `in` to `out`
"""
function pandoc(in::AbstractString, out::AbstractString)
    cmd = `pandoc $in -o $out`
    run(cmd)
    return out
end
