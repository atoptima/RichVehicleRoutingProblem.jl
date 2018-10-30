function data_gen_unit_tests()

    generate_symmetric_distance_matrix_tests()
    generate_data_random_tsp_tests()
    generate_random_unit_pricing()
    generate_random_vehicle_category_tests()
    generate_random_depot_tests()
    generate_random_vehicle_sets_tests()
    generate_random_pickups_tests()
    generate_full_data_tests()

end

function generate_symmetric_distance_matrix_tests()
    coords = [RVRP.Coord(rand(1:20), rand(1:20)) for i in 1:5]
    matrix_1 = RVRP.generate_symmetric_distance_matrix(coords)
    matrix_2 = RVRP.generate_symmetric_distance_matrix(5)
    @test size(matrix_1) == (5,5)
    @test size(matrix_2) == (5,5)
    for i in 1:5
        @test matrix_1[i,i] == 0.0
        @test matrix_2[i,i] == 0.0
        for j in i+1:5
            @test matrix_1[i,j] == matrix_1[j,i]
            @test matrix_2[i,j] == matrix_2[j,i]
        end
    end
end

function generate_data_random_tsp_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test typeof(data) == RVRP.RvrpInstance
    @test data.id[1:11] == "tsp_random_"
    @test data.problem_type.fleet_size == "FINITE"
    @test data.problem_type.fleet_composition == "HOMOGENEOUS"
    @test length(data.vehicle_categories) == 1
    @test length(data.vehicle_sets) == 1
    @test length(data.depots) == 1
    @test length(data.pickups) == 5
    @test data.deliveries == RVRP.Delivery[]
    @test data.shipments == RVRP.Shipment[]
    @test data.travel_time_matrix == Array{Float64,2}(undef, 0, 0)
    @test size(data.travel_distance_matrix) == (5,5)
    for i in 1:5
        @test data.travel_distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.travel_distance_matrix[i,j] == data.travel_distance_matrix[j,i]
        end
    end
end

function generate_random_unit_pricing()
    costs = RVRP.generate_random_unit_pricing()
    @test typeof(costs) == RVRP.UnitPricing
end

function generate_random_vehicle_category_tests()
    v_cats = RVRP.generate_random_vehicle_category(5)
    @test eltype(v_cats) == RVRP.VehicleCategory
    @test length(v_cats) == 5
end

function generate_random_depot_tests()
    depot = RVRP.generate_random_depot(3, 2)
    @test typeof(depot) == RVRP.Depot
    @test depot.id == "depot_2"
    @test depot.index == 2
    @test depot.location.index == 3
    @test depot.location.id == "depot_3"
end

function generate_random_vehicle_sets_tests()
    v_cats = RVRP.generate_random_vehicle_category(2)
    depots = [RVRP.generate_random_depot(i+1, i) for i in 1:2]
    vs = RVRP.generate_random_vehicle_sets(3, v_cats, depots)
    @test length(vs) == 3
    @test eltype(vs) == RVRP.HomogeneousVehicleSet
    for v in vs
        @test v.departure_depot_index >= 1
        @test v.departure_depot_index <= 2
        @test length(v.arrival_depot_indices) == 1
        @test v.departure_depot_index == v.arrival_depot_indices[1]
    end
end

function generate_random_pickups_tests()
    ps = RVRP.generate_random_pickups(3, 2, 1:5)
    @test length(ps) == 3
    @test eltype(ps) == RVRP.Pickup
    for p in ps
        @test p.location.index >= 2
        @test p.location.index <= 5
    end
end

function generate_full_data_tests()
    data = RVRP.generate_full_data_random(3)
    @test length(data.pickups) == 3
    @test length(data.deliveries) == 0
    @test length(data.shipments) == 0
    @test typeof(data) == RVRP.RvrpInstance
end
