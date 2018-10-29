struct Action
    request_index::Int # -1 if depot
    node_type::Int # 0 - Depot, 1 - Pickup, 2 - Delivery, 3 - Operation
    start_time::Float64
    end_time::Float64
end

struct Route
    vehicle_set_index::Int
    start_time::Float64
    end_time::Float64
    route::Vector{Action}
    # TODO: add OSRM path here
    # path::Path
end

struct RvrpSolution
    solution_id::String
    problem_id::String
    cost::Float64
    routes::Vector{Route}
    unassigned_pickup_indices::Vector{Pickup}
    unassigned_delivery_indices::Vector{Delivery}
    unassigned_shipment_indices::Vector{Shipment}
end
