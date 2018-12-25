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
    latitude::Float64
    longitude::Float64
    opening_time_windows::Vector{Range}
    entry_time::Float64 
    exit_time::Float64
    entry_location_group_id::String # to model and extra time when entering/exiting the group
end

mutable struct LocationGroup # optionally defined to identify a set of locations with some commonalities, such as all possible pickups for a request, or joint entry/exit times.
    id::String
    location_ids::Vector{String}
    entry_time::Float64 
    exit_time::Float64
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
    vehicle_or_compartment_capacity_consumptions::Dict{String,Float64} # to quantify the vehicle/compartment capacity that is used for accomodating  lot-sizes of the request along several independant capacity measures whose string id key are in the dictionary: as weight, value, volume; 
    request_flexibility::FlexibleConstraint # true is optional, false for (semi-)mandatory
    product_quantity_range::Int # of the request
    pickup_location_id::String # empty string for delivery-only requests. To be used instead of the above if there is a single pickup location
    delivery_location_id::String # empty string for pickup-only requests. To be used instead of the above if there is a single delivery location
    pickup_service_time::Float64 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # used to measure post-cleaning or unloading time for instance
    pickup_time_windows::Vector{Range}
    delivery_time_windows::Vector{Range}
    delivery_time_flexibility::FlexibleConstraint # for semi-mandatory delivery time windows
end

mutable struct VehicleCategory
    id::String
    vehicle_capacities::Dict{String,Float64} # defined only if measured at the vehicle level; for string id key associated with properties capacity measures that need to be checked on the vehicle, as for instance weight, value, volume
end


mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    vehicle_category_id::String
    departure_location_group_id::String # Vehicle routes start from one of the depot locations in the group
    departure_location_id::String # To be used instead of the above if the vehicle routes must start from a single depot location
    arrival_location_group_id::String # Vehicle routes end at one of the depot locations in the group
    arrival_location_id::String # To be used instead of the above if the vehicle routes must end at a single depot location
    working_time_window::Range
    arrival_time_flexibility::FlexibleConstraint # for semi-mandatory  working_time_window hard_max
    travel_distance_unit_cost::Float64 # may depend on both driver and vehicle
    travel_time_unit_cost::Float64 # may depend on both driver and vehicle
    service_time_unit_cost::Float64
    waiting_time_unit_cost::Float64
    initial_energy_charge::Float64
    nb_of_vehicles_range::Range # also includes the fixed cost per vehicle  within each time period (in Range.nominal_unit_price)
    max_nb_of_vehicles_flexibility::FlexibleConstraint # for each time period for which it is available (as specified in working_time_window)
    max_working_time::Float64 # within each time period
    max_travel_distance::Float64 # within each time period
    allow_ongoing::Bool # true if the vehicles do not need to complete all their requests by the end of each time period of the planning
end


struct RvrpInstance
    id::String
    travel_time_matrix::Array{Float64,2}
    locations::Vector{Location}
    location_groups::Vector{LocationGroup} # if any
    requests::Vector{Request}
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
    time_periods::Vector{Range} # Define a single period of for time horizon or several; vehicles need must return to a depot by the end of each time period if they cannot be ongoing.
end
