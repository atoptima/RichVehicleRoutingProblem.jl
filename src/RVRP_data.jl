abstract type AbstractNode end

@enum RESOURCE FixedCost VariableCost ClockTime TravelTime WaitingTime RestTime TravelDistance Capacity
@enum OPERATION Pickup Delivery Cleaning Parcking Setup 
@enum REQUEST Pickup Delivery Shipment Cleaning Parcking Setup ComplexOperation

struct ResourceDict
    Dict{RESOURCE,Float64}
end

    
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

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    resource_types::Vector{RESOURCE}
    vehicle_base_types::Vector{VehicleBaseType}
    vehicles::Vector{VehicleType}
    distance_matrix::Array{Float64,2} # optional; indexed by Location index
    travel_times_matrix::Array{Float64,2} # optional; indexed by Location index
    requests::Vector{Request}  # Requests aggregated into a single container
    requestDict::Dict{REQUEST,Vector{Int}}  # Requests sorted by types pointing to position in the requets vector
end
