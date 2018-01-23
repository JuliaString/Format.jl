__precompile__()

module Format

import Base.show

export FormatSpec, FormatExpr, printfmt, printfmtln, format, generate_formatter
export pyfmt, cfmt, fmt
export fmt_default, fmt_default!, reset!, default_spec, default_spec!

# Deal with mess from #16058
# Later, use Strs package!
isdefined(Main, :ASCIIStr) || (const ASCIIStr = String)
isdefined(Main, :UTF8Str)  || (const UTF8Str = String)
@static if VERSION < v"0.7.0-DEV"
    _findfirst(a, b) = findfirst(b, a)
else
    _findfirst(a, b) = (p = findfirst(equalto(a), b); p == nothing ? 0 : p)
end

include("cformat.jl" )
include("fmtspec.jl")
include("fmtcore.jl")
include("formatexpr.jl")
include("fmt.jl")

end # module Format
