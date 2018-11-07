struct Coord
    x::Float64
    y::Float64
end

mutable struct Location
    id::String
    index::Int # Not given in the JSON input, but internally defined by the algorithm
    coord::Coord # optional
end

struct TimeWindow
    begin_time::Float64
    end_time::Float64
end

mutable struct PickupPoint
    id::String # If its part of a shipment, it has is own id anyway
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct DeliveryPoint
    id::String # If it is part of a shipment,it has is own id anyway
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct DepotPoint # location to start or end a route; a depot can also act as a Pickup or a Delivery Point
    id::String
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional
end

mutable struct RechargingPoint
    id::String # If it is part of a shipment,it has is own id anyway
    location::Location
    fixed_cost::Float64
    energy_unit_cost::Float64
    energy_recharging_rates::Vector{Float64} # to model a piecewise linear recharging curve, this vector defines recharging-time rate associated to primary, secondary, ... recharge intervals; the vehicle can start directly with the secondary interval if his remaining charge is above the primary interval threshold. To model a concave function (as expected for battery charge), the primary charging rate is higher  than the secondary rate, etc.
    opening_time_windows::Vector{TimeWindow} # optional
    access_time::Float64 # optional 
end

mutable struct ProductCategory
    id::String 
    conflicting_product_ids::Vector{String} # if any
    prohibited_predecessor_product_ids::Vector{String}  # if any
end

mutable struct SpecificProduct # an entity to understand as a commodity in a multi-commodity flow problem
    id::String 
    product_category_id::String
    pickup_availabitilies_at_point_ids::Dict{String,Float64} # pickups can be either at a PickupPoint or a DepotPoint; Dict undefined if no restriction, i.e, if available in large quantities at any point.
    delivery_capacities_at_point_ids::Dict{String,Float64} # deliveries can be either at a DeliveryPoint or a DepotPoint; Dict undefined if no restriction, i.e, if can deliver to any point in large quantities
end

mutable struct Request # can be
    # a specific product shipment from a depot to a DeliveryPoint, or
    # a specific product shipment from a PickupPoint to a depot, or
    # a delivery to a DeliveryPoint of a product that is not specific to this delivery and was loaded potentially from several different PickupPoints, or
    # a pickup from a PickupPoint of a product that is not specific to this pickup and will be unloaded potentially at several different DeliveryPoints, or
    # a specific product shipment from a specific PickupPoint to a specific DeliveryPoint, or
    # a specific product shipment from one of several PickupPoints to a specific DeliveryPoint, or
    # a specific product shipment from a specific PickupPoints to one of several DeliveryPoints, or
    # a specific product shipment from one of several PickupPoints to one of several DeliveryPoints.
    id::String
    product_id::String  
    is_optional::Bool  # default is false
    price_reward::Float64 # if is_optional
    product_quantity::Float64 # of the shipment
    compartment_capacity_consumption::Float64 # portion of the vehicle compartment capacity used by the request (it can be equal to the quantity, or different even in terms of unit: volume versus weight for instance).
    split_fulfillment::Bool  # true if split delivery/pickup is allowed, default is false
    precedence_restriction::Int # default is 0 = no restriction; 1 after all pickups, 2 after all deliveries, 3 if cannot follow a product that is in the prohibited predecessor list; 
    alternative_pickup_point_ids::Vector{String} # nonempty only if it defines the request; it is not supposed to duplicate the pickup options information contained in SpecificProduct
    alternative_delivery_point_ids::Vector{String} # nonempty only if it defines the request; it is not supposed to duplicate the delivery options information contained in SpecificProduct
    pickup_service_time::Float64 # optional; on top of PickupPoint service_time; used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # optional; on top of DeliveryPoint service_time; used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # used for the dail-a-ride model or similar applications
end

mutable struct VehicleCategory
    id::String
    fixed_cost::Float64
    travel_distance_unit_price::Float64
    travel_time_unit_price::Float64
    service_time_unit_price::Float64
    waiting_time_unit_price::Float64
    compartment_capacities::Vector{Float64} # the stantard case is to have a single compartment
    energy_recharge_intervals::Vector{Float64} # to model a piecewise linear recharging curve, this vector defines primary, secondary, ... recharge interval thresholds
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    prohibited_product_category_ids::Vector{String}  # if any
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    departure_depot_ids::Vector{String} # []: Mentionned vehicle starts from first action
    arrival_depot_ids::Vector{String} # []: Open routes
    vehicle_category::VehicleCategory
    working_time_window::TimeWindow
    initial_energy_charge::Float64
    min_nb_of_vehicles::Int
    max_nb_of_vehicles::Int
    max_working_time::Float64 
    max_travel_distance::Float64
    allow_ongoing::Bool # true if these vehicles routes are open, and the vehicles do not need to complete all their requests by the end of the planning
end

struct RvrpInstance
    id::String
    travel_distance_matrix::Array{Float64,2}
    travel_time_matrix::Array{Float64,2}
    energy_consumption_matrix::Array{Float64,2}
    locations::Vector{Location}
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

