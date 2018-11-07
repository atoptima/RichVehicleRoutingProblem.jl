################################# JSON Parsers #################################
JSON2.@format Location begin
    index => (default=0,)
end

JSON2.@format DepotPoint begin
    index => (default=0,)
end

JSON2.@format PickupPoint begin
    index => (default=0,)
end

JSON2.@format DeliveryPoint begin
    index => (default=0,)
end

JSON2.@format Request begin
    index => (default=0,)
end

JSON2.@format ProductCategory begin
    index => (default=0,)
end

JSON2.@format SpecificProduct begin
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
    depot_idx = Scanner.next(scan, Int)
    Scanner.finish_scan(scan)
    
    coords = [Coord(points[i,1], points[i,2]) for i in 1:n]
    locations = [Location(string("loc_", i), i, coords[i])  for i in 1:n]
    tw = TimeWindow(0.0, typemax(Int32))
      vc = VehicleCategory(
          "unique_category", 1, 0.0, UnitPrices(1.0, 0.0, 0.0, 0.0, 0.0),
          [typemax(Int32)], typemax(Int32), typemax(Int32), 0, String[])
    v = HomogeneousVehicleSet(
        "unique_vehicle", 1, "unique_depot", ["unique_depot"], 1, [1], vc, tw,
        0.0, 1, n, typemax(Int32), typemax(Int32), false
    )
    vehicle_categories = [vc]
    vehicle_sets = [v]
    depot_points = [DepotPoint("unique_depot", 1, locations[depot_idx], [tw], 0.0)]
    pickup_points = PickupPoint[]
    p_idx = 1
    for l_idx in 1:n
        if l_idx != depot_idx
            p = PickupPoint(
                string("pickup_point_", p_idx), p_idx,
                locations[l_idx], [tw], 0.0
            )
            push!(pickup_points, p)
            p_idx += 1
        end
    end
    travel_distance_matrix = generate_symmetric_distance_matrix(coords)
    for j in 1:n, i in 1:n
        travel_distance_matrix[i,j] = round(travel_distance_matrix[i,j],
                                            RoundingMode{:Nearest}())
    end
    travel_time_matrix = energy_consumption_matrix = Array{Float64,2}(undef, 0, 0)
    delivery_points = DeliveryPoint[]

    product_categories = [ProductCategory(
        "unique_product", 1, String[], String[]
    )]
    products = [SpecificProduct(
        "unique_specific_product", 1, "unique_product",
        Dict{String,Float64}(), Dict{String,Float64}()
    )]

    requests = [Request(
        string("request_", p.index), p.index, "unique_specific_product",
        false, 0.0, demands[p.index], demands[p.index], false, 0,
        [string("pickup_point_", p.index)], String[], 0.0, 0.0, typemax(Int32)
    ) for p in pickup_points]

    recharging_points = RechargingPoint[]
    return RvrpInstance(
        id, travel_distance_matrix, travel_time_matrix, energy_consumption_matrix,
        pickup_points, delivery_points, depot_points, recharging_points,
        product_categories, products, requests, vehicle_categories, vehicle_sets
    )
end

