__precompile__()

module Format

import Base.show

export FormatSpec, FormatExpr, printfmt, printfmtln, format, generate_formatter
export pyfmt, cfmt, fmt
export fmt_default, fmt_default!, reset!, default_spec, default_spec!

# Deal with mess from #16058
# Later, use Strs package!
const ASCIIStr = String
const UTF8Str = String
const ByteStr = String
const bytestr = String

include("cformat.jl" )
include("fmtspec.jl")
include("fmtcore.jl")
include("formatexpr.jl")
include("fmt.jl")

end # module Format
