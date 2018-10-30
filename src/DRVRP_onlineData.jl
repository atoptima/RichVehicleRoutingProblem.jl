# To use the solution, the input data is required


struct CurrentState
    id::String
    instance_id::String
    ongoing_routes::Vector{Route} # holds the backlog of uncompleted requests
    completed_pickup_ids::Vector{String} # the full request is fulfilled 
    completed_delivery_ids::Vector{String} # the full request is fulfilled 
    completed_shipment_ids::Vector{String} # the full request is fulfilled 
    assigned_pickup_ids::Vector{String} # the request is partially fulfilled 
    uncompleted_delivery_ids::Vector{String} # the request is partially fulfilled 
    uncompleted_shipment_ids::Vector{String} # the request is partially fulfilled 
    unassigned_pickup_ids::Vector{String} # the full request is unfulfilled 
    unassigned_delivery_ids::Vector{String} # the full request is unfulfilled 
    unassigned_shipment_ids::Vector{String} # the full request is unfulfilled 
end


struct route_update
    id::String
    route_id::String
    action_seq_index::Int
    observed_start_time::Float64
end

struct request_update
    id::String
    request_type::Int # 0 - Depot, 1 - Pickup, 2 - Delivery, 3 otherOperation
    request_id::String # index of the request in the associated vector depots pickups deliveries or shipme
    incident_type::Int # 0 
    route_id::String
    action_seq_index::Int
end
