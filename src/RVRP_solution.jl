# To use the solution, the input data is required

mutable struct VehicleState
    is_empty::Bool
    capacity_usages::VehicleCharacteristics # if not empty 
    accumulated_cost::Float64 
    accumulated_time::Float64 # accounts for waiting time
    accumulated_distance::Float64 # Cannot compute (no distance matrix)
    accumulated_energy_cons::Float64
end

mutable struct Action
    id::String
    location_id::String
    request_id::String # if any request is linked to a request the operation
    operation_type::Int  # 0 - Arrival to Location, 1 - Departure from Location, 2 - Pickup, 3 - Delivery, 4 - Arrival to Zone, 5 - Departure from Zone 
    product_quantity::Float64 # to record the picked/delivered quantity in case of split_fulfillment
    state_on_completing_the_action::VehicleState
end


mutable struct Duty # sequence of actions that form a whole, i.e. each of these cannot be removed indenpendtly frol the other to be assigned to another the route, while a complete duty can
    id::String
    required_vehicle_category_id::String
    actions::Vector{Action}
    state_on_starting_the_duty::VehicleState
    state_on_completing_the_duty::VehicleState
end

mutable struct Route
    id::String
    vehicle_set_id::String
    duties::Vector{Duty}
    starting_work_period::Range
    ending_work_period::Range
    
    # path::OSRMpath     # TODO: add OSRM path here
end

mutable struct Solution
    id::String
    instance_id::String
    cost::Float64 
    routes::Vector{Route}
    unassigned_request_ids::Vector{String} # among semi-mandatory or optional requests
end


