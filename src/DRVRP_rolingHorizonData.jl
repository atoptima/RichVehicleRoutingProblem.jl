# To use the solution, the input data is required


struct InitialState
    id::String
    instance_id::String
    ongoing_routes::Vector{Route} # holds the backlog of uncompleted requests
    assigned_pickup_ids::Vector{String} # the request is partially fulfilled 
    uncompleted_delivery_ids::Vector{String} # the request is partially fulfilled 
    uncompleted_shipment_ids::Vector{String} # the request is partially fulfilled 
end

