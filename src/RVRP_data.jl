struct Coord
    x::Float64
    y::Float64
end

mutable struct Location
    id::String
    index::Int # Not given in JSON
    coord::Coord # optional
end

struct TimeWindow
    begin_time::Float64
    end_time::Float64
end

mutable struct PickupPoint
    id::String # If its part of a shipment, it has is own id anyway
    index::Int # Not given in JSON. 
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct DeliveryPoint
    id::String # If it is part of a shipment,it has is own id anyway
    index::Int # Not given in JSON. 
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct DepotPoint # location to start or end a route; a depot can also act as a Pickup or a Delivery Point
    id::String
    index::Int # Not given in JSON
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct RechargingPoint
    id::String # If it is part of a shipment,it has is own id anyway
    index::Int # Not given in JSON. 
    location::Location
    reloading_rate::Float64 # fuel capacity that is brought within the vehicle reloading_time
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional 
end

mutable struct ProductCategory
    id::String 
    index::Int # Not given in JSON. 
    conflicting_product_ids::Vector{String} # if any
    prohibited_predecessor_product_ids::Vector{String}  # if any
end

mutable struct SpecificProduct # an entity to understand as a commodity in a multi-commodity flow problem
    id::String 
    index::Int # Not given in JSON. 
    product_category_id::String
    pickup_availabitilies_at_point_ids::Dict{String,Float64} # pickups can be either at a PickupPoint or a DepotPoint; Dict undefined if no restriction, i.e, if available in large quantities at any point.
    delivery_capacities_at_point_ids::Dict{String,Float64} # deliveries can be either at a DeliveryPoint or a DepotPoint; Dict undefined if no restriction, i.e, if can deliver to any point in large quantities
end

mutable struct Request # can be
    # a shipment from a depot to a DeliveryPoint, or
    # a shipment from a PickupPoint to a depot, or
    # a delivery to a DeliveryPoint of an indistinguishable product that was loaded at different PickupPoints, or
    # a pickup from a PickupPoint of an indistinguishable product that will be unloaded at different PickupPoints, or
    # a shipment for a specific PickupPoint to a  specific DeliveryPoint, or
    # a shipment from one of several PickupPoints to a specific DeliveryPoint, or
    # a shipment from a specific PickupPoints to one of several DeliveryPoints, or
    # a shipment from one of several PickupPoints to one of several DeliveryPoints.
    id::String
    index::Int # Not given in JSON
    product_id::String  
    is_optional::Bool  # default is false
    price_reward::Float64 # if is_optional
    product_quantity::Float64 # of the shipment
    load_capacity_conso::Float64 # portion of the vehicle load capacity used by the request (it can be equal to the quantity, or different even in terms of unit: volume versus weight for instance).
    split_fulfillment::Bool  # true if split delivery/pickup is allowed, default is false
    precedence_restriction::Int # default is 0 = no restriction; 1 after all pure pickups, 2 after all pure deliveries, 3 if cannot follow a product that is in the prohibited predecessor list; 
    alternative_pickup_point_ids::Vector{String} # defined only if it is a subset of SpecificProduct pickup options; empty otherwise
    alternative_delivery_point_ids::Vector{String} # defined only if it is a subset of SpecificProduct delivery options; empty otherwise
    pickup_service_time::Float64 # optional; on top of PickupPoint service_time; used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # optional; on top of DeliveryPoint service_time; used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # used for the dail-a-ride model or similar applications
end

struct UnitPrices # cost per unit
    travel_distance_price::Float64
    travel_time_price::Float64
    service_time_price::Float64
    waiting_time_price::Float64
end

mutable struct VehicleCategory
    id::String
    index::Int # Not given in JSON
    fixed_cost::Float64
    unit_pricing::UnitPrices
    compartment_capacities::Vector{Float64} # the santard case is to have a single compartment
    fuel_capacity::Float64
    reloading_time::Float64
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    prohibited_product_category_ids::Vector{String}  # if any
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
    initial_fuel_load::Float64
    min_nb_of_vehicles::Int
    max_nb_of_vehicles::Int
    max_working_time::Float64 
    max_travel_distance::Float64
    allow_ongoing::Bool # true if the vehicle does not need to complete all his deliveries by the end of the time horizon, as they can be completed on the next period.
end

struct RvrpInstance
    id::String
    travel_distance_matrix::Array{Float64,2}
    travel_time_matrix::Array{Float64,2}
    fuel_consumption_matrix::Array{Float64,2}
    pickup_points::Vector{PickupPoint}
    delivery_points::Vector{DeliveryPoint}
    depot_points::Vector{DepotPoint}
    recharging_points::Vector{RechargingPoint}
    product_categories::Vector{ProductCategory}
    products::Vector{SpecificProduct}
    requests::Vector{Request}
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
end

mutable struct RvrpComputedData
    instance_id::String
    pickup_id2Index::Dict{String, Int}
    delivery_id2Index::Dict{String, Int}
    depot_id2Index::Dict{String, Int}
    recharging_id2Index::Dict{String, Int}
    product_category_id2Index::Dict{String, Int}
    product_id2Index::Dict{String, Int}
    request_id2Index::Dict{String, Int}
    vehicle_category_id2Index::Dict{String, Int}
    vehicle_set_id2Index::Dict{String, Int}
end

