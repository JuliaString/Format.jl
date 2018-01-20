using Format

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

ts(io) = String(take!(io))

include( "cformat.jl" )
include( "fmtspec.jl" )
include( "formatexpr.jl" )
include( "fmt.jl" )
