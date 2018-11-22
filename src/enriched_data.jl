struct FlexibleConstraint
    flexibility_status::Bool # true means optional constraint (i.e. to be statisfied only of it does not increase the solution cost; false means that the constraint is (semi-)mandatory
    hierarchical_level::Int # for semi-mandatory constraints, level zero are mandatory, level k are constraints that can unsatisfyied if there was no feasbile solutions to the constraints of level 0 to k-1 that satisfy the set of cosntraint of level k.
    fixed_price::Float64 #if status is false it measures a fixed cost of not satisfying the constraint, if statur is true, it measures the fixed reward for satisfying the ocnstraint.
end

mutable struct EnrichedDataForLocation # to complete struct Location
    id::String
    location_id::String
    zone_id::String 
    location_entry_time::Float64 # to add to time of any transition arriving in this location  from a different location
    location_exit_time::Float64 # to add to time of any transition leaving this location  to a different location
    zone_entry_time::Float64 # to add to time of any transition arriving in this location from a different zone
    zone_exit_time::Float64 # to add to time of any transition leaving this location to a different zone
    energy_fixed_cost::Float64 # an entry fee , if any
    energy_unit_cost::Float64 # recharging cost per unit of energy, if any
    energy_recharging_speeds::Vector{Float64} # if recharging in this location: the i-th speep is associted to the i-th energy interval defined for the vehicle
end


mutable struct EnrichedDataForRequest
    id::String
    request_id::String
    request_flexibility::FlexibleConstraint # true is optional, false for (semi-)mandatory
end


mutable struct ElectricVehicleCategory
    id::String
    energy_interval_lengths::Vector{Float64} # at index i, the length of the i-th energy interval. empty if no recharging.
end

mutable struct EnrichedDataForHomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    vehicle_set_id::String
    electric_vehicle_category_id::String
    max_nb_of_vehicles_flexibility::FlexibleConstraint # for each time period for which it is available (as specified in working_time_window)
    allow_ongoing::Bool # true if the vehicles do not need to complete all their requests by the end of each time period of the planning

end

struct EnrichedDataForInstance
    id::String
    instance_id::String
    energy_consumption_matrix::Array{Float64,2}
    time_periods::Vector{Range} # Define a single period of for time horizon or several; vehicles need must return to a depot by the end of each time period if they cannot be ongoing. Route's max_duration and max_distance apply to each time period
    data_for_locations::Vector{EnrichedDataForLocation}
    data_for_requests::Vector{EnrichedDataForRequest}
    electric_vehicle_categories::Vector{ElectricVehicleCategory}
    data_for_vehicle_sets::Vector{EnrichedDataForHomogeneousVehicleSet}
end
