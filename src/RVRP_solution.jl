# To use the solution, the input data is required

mutable struct Action
    id::String
    location_id::String
    operation_type::Int # 0- Depot, 1 - Pickup, 2 - Delivery, 3 - otherOperation # should be picked quantity
    request_id::String # if any request is linked to a request the operation
    scheduled_start_time::Float64 # post-compute
end

mutable struct Route
    id::String
    vehicle_set_id::String
    sequence::Vector{Action}
    end_status::Int # 0 returnToStartDepot, 1 returnToOtherDepot, 2 ongoing # post-compute
    # path::OSRMpath     # TODO: add OSRM path here
end

mutable struct RvrpSolution
    id::String
    instance_id::String
    cost::Float64 # post-compute
    routes::Vector{Route}
    unassigned_request_ids::Vector{String} # among semi-mandatory or optional request # post-compute
end
