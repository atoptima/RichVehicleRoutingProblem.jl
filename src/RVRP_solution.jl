# To use the solution, the input data is required

struct Action
    id::String
    request_type::Int # 0 - Depot, 1 - Pickup, 2 - Delivery, 3 - otherOperation
    request_id::String # index of the request in the associated vector depots pickups deliveries or shipment
    scheduled_start_time::Float64
end

struct Route
    id::String
    vehicle_set_id::String
    sequence::Vector{Action}
    # TODO: add OSRM path here
    # path::Path
end

struct RvrpSolution
    id::String
    instance_id::String
    cost::Float64
    routes::Vector{Route}
    unassigned_pickup_ids::Vector{String}
    unassigned_delivery_ids::Vector{String}
    unassigned_shipment_ids::Vector{String}
end
