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
    coord::Coord # optional
    index::Int # optional
end

struct TimeWindow
    tw_start::Float64
    tw_end::Float64
end

struct Costs
    fixed::Float64
    distance::Float64
    time::Float64
    service::Float64
    wait::Float64
end

struct VehicleType
    id::String
    capacity::Int
    costs::Costs
end

struct Depot <: AbstractNode
    location::Location
    time_windows::Array{TimeWindow,1} # optional
end

struct Pickup <: AbstractNode
    location::Location
    capacity_demand::Float64
    time_windows::Array{TimeWindow,1} # optional
    duration::Float64 # optional      
    req_id::String
end

struct Delivery <: AbstractNode
    location::Location
    capacity_demand::Float64
    time_windows::Array{TimeWindow,1} # optional
    duration::Float64 # optional
    req_id::String
end

struct Operation <: AbstractNode
    start_location::Location
    end_location::Location
    required_capacity::Float64
    delta_capacity::Float64
    time_windows::Array{TimeWindow,1} # optional
    duration::Float64 # optional      
    req_id::String
end

abstract type AbstractRequest end

struct Service <: AbstractRequest
    id::String
    node::Union{Pickup, Delivery, Operation}
end    

struct Shipment <: AbstractRequest
    id::String
    pickup::Pickup
    delivery::Delivery
end

abstract type AbstractVehicle end

struct Vehicle <: AbstractVehicle
    id::String
    depot::Depot # optional
    v_type::VehicleType
    time_schedule::TimeWindow
    return_to_depot::Bool
    infinite_copies::Bool
    initial_load::Float64
    picked_shipments::Array{Shipment,1}
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicles::Array{Vehicle,1}
    vehicle_types::Array{VehicleType,1}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}

    services::Array{Service,1}
    shipments::Array{Shipment,1}
    picked_shipments::Array{Shipment,1}
end 
