module RichVehicleRoutingProblem

import JSON2
import Scanner

include("RVRP_data.jl")
include("RVRP_computed_data.jl")
include("RVRP_solution.jl")
include("parser_json.jl")
include("parser_cvrplib.jl")
include("utils.jl")


abstract type AbstractSolver end

"""
    solve(data::RvrpInstance, solver::AbstractSolver)

Starts the solution procedure.
"""
function solve end

"""
    transform_solution(data::RvrpInstance, solver::AbstractSolver, solver_sol::Any)

Transforms the solutin outputed by the solver to the RVRP format.
"""
function transform_solution end

"""
    check_data(data::RvrpInstance, solver::AbstractSolver)

Checks if the date is compatible with the solver provided.
"""
function check_data end


end

