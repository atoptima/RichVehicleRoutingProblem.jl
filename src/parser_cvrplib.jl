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
    
    xs = [points[i,1] for i in 1:n]
    ys = [points[i,2] for i in 1:n]

    travel_distance_matrix = generate_symmetric_distance_matrix(xs, ys)
    travel_time_matrix = Array{Float64,2}(undef,0,0)
    energy_consumption_matrix = Array{Float64,2}(undef,0,0)

    locations = [Location(
        id = string("loc_", i), index = i, x_coord = xs[i], y_coord = ys[i]
    ) for i in 1:n]
    locations[depot_idx].id = "depot"
    location_groups = LocationGroup[]
    product_categories = [ProductCategory(
        id = "unique_product_category"
    )]
    specific_products = [SpecificProduct(
        id = "unique_specific_product"
    )]
    
    requests = Request[]
    req_idx = 0
    for i in 1:n
        if i != depot_idx
            req = Request(
                id = string("req_", req_idx),
                specific_product_id = "unique_specific_product",
                product_quantity_range = simple_range(demands[i]),
                shipment_capacity_consumption = [demands[i]],
                pickup_location_id = locations[i].id
            )
            push!(requests, req)
            req_idx += 1
        end
    end

    vehicle_categories = [VehicleCategory(
        id = "unique_vehicle_category",
        compartment_capacities = fill(capacity, 1, 1)
    )]
    vehicle_sets = [HomogeneousVehicleSet(
        id = "unique_vehicle_set",
        vehicle_category_id = "unique_vehicle_category",
        departure_location_id = "depot",
        arrival_location_id = "depot",
        travel_distance_unit_cost = 1.0,
        nb_of_vehicles_range = Range(0, 0, n-1, n-1, 0.0, 0.0, 0.0)
    )]

    return RvrpInstance(
        id, travel_distance_matrix, travel_time_matrix,
        energy_consumption_matrix, locations, location_groups,
        product_categories, specific_products, requests, vehicle_categories,
        vehicle_sets
    )

end

