module RichVehicleRoutingProblem

import JSON2
import JSON

include("RVRP_data.jl")
include("RVRP_solution.jl")
include("data_gen.jl")
include("parsers.jl")


abstract type AbstractSolver end

"""
    solve(data::RvrpProblem, solver::AbstractSolver)

Starts the solution procedure.
"""
function solve end

"""
    transform_solution(data::RvrpProblem, solver::AbstractSolver, solver_sol::Any)

Transforms the solutin outputed by the solver to the RVRP format.
"""
function transform_solution end

"""
    check_data(data::RvrpProblem, solver::AbstractSolver)

Checks if the date is compatible with the solver provided.
"""
function check_data end


end

