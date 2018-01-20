using Format

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

ts(io) = String(take!(io))

using SpecialFunctions # Get erfinv

@testset "cformat" begin
    include( "cformat.jl" )
end
@testset "fmtspec" begin
    include( "fmtspec.jl" )
end
@testset "formatexpr" begin
    include( "formatexpr.jl" )
end
@testset "fmt" begin
    include( "fmt.jl" )
end
