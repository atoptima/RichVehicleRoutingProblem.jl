module RichVehicleRoutingProblem

import JSON2
import Scanner

# Default values
const MAXNUMBER = 10^9

"""
    solve(data::RvrpInstance, solver)

Starts the solution procedure.
"""
function solve end

"""
    supported_features(solver_type)::Vector{BitSet}

Checks if the date is compatible with the solver provided.
"""
function supported_features end

include("RVRP_data.jl")
include("RVRP_computed_data.jl")
include("RVRP_solution.jl")
include("utils.jl")
include("parser_json.jl")
include("parser_cvrplib.jl")
include("instance_check.jl")
include("solution_check.jl")
include("helpers.jl")

# Solvers
include("vroom/interface.jl")
include("jsprit/interface.jl")
include("mock_solver/mock_solver.jl")

end
