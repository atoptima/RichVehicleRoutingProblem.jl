abstract type AbstractNode end

struct ProblemType
    fleet_size::String # INFINITE or FINITE
    fleet_composition::String # HOMOGENEOUS or HETEROGENEOUS
end

struct Coord
    x::Float64
    y::Float64
end

struct Location # define: index + distance matrix or Coord
    id::String # optional
    index::int
    coord::Coord # optional
end

struct TimeWindow
    tw_start::Float64
    tw_end::Float64
end

struct ResourcePrices
    names::Vector{String} # fixed_cost_coef, travel_dist_coef,  travel_time_coef, service_time_coef,  waiting_time_coef
    coef::Vector{Float64}
end

struct ResourceConsumptions
    names::Vector{String} #  travel_dist_conso,  travel_time_conso, service_time_conso,  waiting_time_conso, vehicle_type_id
    conso::Vector{Float64}
end

struct Depot <: AbstractNode
    location::Location
    time_windows::Vector{TimeWindow} # optional
end

struct Operation <: AbstractNode
    location::Location
    conso::ResourceConsumptions
    time_windows::Vector{TimeWindow} # optional
    req_index::Int
    operation_type::String # Pickup, Delivery, Shipment, Cleaning, ...
end

struct Request
    id::String
    index::Int
    operations::Vector{Operation} # Sequence of operations ; can be limited to one; can be a pair of Pickup and Delivery, or a triplets including a cleaning first, etc
end

struct VehicleBaseType
    prices::ResourcePrices
    capacity::ResourceConsumptions
end

struct VehicleType
    id::String
    index::Int
    depot::Depot # optional
    base_type::VehicleType
    time_schedule::TimeWindow
    return_to_depot::Bool
    infinite_copies::Bool
    init_load::ResourceConsumptions
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicles::Vector{VehicleType}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}
    # Requests
    pickups::Vector{Request}
    deliveries::Vector{Request}
    operations::Vector{Request}
    shipments::Vector{Request}
    picked_shipments::Vector{Request}
end
