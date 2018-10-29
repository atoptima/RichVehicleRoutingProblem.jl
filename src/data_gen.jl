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

function generate_data_random_tsp(n::Int)
    # Generate the points
    problem_id = string("tsp_random_", rand(1:1000))
    problem_type = ProblemType("FINITE", "HOMOGENEOUS")
    tw = TimeWindow(0.0, typemax(Int32))
    vc = VehicleCategory("unique_category", 1, 0.0,
                         UnitPricing(1.0, 0.0, 0.0, 0.0), 0.0)
    v = HomogeneousVehicleSet("unique_vehicle", 1, "unique_depot",
                              ["unique_depot"], 1, [1], vc, tw,
                              1, 1, typemax(Int32), typemax(Int32))
    vehicle_categories = [vc]
    vehicle_sets = [v]
    pickups = generate_random_pickups(n, 1, 0:0)
    locations = [pickups[i].location for i in 1:length(pickups)]
    coords = [pickups[i].location.coord for i in 1:length(pickups)]
    travel_distance_matrix = generate_symmetric_distance_matrix(coords)
    travel_time_matrix = Array{Float64,2}(undef, 0, 0)
    depots = [Depot("unique_depot", 1, locations[1], [tw])]
    deliveries = Delivery[]
    shipments = Shipment[]

    return RvrpProblem(problem_id, problem_type, vehicle_categories,
        vehicle_sets, travel_distance_matrix, travel_time_matrix, depots,
        pickups, deliveries, shipments)
end

function generate_random_unit_pricing()
    return UnitPricing(rand(1:100, 4)...)
end

function generate_random_vehicle_category(n::Int)
    vehicle_categories = VehicleCategory[]
    pricing = generate_random_unit_pricing()
    for i in 1:n
        vc = VehicleCategory(string("cat_", i), i, rand(), pricing, rand(3:10))
        push!(vehicle_categories, vc)
    end
    return vehicle_categories
end

function generate_random_depot(loc_idx::Int, depot_idx::Int)
    coord = Coord(rand(1:20), rand(1:20))
    return Depot(string("depot_", depot_idx), depot_idx,
                 Location(string("depot_", loc_idx), loc_idx, coord),
                 [TimeWindow(rand(1:20), rand(1:20))])
end

function generate_random_vehicle_sets(n::Int, categs::Vector{VehicleCategory},
                                      depots::Vector{Depot}; with_tw = false)
    vs = HomogeneousVehicleSet[]
    for i in 1:n
        if !with_tw
            tw = TimeWindow(0, typemax(Int32))
        else
            tw = TimeWindow(rand(1:20), rand(20:25))
        end
        depot_idx = rand(1:length(depots))
        depot_id = depots[depot_idx].id
        v = HomogeneousVehicleSet(string("set_", i), i,
                                  depot_id, [depot_id],
                                  depot_idx, [depot_idx],
                                  categs[rand(1:length(categs))], tw, 1, 1,
                                  typemax(Int32), typemax(Int32))
        push!(vs, v)
    end
    return vs
end

function generate_random_pickups(n::Int, first_loc_idx::Int,
                                 load_consumption_bounds::UnitRange{Int64};
                                 with_tw = false)
    pickups = Pickup[]
    for i in 1:n
        coord = Coord(rand(1:20), rand(1:20))
        loc = Location(string("loc_", first_loc_idx), first_loc_idx, coord)
        tws = TimeWindow[]
        if with_tw
            push!(tws, TimeWindow(rand(1:20), rand(20:25)))
        end
        p = Pickup(string("pickup_", i), i, loc, rand(load_consumption_bounds),
                   tws, rand(1:5))
        push!(pickups, p)
        first_loc_idx += 1
    end
    return pickups
end

function generate_full_data_random(n::Int)
    problem_id = string("full_random_", rand(1:1000))
    problem_type = ProblemType("FINITE", "HETEROGENEOUS")
    vehicle_categories = generate_random_vehicle_category(2)
    depots = [generate_random_depot(i, i) for i in 1:2]
    vehicle_sets = generate_random_vehicle_sets(3, vehicle_categories, depots)
    travel_distance_matrix = Array{Float64,2}(undef, 0, 0)
    travel_time_matrix = Array{Float64,2}(undef, 0, 0)
    pickups = generate_random_pickups(n, 3, 1:3)
    deliveries = Delivery[]
    shipments = Shipment[]

    return RvrpProblem(problem_id, problem_type, vehicle_categories,
        vehicle_sets, travel_distance_matrix, travel_time_matrix, depots,
        pickups, deliveries, shipments)
end
