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
    index::Int # optional
    coord::Coord # optional
end

struct TimeWindow
    tw_start::Float64
    tw_end::Float64
end

struct UnitPricing
    distance_price::Float
    travel_time_price::Float
    service_time_price::Float
    wait_time_price::Float
end

struct Costs
    fixed::Float64
    distance::Float64
    time::Float64
    service::Float64
    wait::Float64
end

struct Depot
    location::Location
    time_windows::Vector{TimeWindow} # optional
end

struct Pickup
    id::String
    index::Int
    location::Location
    capacity_demand::Float64
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

struct Delivery
    id::String
    index::Int
    location::Location
    capacity_demand::Float64
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

struct Shipment
    id::String
    index::Int
    pickup::Pickup
    delivery::Delivery
end

struct VehicleType
    id::String
    index::Int
    fixed_cost::Float64
    unit_pricing::UnitPricing
    capacity::Float64
end

struct InstanceVehicleType # vehicle type in optimization instance.
    id::String
    index::Int
    depot::Depot # optional. If not mentionned vehicle start from first action
    vehicle_type::VehicleType
    time_schedule::TimeWindow
    return_to_depot::Bool
    nb_of_copies::Int
    intial_load::Float64
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicle_types::Vector{VehicleType}
    instance_vehicle_types::Vector{InstanceVehicleType}
    distance_matrix::Array{Float64,2}
    travel_times_matrix::Array{Float64,2}
    # Requests
    pickups::Vector{PickupRequest}
    deliveries::Vector{DeliveryRequest}
    shipments::Vector{Shipment}
end
