__precompile__(true)

module Format

import Base.show

using Printf
const PF = @static VERSION >= v"1.4.0-DEV.180" ? Printf : Base.Printf

_stdout() = stdout
_codeunits(s) = Vector{UInt8}(codeunits(s))
m_eval(expr) = Core.eval(@__MODULE__, expr)

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
