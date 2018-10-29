# To use the solution, the input data is required

struct Action
    request_type::Int # 0 - Depot, 1 - Pickup, 2 - Delivery
    request_index::Int # index of the request in the associated vector depots pickups  deliveries or shipments
end

struct Route
    vehicle_set_index::Int
    sequence::Vector{Action}
    # TODO: add OSRM path here
    # path::Path
end

struct RvrpSolution
    solution_id::String
    problem_id::String
    cost::Float64
    routes::Vector{Route}
    unassigned_pickup_indices::Vector{Int}
    unassigned_delivery_indices::Vector{Int}
    unassigned_shipment_indices::Vector{Int}
end
