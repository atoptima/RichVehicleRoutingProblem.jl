# To use the solution, the input data is required

struct Action
    id::String
    action_type::Int # 0- Depot, 1 - Pickup, 2 - Delivery, 3 - otherOperation
    request_id::String # index of the request in the associated vector depots pickups deliveries or shipment
    scheduled_start_time::Float64
end

struct Route
    id::String
    vehicle_set_id::String
    sequence::Vector{Action}
    end_status::Int # 0 returnToStartDepot, 1 returnToOtherDepot, 2 ongoing
    # TODO: add OSRM path here
    # path::Path
end

struct RVRPfinalState # received as the target end of period situation
    id::String
    ongoing_routes::Vector{Route} # holds the backlog of uncompleted requests
    uncompleted_request_ids::Vector{String} # the request is partially fulfilled 
end


struct RvrpSolution
    id::String
    instance_id::String
    cost::Float64
    routes::Vector{Route}
    unassigned_request_ids::Vector{String}
    final_state::RVRPfinalState  # the request is partially fulfilled 
end
