using Format
using Compat.Test
using Compat.Printf
using Compat.Random

@testset "cformat"    begin include( "cformat.jl" ) end
@testset "fmtspec"    begin include( "fmtspec.jl" ) end
@testset "formatexpr" begin include( "formatexpr.jl" ) end
@testset "fmt"        begin include( "fmt.jl" ) end
