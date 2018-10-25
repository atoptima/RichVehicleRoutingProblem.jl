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

struct Depot <: AbstractNode
    location::Location
    time_windows::Vector{TimeWindow} # optional
end

struct Operation <: AbstractNode
    location::Location
    resource_consumptions::Vector{Float64}
    time_windows::Vector{TimeWindow} # optional
    req_index::Int
    operation_type::String # Pickup, Delivery, Shipment, Cleaning, ...
end

struct SimpleRequest
    id::String
    index::Int
    operation::Operation # Single Requests have only one operation
end

struct ComplexRequest
    id::String
    index::Int
    operations::Vector{Operation} # Sequence of operations ; can be limited to one; can be a pair of Pickup and Delivery, or a triplets including a cleaning first, etc
end

struct VehicleBaseType
    fixed_cost::Float64
    resource_unit_prices::Vector{Float64}
    resource_capacities::Vector{Float64}
end

struct VehicleType
    id::String
    index::Int
    depot::Depot # optional
    base_type::VehicleType
    time_schedule::TimeWindow
    return_to_depot::Bool
    infinite_copies::Bool
    resource_intial_states::Vector{Float64}
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    resource_names::Vector{String}
    vehicles::Vector{VehicleType}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}
    # Requests
    simple_requests::Vector{SimpleRequest}
    complex_requests::Vector{ComplexRequest}
end
