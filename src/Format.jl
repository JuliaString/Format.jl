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
    _replace(s, p) = replace(s, p.first, p.second)
    _replace(s, p; count=c) = replace(s, p.first, p.second, c)
    _findfirst(ch, str) = findfirst(str, ch)
    _findnext(ch, str, pos) = findnext(str, ch, pos)
    const _searchindex = searchindex
else
    const _replace = replace
    _findfirst(ch, str) = (p = findfirst(equalto(ch), str); p == nothing ? 0 : p)
    _findnext(ch, str, pos) = (p = findnext(equalto(ch), str, pos); p == nothing ? 0 : p)
    _searchindex(s, t) = first(findfirst(t, s))
end

include("cformat.jl" )
include("fmtspec.jl")
include("fmtcore.jl")
include("formatexpr.jl")
include("fmt.jl")

end # module Format
