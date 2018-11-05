struct ProblemType
#    fleet_size::String # INFINITE or FINITE (=default)
#    fleet_composition::String # HOMOGENEOUS or HETEROGENEOUS (=default)
    request_cover::String # PRICECOLLECTING or MANDATORY (=default) or MIXED
    shipment_model::String # SINGLECOMMODITY or MULTIPLECOMMODITY (=default);
    # When the requests are only of one type: either all are pickups or all are deliveries; the problem  is a single commodity.
    split_option::String # SPLITDELIVERY or MONODELIVERY (=default)
    backhaul_option::String # WITHBACKHAUL or MIXINGPICKUPSANDDELIVERIES (=default)
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
    waiting_time_price::Float64
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
    shipment_id::String # NULL if pure Pickup request
    product_id::String # optional : required only to implement conflicts
    conflicting_product_ids::Vector{String}  # optional : required only to implement conflicts
    price_reward::Float64  # optional : required only to implement the price collection variant
    quantity::Float64 # the available commodity quantity, or the requested quantity to pickup
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

mutable struct Delivery
    id::String # If it is part of a shipment,it has is own id anyway
    index::Int # Not given in SON. if it is part of a shipment, the index of the shipment
    location::Location
    shipment_id::String # NULL if pure Delivery request
    product_id::String  # optional : required only to implement conflicts
    conflicting_product_ids::Vector{String}  # optional : required only to implement conflicts
    price_reward::Float64 # optional : required only to implement the price collection variant
    quantity::Float64 # the requested commodity quantity, or the available capacity of the delivery point
    time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional
end

mutable struct Shipment
    id::String
    index::Int # Not given in JSON
    product_id::String  # optional : required only to implement conflicts
    conflicting_product_ids::Vector{String}  # optional : required only to implement conflicts
    price_reward::Float64 # for the PRICECOLLECTING variant
    pickups::Vector{Pickup} # more than on pickup point is possible, for a single delivery
    deliveries::Vector{Delivery} # more than on delivery point is possible, for a single pickup
    max_duration::Float64
end

mutable struct VehicleCategory
    id::String
    index::Int # Not given in JSON
    fixed_cost::Float64
    unit_pricing::UnitPricing
    compartment_capacities::Vector{Float64} # the santard case is to have a single compartment
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
    # Single-Commodity Requests
    pickups::Vector{Pickup}
    deliveries::Vector{Delivery}
    # Multi-Commodity Requests
    shipments::Vector{Shipment}
end


mutable struct RvrpComputedData
    instance_id::String
    pickupId2Index::Dict{String, Int}
    deliveryId2Index::Dict{String, Int}
    shipmentId2Index::Dict{String, Int}
end
