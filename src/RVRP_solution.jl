# To use the solution, the input data is required

mutable struct Action
    id::String
    location_id::String
    request_id::String # if any request is linked to a request the operation
    operation_type::Int # 0- Depot, 1 - Pickup, 2 - Delivery, 3 - ...otherOperation
    product_quantity::Float64 # to record the picked/delivered quantity in case of split_fulfillment
end

mutable struct Route
    id::String
    vehicle_set_id::String
    sequence::Vector{Action}
    # path::OSRMpath     # TODO: add OSRM path here
end

mutable struct RvrpSolution
    id::String
    instance_id::String
    cost::Float64 
    routes::Vector{Route}
end


