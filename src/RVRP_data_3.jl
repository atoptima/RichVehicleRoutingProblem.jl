abstract type AbstractNode end

@enum RESOURCE_TYPES FixedCost VariableCost ClockTime TravelTime WaitingTime RestTime TravelDistance Capacity
@enum OPERATION_TYPES Pickup Delivery Cleaning Parcking Setup 
@enum REQUEST_TYPES Pickup Delivery Shipment Cleaning Parcking Setup ComplexOperation

const ResourceDict = Dict{RESOURCE_TYPES,Float64}


    
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

struct Arc
    index::Int
    tail::AbstractNode
    head::AbstractNode
    resource_consumptions::ResourceDict
end

struct Depot <: AbstractNode
    location::Location
    time_windows::Vector{TimeWindow} # optional
    inArcIndices::Vector{Int}
    outArcIndices::Vector{Int}
end

struct Operation <: AbstractNode
    location::Location
    resource_consumptions::ResourceDict
    time_windows::Vector{TimeWindow} # optional
    req_index::Int
    operation_type::OPERATION # Pickup, Delivery, Cleaning, ...
    inArcIndices::Vector{Int}
    outArcIndices::Vector{Int}
end

struct Request
    id::String
    index::Int
    request_type::REQUEST # SingleOperation, Shipment, ...
    operations::Vector{Operation} # a request can be a sequence of operations: f.i can be a pair of Pickup and Delivery, or a triplets including 
end


struct VehicleBaseType
    resource_prices::ResourceDict
    resource_capacities::ResourceDict 
end

struct VehicleType # vehicle type in optimization instance.
    id::String
    index::Int
    depot::Depot # optional
    base_type::VehicleBaseType
    time_schedule::TimeWindow
    return_to_depot::Bool
    infinite_copies::Bool
    nb_of_copies::Int
    resource_intial_states::ResourceDict
end

struct Network
    nodes::Vector{AbstractNode}
    matrices::Dict{RESOURCE_TYPES, Array{Float64, 2}} # Use distance matrices for a dense network
    arcList::Vector{Arc} # Use arc vector for a sparce network
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    resource_types::Vector{RESOURCE_TYPES}
    network::Network
    vehicle_base_types::Vector{VehicleBaseType}
    vehicles::Vector{VehicleType}
    requests::Vector{Request}  # Requests aggregated into a single container
    requestDict::Dict{REQUEST_TYPES,Vector{Int}}  # Requests sorted by types pointing to positions in the request vector
end
