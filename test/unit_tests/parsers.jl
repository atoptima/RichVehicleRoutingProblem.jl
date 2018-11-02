function parsers_unit_tests()
    parse_to_json_tests()
    parse_from_json_tests()
    parse_cvrplib_tests()
end

function parse_to_json_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end

function parse_from_json_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    data2 = RVRP.parse_from_json("../dump/dummy.json")
    @test data == data2
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false

    data = RVRP.generate_full_data_random(3)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    data2 = RVRP.parse_from_json("../dump/dummy.json")
    @test data == data2
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end

function parse_cvrplib_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    @test typeof(data) == RVRP.RvrpInstance
    @test data.problem_type.fleet_size == "INFINITE"
    @test data.problem_type.fleet_composition == "HOMOGENEOUS"
    @test data.problem_type.request_cover == "MANDATORY"
    @test length(data.vehicle_categories) == 1
    @test data.vehicle_categories[1].capacity == 35.0
    @test data.vehicle_categories[1].fixed_cost == 0.0
    @test data.vehicle_categories[1].unit_pricing == RVRP.UnitPricing(1.0, 0.0,
                                                                      0.0, 0.0)
    @test length(data.vehicle_sets) == 1
    @test data.vehicle_sets[1].max_nb_of_vehicles == 16
    @test length(data.pickups) == 15
    @test length(data.depots) == 1
    @test length(data.deliveries) == 0
    @test length(data.shipments) == 0
    for p in data.pickups
        @test p.shipment_id == ""
        @test length(p.time_windows) == 1
        @test p.time_windows[1].begin_time == 0.0
        @test p.time_windows[1].end_time == typemax(Int32)
    end
    for i in 1:5
        @test data.travel_distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.travel_distance_matrix[i,j] == data.travel_distance_matrix[j,i]
        end
    end
end
