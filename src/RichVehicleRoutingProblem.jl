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

"""
    check_data(data::RvrpProblem, solver::AbstractSolver)

Check if the date is compatible with the solver provided.
"""
function check_data end


end

