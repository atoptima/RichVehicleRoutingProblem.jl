struct TimeWindow
    opening_date::Float64
    soft_closing_date::Float64 # must be greater or equal to the opening_date
    hard_closing_date::Float64 # must be greater or equal to the soft_closing_date
end

mutable struct Location # Location where can be a Depot, Pickup, Delivery, Recharging, ..., or a combination of those services
    id::String
    index::Int # used for matrices such as travel distance, travel time ...
    x_coord::Float64
    y_coord::Float64
    opening_time_windows::Vector{TimeWindow}
    access_time::Float64
    energy_fixed_cost::Float64 # an entry fee, if any
    energy_unit_cost::Float64 # recharging cost per unit of energy, if any
    energy_recharging_speeds::Vector{Float64} # if recharging in this location: the i-th speep is associted to the i-th energy interval defined for the vehicle
end

mutable struct LocationGroup # optionally defined to identify a set of locations with some commonalities, such as all possible pickups for a request.
    id::String
    location_ids::Vector{String}
end

mutable struct ProductCategory
    id::String
    conflicting_product_ids::Vector{String} # if any
    prohibited_predecessor_product_ids::Vector{String} # if any
end

mutable struct SpecificProduct
    id::String
    product_category_id::String
    pickup_availabitilies_at_location_or_group_ids::Dict{String,Float64} # defined only if pickup locations have a restricted capacity
    delivery_capacities_at_location_or_group_ids::Dict{String,Float64}  # defined only if delivery locations have a restricted capacity
end

mutable struct Request # can be
    # a shipment from a depot to a delivery location, or
    # a shipment from a pickup location to a depot, or
    # a delivery of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a pickup of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a shipment from a given pickup location to a given delivery location of a product that is specific to the request, or
    # a shipment from a given pickup location to any location of a group delivery locations of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to a given delivery location of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to any location of a group delivery locations of a product that is specific to the request.
    id::String
    specific_product_id::String
    split_fulfillment::Bool  # true if split delivery/pickup is allowed, default is false
    precedence_status::Int # default = 0 = no restiction, 1 = product predecessor restrictions; 2= after all pickups,3=  after all deliveries.
    mantadory_status::Int # default = 0 = mandatory, 1= semi_mandatory (must be covered if a feasible solution exists), 2 = optional
    price_reward::Float64 # define if semi_mandatory or optional; reward for fulfilling the request
    product_quantity::Float64 # of the request
    shipment_capacity_consumption::Vector{Float64} # can include several independant capacity consumptions: as weight, value, volume
    incompatible_vehicles::Vector{{String,Int}} # list of Vehicle Category,  index of compartment
    pickup_location_or_group_ids::Vector{String}  # empty string for delivery-only requests. id of the Locations or of LocationGroups representing alternatives for pickup
    delivery_locations_or_group_ids::Vector{String}  # empty string for pickup-only requests. id of the Locations or of LocationGroups representing alternatives for delivery
    pickup_service_time::Float64 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # to enforce a maximum duration between pickup and delivery
    duration_unit_price::Float64 # to measure the cost of the time spent between pickup and delivery
    lateness_unit_price::Float64 # to measure the cost of going beyond the soft_closing_dates
end

mutable struct VehicleCategory
    id::String
    travel_distance_unit_price::Float64
    travel_time_unit_price::Float64
    service_time_unit_price::Float64
    waiting_time_unit_price::Float64
    compartment_capacities::Array{Float64,2} # matrix providing capacites for each compartment the additive measure: weight, value, volume
    energy_interval_lengths::Vector{Float64} # at index i, the length of the i-th energy interval. empty if no recharging.
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    vehicle_category_id::String
    departure_location_or_group_ids::Vector{String} # Vehicle routes start from depot locations
    arrival_location_or_group_ids::Vector{String} # Vehicle routes end at depot locations
    working_time_window::TimeWindow
    lateness_unit_price::Float64 # to measure the cost of going beyond the soft_closing_date
    initial_energy_charge::Float64
    min_nb_of_vehicles::Int
    soft_max_nb_of_vehicles::Int
    hard_max_nb_of_vehicles::Int # must be greater or equal to soft_max_nb_of_vehicles
    fixed_cost_below_soft_max_nb::Float64
    fixed_cost_above_soft_max_nb::Float64
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
    location_groups::Vector{LocationGroup} # if any
    product_categories::Vector{ProductCategory}
    specific_products::Vector{SpecificProduct}
    requests::Vector{Request}
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
end
