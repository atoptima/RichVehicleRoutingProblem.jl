struct ProblemType
    fleet_size::String # INFINITE or FINITE
    fleet_composition::String # HOMOGENEOUS or HETEROGENEOUS
    request_cover::String # PRICECOLLECTING or MANDATORY
end

struct Coord
    x::Float64
    y::Float64
end

mutable struct Location # define: index + distance matrix or Coord
    id::String
    index::Int # Not given in JSON
    coord::Coord # optional
end

struct TimeWindow
    begin_time::Float64
    end_time::Float64
end

struct UnitPricing
    travel_distance_price::Float64
    travel_time_price::Float64
    service_time_price::Float64
    wait_time_price::Float64
end

mutable struct Depot
    id::String
    index::Int # Not given in JSON
    location::Location
    time_windows::Vector{TimeWindow} # optional
end

mutable struct Pickup
    id::String # If its part of a shipment, it has is own id anyway
    index::Int # Not given in JSON. If its part of a shipment, the index of the shipment
    location::Location
    shipment_id::String # NULL if none
    price_reward::Float64
    capacity_request::Float64
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

mutable struct Delivery
    id::String # If it is part of a shipment,it has is own id anyway
    index::Int # Not given in SON. if it is part of a shipment, the index of the shipment
    location::Location
    shipment_id::String # NULL if none
    price_reward::Float64
    capacity_request::Float64
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

mutable struct Shipment
    id::String
    index::Int # Not given in JSON
    price_reward::Float64
    pickup::Pickup
    delivery::Delivery
    max_duration::Float64
end

mutable struct VehicleCategory
    id::String
    index::Int # Not given in JSON
    fixed_cost::Float64
    unit_pricing::UnitPricing
    capacity::Float64
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    index::Int # Not given in JSON
    departure_depot_id::String # "": mentionned vehicle start from first action
    arrival_depot_ids::Vector{String}
    departure_depot_index::Int # -1: mentionned vehicle start from first action
    arrival_depot_indices::Vector{Int}
    vehicle_category::VehicleCategory
    working_time_window::TimeWindow
    min_nb_of_vehicles::Int
    max_nb_of_vehicles::Int
    max_travel_time::Float64
    max_travel_distance::Float64
end

struct RvrpInstance
    id::String
    problem_type::ProblemType
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
    travel_distance_matrix::Array{Float64,2}
    travel_time_matrix::Array{Float64,2}
    depots::Vector{Depot}
    # Requests
    pickups::Vector{Pickup}
    deliveries::Vector{Delivery}
    shipments::Vector{Shipment}
end


mutable struct RvrpComputedData
    instance_id::String
    pickupId2Index::Dict{String, Int}
    deliveryId2Index::Dict{String, Int}
    shipmentId2Index::Dict{String, Int}
end
