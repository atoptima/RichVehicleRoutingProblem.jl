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

    travel_matrix_periods = [Range()]
    period_to_matrix_id = Dict{Range,String}(travel_matrix_periods[1] => "unique_mat")
    mat = generate_symmetric_distance_matrix(xs, ys)
    for j in 1:n
        for i in 1:n
            mat[i,j] = round(mat[i,j], RoundingMode{:Nearest}())
        end
    end
    travel_distance_matrices = Dict{String,Array{Float64,2}}("unique_mat" => mat)
    travel_time_matrices = Dict{String,Array{Float64,2}}()
    energy_consumption_matrices = Dict{String,Array{Float64,2}}()
    work_periods = [Range()]

    locations = [Location(
        id = string("loc_", i), index = i,
        longitude = xs[i], latitude = ys[i]
    ) for i in 1:n]
    locations[depot_idx].id = "depot"
    location_groups = create_singleton_location_groups(locations)

    product_compatibility_classes = ProductCompatibilityClass[]
    product_sharing_classes = ProductSharingClass[]
    product_specification_classes = [ProductSpecificationClass(
        id = "unique_p_spec_c",
        capacity_consumptions = Dict{String,Tuple{Float64,Float64}}("unique_measure" => (1.0,1.0))
    )]

    requests = Request[]
    req_idx = 0
    for i in 1:n
        if i != depot_idx
            req = Request(
                id = string("req_", req_idx),
                product_specification_class_id = "unique_p_spec_c",
                product_quantity_range = single_val_range(demands[i]),
                pickup_location_group_id = location_groups[i].id
            )
            push!(requests, req)
            req_idx += 1
        end
    end

    vehicle_categories = [VehicleCategory(
        id = "unique_vehicle_category",
        vehicle_capacities = Dict{String,Float64}("unique_measure" => capacity)
    )]
    vehicle_sets = [HomogeneousVehicleSet(
        id = "unique_vehicle_set",
        vehicle_category_id = "unique_vehicle_category",
        departure_location_group_id = "depot_loc_group",
        arrival_location_group_id = "depot_loc_group",
        travel_distance_unit_cost = 1.0,
        nb_of_vehicles_range = FlexibleRange(soft_range = Range(0, n-1),
                                             hard_range = Range(0, n-1))
    )]

    data = RvrpInstance(
        id, travel_matrix_periods, period_to_matrix_id, travel_time_matrices,
        travel_distance_matrices, energy_consumption_matrices, work_periods,
        locations, location_groups, product_compatibility_classes,
        product_sharing_classes, product_specification_classes, requests,
        vehicle_categories, vehicle_sets
    )
    preprocess_instance(data)
    return data

end

