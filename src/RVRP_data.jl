struct Range
    hard_min::Float64
    soft_min::Float64 # must be greater or equal to the hard_opening; can be undefined
    soft_max::Float64 # must be greater or equal to the soft_opening; can be undefined
    hard_max::Float64 # must be greater or equal to the soft_closing
    nominal_unit_price::Float64 # to measure the cost/reward per unit 
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
    vehicle_capacity_consumption::Dict{String,Tuple{Float64,Float64}} # to quantify the vehicle capacity that is used for accomodating  lot-sizes of the request along several independant capacity measures whose string id key are in the dictionary: as weight, value, volume; for each such key, the capacity used is the float coef 2 * roundup(quantity /  shipment_lot_size = float coef 1)
    vehicle_property_requirements::Dict{String,Float64} # to check if the vehicle has the property of accomodating the request: yes if request requirement <= vehicle property capacity for each string id referenced requirement
end

struct FlexibleConstraint
    flexibility_status::Bool # true means optional constraint (i.e. to be statisfied only of it does not increase the solution cost; false means that the constraint is (semi-)mandatory
    hierarchical_level::Int # for semi-mandatory constraints, level zero are mandatory, level k are constraints that can unsatisfyied if there was no feasbile solutions to the constraints of level 0 to k-1 that satisfy the set of cosntraint of level k.
    violation_fixed_price::Float64 #if status is false to measure a fixed cost/reward of not satisfying the constraint 
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
    request_flexibility::FlexibleConstraint # true is optional, false for (semi-)mandatory
    precedence_status::Int # default = 0 = product predecessor restrictions;  1 = after all pickups, 2 =  after all deliveries.
    product_quantity_range::Range # of the request
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
    vehicle_capacities::Dict{String,Float64} # defined only if measured at the vehicle level; for string id key associated with properties capacity measures that need to be checked on the vehicle, as for instance weight, value, volume
    compartment_capacities::Dict{String,Dict{String,Float64}} # defined only if measured at the compartment level; for string id key associated with properties capacity measures that need to be checked on the vehicle, as for instance weight, value, volume, ... For each such property, the Dictionary specifies the capacity for each compartment id key. 
    vehicle_properties::Dict{String,Float64} # defined only if measured at the vehicle level; for string id key associated with properties that need to be checked on the vehicle (such as the same check applies to all the compartments), as for instance to ability to cary liquids or  refrigerated product.
    compartments_properties::Dict{String,Dict{String,Float64}} #  defined only if measured at the compartment level; for string id key associated with properties that need to be check on the comparments such as  max weight, max length, refrigerated product, .... For each such property, the Dictionary specifies the capacity for each compartment id key. 
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
    max_nb_of_vehicles_flexibility::FlexibleConstraint
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
