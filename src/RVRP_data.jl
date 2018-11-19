struct Range
    hard_min::Float64
    soft_min::Float64 # must be greater or equal to the hard_opening; can be undefined
    soft_max::Float64 # must be greater or equal to the soft_opening; can be undefined
    hard_max::Float64 # must be greater or equal to the soft_closing
    flat_unit_price::Float64 # can be a cost or a reward
    shortage_extra_unit_price::Float64 # to measure the cost/reward of being below this range's soft_opening
    excess_extra_unit_price::Float64 # to measure the cost/reward of being above this range's soft_closing
end

mutable struct Location # Location where can be a Depot, Pickup, Delivery, Recharging, ..., or a combination of those services
    id::String
    index::Int # used for matrices such as travel distance, travel time ...
    x_coord::Float64
    y_coord::Float64
    opening_time_windows::Vector{Range}
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
    pickup_availabitilies_at_location_ids::Dict{String,Float64} # defined only if pickup locations have a restricted capacity; provides capcity for each pickup location where the product is avaiblable in restricted capacity
    delivery_capacities_at_location_ids::Dict{String,Float64}  # defined only if delivery locations have a restricted capacity; provides capcity for each delivery location where the product can be delivered in restricted capacity
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
    precedence_status::Int # default = 0 = product predecessor restrictions;  1 = after all pickups, 2 =  after all deliveries.
    semi_mantadory::Bool # false (default, controlled by quantity range), true (= semi_mandatory) (must be covered if a feasible solution exists)
    product_quantity_range::Range # of the request
    shipment_capacity_consumption::Vector{Float64} # can include several independant capacity consumptions: as weight, value, volume
    shipment_property_requirements::Dict{Int,Float64} # to check if the vehicle has the property of accomodating the request: yes if request requirement <= vehicle property capacity for each index referenced requirement
    pickup_location_group_id::String # empty string for delivery-only requests. LocationGroup representing alternatives for pickup, otherwise.
    pickup_location_id::String # empty string for delivery-only requests. To be used instead of the above if there is a single pickup location
    delivery_location_group_id::String # empty string for pickup-only requests. LocationGroup representing alternatives for delivery, otherwise.
    delivery_location_id::String # empty string for pickup-only requests. To be used instead of the above if there is a single delivery location
    pickup_service_time::Float64 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # to enforce a maximum duration between pickup and delivery
    duration_unit_cost::Float64 # to measure the cost of the time spent between pickup and delivery
    pickup_time_windows::Vector{Range}
    delivery_time_windows::Vector{Range}
end

mutable struct VehicleCategory
    id::String
    compartment_capacities::Array{Float64,2} # matrix providing capacites for each compartment the additive measures: weight, value, volume
    vehicle_properties::Dict{Int,Float64} # defined only for index key associated with properties that need to be checked on the vehicle (such as the same check applies to all the compartments), as for instance to ability to cary liquids or  refrigerated product.
    compartments_properties::Dict{Int,Vector{Float64}} # defined only for index key associated with properties that need to be check on the comparments such as  max weight, max length, refrigerated product, .... For each such property, the Tuples specify a vector specifies the capacity for each compartment.
    energy_interval_lengths::Vector{Float64} # at index i, the length of the i-th energy interval. empty if no recharging.
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    vehicle_category_id::String
    departure_location_group_id::String # Vehicle routes start from one of the depot locations in the group
    departure_location_id::String # To be used instead of the above if the vehicle routes must start from a single depot location
    arrival_location_group_id::String # Vehicle routes end at one of the depot locations in the group
    arrival_location_id::String # To be used instead of the above if the vehicle routes must end at a single depot location
    working_time_window::Range
    travel_distance_unit_cost::Float64 # may depend on both driver and vehicle
    travel_time_unit_cost::Float64 # may depend on both driver and vehicle
    service_time_unit_cost::Float64
    waiting_time_unit_cost::Float64
    initial_energy_charge::Float64
    nb_of_vehicles_range::Range
    max_working_time::Float64
    max_travel_distance::Float64
    allow_ongoing::Bool # true if these vehicles routes are open, and the vehicles do not need to complete all their requests by the end of the planning
end

mutable struct RvrpInstance
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

################ Default-valued constructors #################
function Range(
    ; hard_min = 0.0, soft_min = 0.0, soft_max = typemax(Int32),
    hard_max = typemax(Int32), flat_unit_price = 0.0,
    shortage_extra_unit_price = 0.0, excess_extra_unit_price = 0.0)
    return Range(hard_min, soft_min, soft_max, hard_max, flat_unit_price,
                 shortage_extra_unit_price, excess_extra_unit_price)
end
simple_range(v::Real) = Range(v, v, v, v, 0.0, 0.0, 0.0)

function Location(
    ;id = "", index = -1, x_coord = -1.0, y_coord = -1.0,
    opening_time_windows = [Range()], access_time = 0.0,
    energy_fixed_cost = 0.0, energy_unit_cost = 0.0,
    energy_recharging_speeds = Float64[])
    return Location(
        id, index, x_coord, y_coord, opening_time_windows, access_time,
        energy_fixed_cost, energy_unit_cost, energy_recharging_speeds
    )
end

function LocationGroup(; id = "", location_ids = String[])
    return LocationGroup(id, location_ids)
end

function ProductCategory(; id = "", conflicting_product_ids = String[],
                         prohibited_predecessor_product_ids = String[])
    return ProductCategory(id, conflicting_product_ids,
                           prohibited_predecessor_product_ids)
end

function SpecificProduct(
    ; id = "", product_category_id = "",
    pickup_availabitilies_at_location_ids = Dict{String,Float64}(),
    delivery_capacities_at_location_ids = Dict{String,Float64}())
    return SpecificProduct(id, product_category_id,
                           pickup_availabitilies_at_location_ids,
                           delivery_capacities_at_location_ids)
end

function Request(
    ; id = "", specific_product_id = "",
    split_fulfillment = false, precedence_status = 0,
    semi_mantadory = false, product_quantity_range = Range(),
    shipment_capacity_consumption = Float64[],
    shipment_property_requirements = Dict{Int,Float64}(),
    pickup_location_group_id = "", pickup_location_id = "",
    delivery_location_group_id = "", delivery_location_id = "",
    pickup_service_time = 0.0, delivery_service_time = 0.0,
    max_duration = typemax(Int32), duration_unit_cost = 0.0,
    pickup_time_windows = [Range()], delivery_time_windows = [Range()])
    return Request(
        id, specific_product_id, split_fulfillment, precedence_status,
        semi_mantadory, product_quantity_range, shipment_capacity_consumption,
        shipment_property_requirements, pickup_location_group_id,
        pickup_location_id, delivery_location_group_id, delivery_location_id,
        pickup_service_time, delivery_service_time, max_duration,
        duration_unit_cost, pickup_time_windows, delivery_time_windows
    )
end

function VehicleCategory(
    ; id = "", compartment_capacities = Array{Float64,2}(undef, 0, 0),
    vehicle_properties = Dict{Int,Float64}(),
    compartments_properties = Dict{Int,Vector{Float64}}(),
    energy_interval_lengths = Float64[], loading_option = 0)
    return VehicleCategory(
        id, compartment_capacities, vehicle_properties, compartments_properties,
        energy_interval_lengths, loading_option
    )
end

function HomogeneousVehicleSet(
    ; id = "", vehicle_category_id = "", departure_location_group_id = "",
    departure_location_id = "", arrival_location_group_id = "",
    arrival_location_id = "", working_time_window = Range(),
    travel_distance_unit_cost = 0.0, travel_time_unit_cost = 0.0,
    service_time_unit_cost = 0.0, waiting_time_unit_cost = 0.0,
    initial_energy_charge = typemax(Int32), nb_of_vehicles_range = Range(),
    max_working_time = typemax(Int32), max_travel_distance = typemax(Int32),
    allow_ongoing = false)
    return HomogeneousVehicleSet(
        id, vehicle_category_id, departure_location_group_id,
        departure_location_id, arrival_location_group_id,
        arrival_location_id, working_time_window, travel_distance_unit_cost,
        travel_time_unit_cost, service_time_unit_cost, waiting_time_unit_cost,
        initial_energy_charge, nb_of_vehicles_range, max_working_time,
        max_travel_distance, allow_ongoing
    )
end

function RvrpInstance(
    ; id = "", travel_distance_matrix = Array{Float64,2}(undef,0,0),
    travel_time_matrix = Array{Float64,2}(undef,0,0),
    energy_consumption_matrix = Array{Float64,2}(undef,0,0),
    locations = Location[], location_groups = LocationGroup[],
    product_categories = ProductCategory[],
    specific_products = SpecificProduct[], requests = Request[],
    vehicle_categories = VehicleCategory[],
    vehicle_sets = HomogeneousVehicleSet[])
    return RvrpInstance(
        id, travel_distance_matrix, travel_time_matrix,
        energy_consumption_matrix, locations, location_groups,
        product_categories, specific_products, requests, vehicle_categories,
        vehicle_sets
    )
end
