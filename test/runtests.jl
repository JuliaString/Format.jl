using Format

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)
@static VERSION >= v"0.7.0-DEV.3058" && (using Printf)
@static VERSION < v"0.7.0-DEV" || (using Random)

ts(io) = String(take!(io))

@testset "cformat"    begin include( "cformat.jl" ) end
@testset "fmtspec"    begin include( "fmtspec.jl" ) end
@testset "formatexpr" begin include( "formatexpr.jl" ) end
@testset "fmt"        begin include( "fmt.jl" ) end
