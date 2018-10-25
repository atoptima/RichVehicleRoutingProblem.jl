struct Action
    start_time::Float64
    end_time::Float64
    location::Location
    node_type::Int # 0 - Depot, 1 - Pickup, 2 - Delivery, 3 - Operation
end

struct Route
    vehicle::Vehicle
    start_time::Float64
    end_time::Float64
    route::Vector{Action}
end

struct RvrpSolution
    solution_id::String
    problem_id::String
    cost::Float64
    routes::Vector{Route}
    unassigned_ids::Vector{String}
    # OSRM segments
end