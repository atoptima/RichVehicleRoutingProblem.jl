module RichVehicleRoutingProblem

import JSON2
import Scanner

# Default values
const MAXNUMBER = 10^9

include("RVRP_data.jl")
include("RVRP_computed_data.jl")
include("RVRP_solution.jl")
include("utils.jl")
include("parser_json.jl")
include("parser_cvrplib.jl")
include("instance_check.jl")

end
