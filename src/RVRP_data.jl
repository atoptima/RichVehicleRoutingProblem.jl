abstract type AbstractNode end
@enum RESOURCE Time TravelTime WaitingTime Distance TravelDistance Capacity
@enum OPERATION Pickup Delivery Shipment Cleaning
@enum REQUEST SingleOperation Shipment

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
    resource_consumptions::Dict{RESOURCE,Float64}
    time_windows::Vector{TimeWindow} # optional
    req_index::Int
    operation_type::OPERATION # Pickup, Delivery, Cleaning, ...
end

struct SimpleRequest
    id::String
    index::Int
    operation::Operation # Single Requests have only one operation
    request_type::REQUEST # SingleOperation, Shipment, ...
end

struct ComplexRequest
    id::String
    index::Int
    operations::Vector{Operation} # Sequence of operations ; can be limited to one; can be a pair of Pickup and Delivery, or a triplets including a cleaning first, etc
    request_type::REQUEST # SingleOperation, Shipment, ...
end

struct VehicleType
    fixed_cost::Float64
    resource_unit_prices::Dict{RESOURCE,Float64}
    resource_capacities::Dict{RESOURCE,Float64}
end

struct InstanceVehicleType # vehicle type in optimization instance.
    id::String
    index::Int
    depot::Depot # optional
    base_type::VehicleType
    time_schedule::TimeWindow
    return_to_depot::Bool
    infinite_copies::Bool
    nb_of_copies::Int
    resource_intial_states::Dict{RESOURCE,Float64}
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    resources::Vector{RESOURCE}
    vehicles::Vector{VehicleType}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}

    # Requests
    # Requests with only one operation of type Pickup:
    pickups::Vector{SimpleRequest}

    # Requests with only one operation of type Delivery:
    deliveries::Vector{SimpleRequest}

    # Requests with two operatios: first a Pickup, then a Delivery
    # with precedence between them, preemption is allowed:
    shipments::Vector{ComplexRequest}
end
