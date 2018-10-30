################################# JSON Parsers #################################
JSON2.@format Location begin
    index => (default=0,)
end

JSON2.@format Depot begin
    index => (default=0,)
end

JSON2.@format Pickup begin
    index => (default=0,)
end

JSON2.@format Delivery begin
    index => (default=0,)
end

JSON2.@format Shipment begin
    index => (default=0,)
end

JSON2.@format VehicleCategory begin
    index => (default=0,)
    departure_depot_index => (default=0,)
    arrival_depot_indices => (default=Int[],)
end

JSON2.@format HomogeneousVehicleSet begin
    index => (default=0,)
end

function parse_to_json(data::RvrpInstance, file_path::String)
    json2_string = JSON2.write(data)
    io = open(file_path, "w")
    write(io, json2_string)
    write(io, "\n")
    close(io)
end

function parse_from_json(file_path::String)
    io = open(file_path, "r")
    s = read(io, String)
    data = JSON2.read(s, RvrpInstance)
    set_indices(data)
    return data
end
