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
    travel_distance_price::Float
    travel_time_price::Float
    service_time_price::Float
    wait_time_price::Float
end

struct Depot
    location::Location
    time_windows::Vector{TimeWindow} # optional
end

struct Pickup
    id::String
    index::Int # if its the pickup of a shipment, the index of the shipment
    location::Location
    capacity_demand::Float64
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

struct Delivery
    id::String
    index::Int # if its the pickup of a shipment, the index of the shipment
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
    max_duration::Float64
end

struct VehicleCategory
    id::String
    index::Int
    fixed_cost::Float64
    unit_pricing::UnitPricing
    capacity::Float64
end

struct HomogeneousVechicleSet # vehicle type in optimization instance.
    id::String
    index::Int
    departure_depot_index::Int # If -1 mentionned vehicle start from first action
    arrival_depot_indices::Vector{Int}
    vehicle_category::VehicleCategory
    working_time_window::TimeWindow
    min_nb_of_vehicles::Int
    max_nb_of_vehicles::Int
    intial_load::Float64
    max_travel_time::Float64
    max_travel_distance::Float64
end

struct RvrpProblem
    problem_id::String
    problem_type::ProblemType
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVechicleSet}
    travel_distance_matrix::Array{Float64,2}
    travel_time_matrix::Array{Float64,2}
    depots::Vector{Depot}
    # Requests
    pickups::Vector{Pickup}
    deliveries::Vector{Delivery}
    shipments::Vector{Shipment}
end
