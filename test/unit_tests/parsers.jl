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
    tw = RVRP.TimeWindow(0.0, typemax(Int32))

    @test typeof(data) == RVRP.RvrpInstance
    @test length(data.vehicle_categories) == 1
    @test data.vehicle_categories[1].index == 1
    @test data.vehicle_categories[1].fixed_cost == 0.0
    @test data.vehicle_categories[1].unit_pricing == RVRP.UnitPrices(1.0, 0.0,
                                                                     0.0, 0.0)
    @test data.vehicle_categories[1].compartment_capacities == [typemax(Int32)]
    @test data.vehicle_categories[1].energy_recharges == []
    @test data.vehicle_categories[1].loading_option == 0
    @test data.vehicle_categories[1].prohibited_product_category_ids == String[]
    @test length(data.vehicle_sets) == 1
    @test data.vehicle_sets[1].index == 1
    @test data.vehicle_sets[1].departure_depot_index == 1
    @test data.vehicle_sets[1].arrival_depot_indices == [1]
    @test data.vehicle_sets[1].departure_depot_ids == [data.vehicle_sets[1].arrival_depot_ids[1]]
    @test data.vehicle_sets[1].vehicle_category == data.vehicle_categories[1]
    @test data.vehicle_sets[1].working_time_window == tw
    @test data.vehicle_sets[1].min_nb_of_vehicles == 1
    @test data.vehicle_sets[1].max_nb_of_vehicles == 16
    @test data.vehicle_sets[1].max_working_time == typemax(Int32)
    @test data.vehicle_sets[1].max_travel_distance == typemax(Int32)
    @test data.vehicle_sets[1].allow_ongoing == false

    @test data.travel_time_matrix == Array{Float64,2}(undef, 0, 0)
    for i in 1:5
        @test data.travel_distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.travel_distance_matrix[i,j] == data.travel_distance_matrix[j,i]
        end
    end

    @test length(data.depot_points) == 1
    @test data.depot_points[1].index == 1
    @test data.depot_points[1].opening_time_windows == [tw]
    @test data.delivery_points == RVRP.DeliveryPoint[]

    @test length(data.products) == 1
    @test data.product_categories[1].index == 1
    @test data.product_categories[1].conflicting_product_ids == String[]
    @test data.product_categories[1].prohibited_predecessor_product_ids == String[]
    @test length(data.products) == 1
    @test data.products[1].index == 1
    @test data.products[1].product_category_id == data.product_categories[1].id
    @test data.products[1].pickup_availabitilies_at_point_ids == Dict{String,Float64}()
    @test data.products[1].delivery_capacities_at_point_ids == Dict{String,Float64}()

    @test length(data.recharging_points) == 0
    @test length(data.pickup_points) == 15
    @test length(data.requests) == 15

    for i in length(data.pickup_points)
        p = data.pickup_points[i]
        r = data.requests[i]
        @test p.index == i
        @test length(p.opening_time_windows) == 1
        @test p.opening_time_windows == [tw]
        @test p.access_time == 0.0
        @test r.is_optional == false
        @test r.price_reward == 0.0
        @test r.product_quantity == r.compartment_capacity_consumption
        @test r.split_fulfillment == false
        @test r.precedence_restriction == 0
        @test r.alternative_pickup_point_ids == [p.id]
        @test r.alternative_delivery_point_ids == String[]
        @test r.pickup_service_time == 0.0
        @test r.delivery_service_time == 0.0
        @test r.max_duration == typemax(Int32)
    end
end
