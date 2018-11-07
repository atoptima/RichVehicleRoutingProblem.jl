function generate_symmetric_distance_matrix(n::Int)
    max_value = 20
    matrix = Matrix{Float64}(undef, n, n)
    points = rand(1:max_value, n, 2)
    for j in 1:n
        matrix[j,j] = 0.0
        for i in j+1:n
            matrix[j,i] = sqrt((points[j,1]-points[i,1])^2
                               + (points[j,2]-points[i,2])^2)
            matrix[i,j] = matrix[j,i]
        end
    end
    return matrix
end

function generate_symmetric_distance_matrix(locations::Vector{Coord})
    n = length(locations)
     matrix = Matrix{Float64}(undef, n, n)
    for j in 1:n
        matrix[j,j] = 0.0
        for i in j+1:n
            matrix[i,j] = matrix[j,i] = sqrt((locations[j].x-locations[i].x)^2
                                             + (locations[j].y-locations[i].y)^2)
        end
    end
    return matrix
end

function generate_random_pd_points(point_type::T, n::Int, first_loc_idx::Int;
         with_tw = false) where T <: Union{Type{PickupPoint}, Type{DeliveryPoint}}
    points = point_type[]
    prefix = string(point_type)
    for i in 1:n
        coord = Coord(rand(1:20), rand(1:20))
        loc = Location(string("loc_", first_loc_idx), first_loc_idx, coord)
        if !with_tw
            tws = TimeWindow[TimeWindow(0, typemax(Int32))]
        else
            tws = TimeWindow[TimeWindow(rand(1:20), rand(20:25))]
        end
        p = point_type(string(prefix, "_", i), i, loc, tws, 0.0)
        push!(points, p)
        first_loc_idx += 1
    end
    return points
end

function generate_data_random_tsp(n::Int)
    id = string("tsp_random_", rand(1:1000))
    tw = TimeWindow(0.0, typemax(Int32))
    vc = VehicleCategory(
        "unique_category", 1, 0.0, UnitPrices(1.0, 0.0, 0.0, 0.0, 0.0),
        [typemax(Int32)], typemax(Int32), typemax(Int32), 0, String[])
    v = HomogeneousVehicleSet("unique_vehicle", 1, "unique_depot",
                              ["unique_depot"], 1, [1], vc, tw, 0.0, 1, 1,
                              typemax(Int32), typemax(Int32), false)
    vehicle_categories = [vc]
    vehicle_sets = [v]
    pickup_points = generate_random_pd_points(PickupPoint, n, 1)
    locations = [pickup_points[i].location for i in 1:length(pickup_points)]
    coords = [pickup_points[i].location.coord for i in 1:length(pickup_points)]
    travel_distance_matrix = generate_symmetric_distance_matrix(coords)
    travel_time_matrix = energy_consumption_matrix = Array{Float64,2}(undef, 0, 0)
    depot_points = [DepotPoint("unique_depot", 1, locations[1], [tw], 0.0)]
    pickup_points = pickup_points[2:end] # the first client is fixed as depot
    delivery_points = DeliveryPoint[]
    product_categories = [ProductCategory(
        "unique_product", 1, String[], String[]
    )]
    products = [SpecificProduct(
        "unique_specific_product", 1, "unique_product",
        Dict{String,Float64}(), Dict{String,Float64}()
    )]
    requests = Request[]
    for i in 1:length(pickup_points)
        p = pickup_points[i]
        req = Request(
            string("client_", p.index), i, "unique_specific_product", false,
            0.0, 0.0, 0.0, false, 0, [string("PickupPoint_", p.index)],
            String[], 0.0, 0.0, typemax(Int32)
        )
        push!(requests, req)
    end
    recharging_points = RechargingPoint[]
    return RvrpInstance(
        id, travel_distance_matrix, travel_time_matrix,
        energy_consumption_matrix, pickup_points, delivery_points,
        depot_points, recharging_points, product_categories, products,
        requests, vehicle_categories, vehicle_sets
    )
end

function generate_random_unit_prices()
    return UnitPrices(rand(1:100, 5)...)
end

function generate_random_depot(loc_idx::Int, depot_idx::Int)
    coord = Coord(rand(1:20), rand(1:20))
    return DepotPoint(string("depot_", depot_idx), depot_idx,
                 Location(string("depot_", loc_idx), loc_idx, coord),
                 [TimeWindow(rand(1:20), rand(1:20))], rand())
end

function generate_random_vehicle_category(n::Int)
    vehicle_categories = VehicleCategory[]
    price = generate_random_unit_prices()
    for i in 1:n
          vc = VehicleCategory(
              string("cat_", i), i, rand(), price, [typemax(Int32)],
              typemax(Int32), typemax(Int32), 0, String[])
        push!(vehicle_categories, vc)
    end
    return vehicle_categories
end

function generate_random_vehicle_sets(n::Int, categs::Vector{VehicleCategory},
                                      depot_points::Vector{DepotPoint}; with_tw=false)
    vs = HomogeneousVehicleSet[]
    for i in 1:n
        if !with_tw
            tw = TimeWindow(0, typemax(Int32))
        else
            tw = TimeWindow(rand(1:20), rand(20:25))
        end
        depot_idx = rand(1:length(depot_points))
        depot_id = depot_points[depot_idx].id
        v = HomogeneousVehicleSet(
            string("set_", i), i, depot_id, [depot_id], depot_idx, [depot_idx],
            categs[rand(1:length(categs))], tw, 0.0, 1, 1, typemax(Int32),
            typemax(Int32), false
        )
        push!(vs, v)
    end
    return vs
end

function generate_full_data_random(n::Int)
    id = string("full_random_", rand(1:1000))
    vehicle_categories = generate_random_vehicle_category(2)
    depot_points = [generate_random_depot(i, i) for i in 1:2]
    vehicle_sets = generate_random_vehicle_sets(3, vehicle_categories, depot_points)
    travel_distance_matrix = Array{Float64,2}(undef, 0, 0)
    travel_time_matrix = energy_consumption_matrix = Array{Float64,2}(undef, 0, 0)
    pickup_points = generate_random_pd_points(PickupPoint, n, 1)
    delivery_points = generate_random_pd_points(DeliveryPoint, n, 1)
    product_categories = [ProductCategory(
        "unique_product", 1, String[], String[]
    )]
    products = [SpecificProduct(
        "unique_specific_product", 1, "unique_product",
        Dict{String,Float64}(), Dict{String,Float64}()
    )]
    requests = Request[]
    for i in 1:length(pickup_points)
        p = pickup_points[i]
        req = Request(
            string("client_", p.index), i, "unique_specific_product", false,
            0.0, 0.0, 0.0, false, 0, [string("PickupPoint_", p.index)],
            String[], 0.0, 0.0, typemax(Int32)
        )
        push!(requests, req)
    end
    for i in 1:length(delivery_points)
        d = delivery_points[i]
        req = Request(
            string("client_", d.index + length(pickup_points)),
            i + length(pickup_points), "unique_specific_product", false, 0.0,
            0.0, 0.0, false, 0, String[], [string("DeliveryPoint_", d.index)],
            0.0, 0.0, typemax(Int32))
        push!(requests, req)
    end

    recharging_points = RechargingPoint[]
    return RvrpInstance(
        id, travel_distance_matrix, travel_time_matrix, energy_consumption_matrix,
        pickup_points, delivery_points, depot_points, recharging_points,
        product_categories, products, requests, vehicle_categories, vehicle_sets
    )
end
