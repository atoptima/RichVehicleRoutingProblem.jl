struct TimeWindow
    begin_time::Float64
    end_time::Float64
end

mutable struct OperationPoint # can be a Depot, Pickup, Delivery, Recharging, ..., or a combination of those
    id::String
    index::Int # used for matrices such as travel distance, travel time ...
    x_coord::Float64
    y_coord::Float64
    opening_time_windows::Vector{TimeWindow}
    access_time::Float64
    energy_fixed_cost::Float64 # for entry fee, if any
    energy_unit_cost::Float64 # for recharging cost per unit of energy, if any<<<<<<< HEAD
    energy_recharging_speeds::Vector{Float64} # at index i, the i-th energy interval recharging speed (energy_units per time_unit). Empty if no recharing in this point.
end

mutable struct OperationGroup # to identify a set of operation points with some commonalities, such as all possible Pickup Points for a product.
    id::String
    operation_point_ids::Vector{String}
end

mutable struct ProductCategory
    id::String
    conflicting_product_ids::Vector{String} # if any
    prohibited_predecessor_product_ids::Vector{String} # if any
end

mutable struct SpecificProduct
    id::String
    product_category_id::String
    pickup_availabitilies_at_point_or_group_ids::Dict{String,Float64} # pickup capacity at OperationPoints; Dict undefined if no restriction, i.e, if available in large quantities at any point.
    delivery_capacities_at_point_or_group_ids::Dict{String,Float64} # delivery capacity atOperationPoints; Dict undefined if no restriction, i.e, if can deliver to any point in large quantities
end

mutable struct Request # can be
    # a specific product shipment from a depot to a DeliveryPoint, or
    # a specific product shipment from a PickupPoint to a depot, or
    # a specific product delivery-only to one of several DeliveryPoints. Pickup is handled by another request(s).
    # a specific product pickup-only from one of several PickupPoints. Delivery is handled by another request(s).
    # a specific product shipment from a specific PickupPoint to a specific DeliveryPoint, or
    # a specific product shipment from one of several PickupPoints to a specific DeliveryPoint, or
    # a specific product shipment from a specific PickupPoints to one of several DeliveryPoints, or
    # a specific product shipment from one of several PickupPoints to one of several DeliveryPoints.
    id::String
    specific_product_id::String
    is_optional::Bool  # default is false
    price_reward::Float64 # if is_optional
    product_quantity::Float64 # of the request
    compartment_capacity_consumption::Float64 # portion of the vehicle compartment capacity used by the request (it can be equal to the quantity, or different even in terms of unit: volume versus weight for instance).
    split_fulfillment::Bool  # true if split delivery/pickup is allowed, default is false
    precedence_restriction::Int # default is 0 = only predecessor restrictions; 1 after all pickups, 2 after all deliveries.
    pickup_point_or_group_id::String # empty string for delivery-only requests. id of the OperationPoint or id of an OperationGroup representing alternatives for pickup
    delivery_point_or_group_id::String # empty string for pickup-only requests. id of the OperationPoint or id of a OperationGroup representing alternatives for delivery
    pickup_service_time::Float64 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # used for the dial-a-ride model or similar applications
end

mutable struct VehicleCategory
    id::String
    fixed_cost::Float64
    travel_distance_unit_price::Float64
    travel_time_unit_price::Float64
    service_time_unit_price::Float64
    waiting_time_unit_price::Float64
    compartment_capacities::Vector{Float64} # the stantard case is to have a single compartment
    energy_interval_lengths::Vector{Float64} # at index i, the length of the i-th energy interval. empty if no recharging.
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    prohibited_product_category_ids::Vector{String}  # if any
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    vehicle_category_id::String
    departure_point_or_group_id::String # []: Vehicle starts directly from first action of first request
    arrival_point_or_group_id::String # []: Open routes (vehicles not required to return to depots)
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
    operation_points::Vector{OperationPoint}
    operation_groups::Vector{OperationGroup}
    product_categories::Vector{ProductCategory}
    specific_products::Vector{SpecificProduct}
    requests::Vector{Request}
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
end
