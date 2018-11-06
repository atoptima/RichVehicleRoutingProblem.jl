function data_gen_unit_tests()

    generate_symmetric_distance_matrix_tests()
    generate_data_random_tsp_tests()
    generate_random_unit_prices()
    generate_random_depot_tests()
    generate_random_vehicle_category_tests()
    generate_random_vehicle_sets_tests()
    generate_random_pd_points_tests()
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
    @test length(data.vehicle_categories) == 1
    @test length(data.vehicle_sets) == 1
    @test length(data.depots) == 1
    @test length(data.pickup_points) == 4
    @test data.delivery_points == RVRP.DeliveryPoint[]
    @test length(data.requests) == 4
    for i in 1:length(data.requests)
        req = data.requests[i]
        @test req.index == i
        @test req.shipment_type == 1
        @test req.is_optional == false
        @test req.price_reward == 0.0
        @test req.load_capacity_conso == 0.0
        @test req.split_fulfillment == false
        @test req.precedence_restriction == 0
        @test req.alternative_pickup_point_ids == [string("PickupPoint_", i+1)]
        @test req.alternative_delivery_point_ids == String[]
        @test req.setup_service_time == 0.0
        @test req.setdown_service_time == 0.0
        @test req.max_duration == typemax(Int32)
        @test req.product_id == "unique_specific_product"
    end
    @test data.travel_time_matrix == Array{Float64,2}(undef, 0, 0)
    @test size(data.travel_distance_matrix) == (5,5)
    for i in 1:5
        @test data.travel_distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.travel_distance_matrix[i,j] == data.travel_distance_matrix[j,i]
        end
    end
    @test length(data.product_categories) == 1
    @test length(data.products) == 1
end

function generate_random_unit_prices()
    costs = RVRP.generate_random_unit_prices()
    @test typeof(costs) == RVRP.UnitPrices
end

function generate_random_depot_tests()
    depot = RVRP.generate_random_depot(3, 2)
    @test typeof(depot) == RVRP.Depot
    @test depot.id == "depot_2"
    @test depot.index == 2
    @test depot.location.index == 3
    @test depot.location.id == "depot_3"
end

function generate_random_vehicle_category_tests()
    v_cats = RVRP.generate_random_vehicle_category(5)
    @test eltype(v_cats) == RVRP.VehicleCategory
    @test length(v_cats) == 5
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

function generate_random_pd_points_tests()
    ps = RVRP.generate_random_pd_points(RVRP.PickupPoint, 3, 2)
    @test length(ps) == 3
    @test eltype(ps) == RVRP.PickupPoint
    for p in ps
        @test p.location.index >= 2
        @test p.location.index <= 5
    end
    ps = RVRP.generate_random_pd_points(RVRP.DeliveryPoint, 3, 2)
    @test length(ps) == 3
    @test eltype(ps) == RVRP.DeliveryPoint
    for p in ps
        @test p.location.index >= 2
        @test p.location.index <= 5
    end
end

function generate_full_data_tests()
    data = RVRP.generate_full_data_random(3)
    @test typeof(data) == RVRP.RvrpInstance
    @test length(data.pickup_points) == 3
    @test length(data.delivery_points) == 3
    @test length(data.requests) == 6
    for i in 1:length(data.requests)
        @test data.requests[i].index == i
    end
end
