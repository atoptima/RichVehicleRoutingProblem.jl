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
    write(io, json2_string * "\n")
    close(io)
end

function parse_from_json(file_path::String)
    io = open(file_path, "r")
    s = read(io, String)
    close(io)
    data = JSON2.read(s, RvrpInstance)
    set_indices(data)
    return data
end


######################## CVRPLIB parsers ########################
function parse_cvrplib(file_path::String)
    scan = Scanner.Scan(file_path)
    garbage = Scanner.next(scan, String)
    garbage = Scanner.next(scan, String)
    id = Scanner.next(scan, String)
    garbage = Scanner.nextline(scan)
    garbage = Scanner.nextline(scan)
    n = Scanner.next(scan, Int)
    garbage = Scanner.nextline(scan)
    capacity = Scanner.next(scan, Int)
    garbage = Scanner.nextline(scan)
    points = Scanner.nextmatrix(scan, Int, n, 3, rowmajor = true)[1:end,2:end]
    garbage = Scanner.nextline(scan)
    demands = Scanner.nextmatrix(scan, Int, n, 2, rowmajor = true)[1:end,2:end]
    garbage = Scanner.nextline(scan)
    depot_id = Scanner.next(scan, Int)
    Scanner.finish_scan(scan)
    
    coords = [Coord(points[i,1], points[i,2]) for i in 1:n]
    locations = [Location(string("loc_", i), i, coords[i])  for i in 1:n]
    problem_type = ProblemType("INFINITE", "HOMOGENEOUS", "MANDATORY")
    tw = TimeWindow(0.0, typemax(Int32))
    vc = VehicleCategory("unique_category", 1, 0.0,
                         UnitPricing(1.0, 0.0, 0.0, 0.0), capacity)
    v = HomogeneousVehicleSet("unique_vehicle", 1, "unique_depot",
                              ["unique_depot"], 1, [1], vc, tw,
                              1, n, typemax(Int32),
                              typemax(Int32))
    vehicle_categories = [vc]
    vehicle_sets = [v]
    depots = [Depot("unique_depot", 1, locations[depot_id], [tw])]
    pickups = [Pickup(string("client_", i), i, locations[i], "", 0.0,
                      demands[i,1], [tw], 0.0) for i in 1:n if i != depot_id]
    travel_distance_matrix = generate_symmetric_distance_matrix(coords)
    for j in 1:n, i in 1:n
        travel_distance_matrix[i,j] = round(travel_distance_matrix[i,j],
                                            RoundingMode{:Nearest}())
    end
    travel_time_matrix = Array{Float64,2}(undef, 0, 0)
    deliveries = Delivery[]
    shipments = Shipment[]

    return RvrpInstance(id, problem_type, vehicle_categories, vehicle_sets,
                        travel_distance_matrix, travel_time_matrix, depots,
                        pickups, deliveries, shipments)
end

