abstract type AbstractNode end
@enum RESOURCE Time TravelTime WaitingTime Distance TravelDistance Capacity
@enum OPERATIONTYPE Pickup Delivery Shipment Cleaning
@enum REQUESTTYPE SingleOperation Shipment
const ResourceValues = Dict{RESOURCE,Float64}


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
    consumption::ResourceValues
    time_windows::Vector{TimeWindow} # optional
    req_index::Int
    operation_type::OPERATIONTYPE # Pickup, Delivery, Cleaning, ...
end

struct Request
    id::String
    index::Int
    operations::Vector{Operation} # Sequence of operations ; can be limited to one; can be a pair of Pickup and Delivery, or a triplets including a cleaning first, etc
    request_type::REQUESTTYPE # SingleOperation, Shipment, ...
end

struct VehicleType
    id::String
    index::Int
    depot::Depot # optional
    prices::ResourceValues
    capacity::ResourceValues
    time_schedule::TimeWindow
    return_to_depot::Bool
    initial_state::ResourceValues
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicle_types::Vector{VehicleType}
    nb_vehicles::Dict{VehicleType,Int}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}

    # Requests
    # Requests with only one operation of type Pickup:
    pickups::Vector{Request}

    # Requests with only one operation of type Delivery:
    deliveries::Vector{Request}

    # Requests with arbitrary number of operations of any OPERATIONTYPE
    # that must be done in the given sequence, by the same vehicle and
    # preemption (between operations) is not allowed:
    operations::Vector{Request}

    # Requests with two operatios: first a Pickup, then a Delivery
    # with precedence between them, preemption is allowed:
    shipments::Vector{Request}

    # Requests that are ongoing, where the Int part represents the
    # number of finished operations in the given request:
    ongoing_operations::Vector{Pair{Request,Int}}
end
