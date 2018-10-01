__precompile__(true)

module Format

import Base.show
using Compat
using Compat.Printf
const V6_COMPAT = VERSION < v"0.7.0-DEV"

_stdout() = @static V6_COMPAT ? STDOUT : stdout
_codeunits(s) = Vector{UInt8}(@static V6_COMPAT ? s : codeunits(s))
@static if V6_COMPAT
    const m_eval = eval
else
    m_eval(expr) = Core.eval(@__MODULE__, expr)
end

export FormatSpec, FormatExpr, printfmt, printfmtln, format, generate_formatter
export pyfmt, cfmt, fmt
export fmt_default, fmt_default!, reset!, default_spec, default_spec!

# Deal with mess from #16058
# Later, use Strs package!
isdefined(Main, :ASCIIStr) || (const ASCIIStr = String)
isdefined(Main, :UTF8Str)  || (const UTF8Str = String)
isdefined(Main, :AbstractChar) || (const AbstractChar = Char)

include("cformat.jl" )
include("fmtspec.jl")
include("fmtcore.jl")
include("formatexpr.jl")
include("fmt.jl")

end # module Format
