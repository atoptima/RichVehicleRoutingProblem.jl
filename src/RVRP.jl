module RVRP

using JSON2
using JSON

include("RVRP_data.jl")
include("data_gen.jl")
include("parsers.jl")


abstract type AbstractSolver end

"""
    solve(data::RvrpProblem, solver::AbstractSolver)

Start the solution procedure.
"""
function solve end



end

