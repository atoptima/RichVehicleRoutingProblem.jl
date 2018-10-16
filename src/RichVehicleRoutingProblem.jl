module RichVehicleRoutingProblem

import JSON2
import JSON

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

