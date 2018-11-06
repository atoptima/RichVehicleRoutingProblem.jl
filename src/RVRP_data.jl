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

struct UnitPrices # cost per unit
    travel_distance_price::Float64
    travel_time_price::Float64
    service_time_price::Float64
    waiting_time_price::Float64
end

mutable struct Depot
    id::String
    index::Int # Not given in JSON
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
end

mutable struct PickupPoint
    id::String # If its part of a shipment, it has is own id anyway
    index::Int # Not given in JSON. 
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional; to measure access time for instance
end


mutable struct DeliveryPoint
    id::String # If it is part of a shipment,it has is own id anyway
    index::Int # Not given in JSON. 
    location::Location
    opening_time_windows::Vector{TimeWindow} # optional
    service_time::Float64 # optional; to measure access time for instance
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
    pickup_availabitilies::Dict{String,Float64} # undefined if no restrictions, i.e, if available in any PickupPoint in large quantities
    delivery_capacities::Dict{String,Float64} # undefined if no restrictions, i.e, if one can deliver to any DeliveryPoint in large quantities
end

mutable struct ShipmentRequest
    id::String
    index::Int # Not given in JSON
    request_type::Int # 1 = pickup, 2 = delivery, 3 = pickup&delivery, 4 = complex_request
    specific_product_id::String  
    is_optional::Bool  # default is false
    price_reward::Float64 # if is_optional
    quantity::Float64 # of the shipment/pickup/delivery
    load_capacity_conso::Float64 # portion of the vehicle load capacity used by the request (can be equal to the quantity)
    split_fulfillment::Bool  # default is false
    precedence_restriction::Int # default is 0 = no restriction; 1 after all pure pickups, 2 after all pure deliveries, 3 if cannot follow a product that is in the prohibited predecessor list
    alternative_pickup_point_ids::Vector{String} # defined only if it is a subset of SpecificProduct pickup sources; it is a singleton for request_type = pickup or pickup&delivery
    alternative_delivery_point_ids::Vector{String} # defined only if it is a subset of SpecificProduct delivery destinations; it is a singleton for request_type = delivery or pickup&delivery
    setup_service_time::Float64 # optional; on top of PickupPoint service_time; used to measure pre-cleaning or loading time for instance
    setdown_service_time::Float64 # optional; on top of DeliveryPoint service_time; used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # used for the dail-a-ride model or similar applications
end

mutable struct VehicleCategory
    id::String
    index::Int # Not given in JSON
    fixed_cost::Float64
    unit_pricing::UnitPricing
    compartment_capacities::Vector{Float64} # the santard case is to have a single compartment
    loading_option::Int # 0 = no restrictions, 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    prohibited_productCategory_ids::Vector{String}  # if any
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
    max_working_time::Float64
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
    pickup_points::Vector{PickupPoints}
    delivery_points::Vector{DeliveryPoints}
    products::Vector{Product}
    commodities::Vector{Commodity}
    requests::Vector{ShipmentRequest}
end

mutable struct RvrpComputedData
    instance_id::String
    pickupId2Index::Dict{String, Int}
    deliveryId2Index::Dict{String, Int}
    shipmentId2Index::Dict{String, Int}
end

