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
    nb_of_copies::Int
    resource_intial_states::Vector{Float64}
    ongoing_requests::Vector{Pair{Request,Int}}
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicles::Vector{VehicleType}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}

    # Requests
    # Requests with only one operation of type Pickup:
    pickups::Vector{SimpleRequest}

    # Requests with only one operation of type Delivery:
    deliveries::Vector{SimpleRequest}

    # Requests with arbitrary number of operations of any OPERATION
    # that must be done in the given sequence, by the same vehicle and
    # preemption (between operations) is not allowed:
    operations::Vector{ConplexRequest}

    # Requests with two operatios: first a Pickup, then a Delivery
    # with precedence between them, preemption is allowed:
    shipments::Vector{ComplexRequest}

    # Requests that are ongoing, where the Int part represents the
    # number of finished operations in the given request:
    ongoing_requests::Vector{Pair{Request,Int}}
end
