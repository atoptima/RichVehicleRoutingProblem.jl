
function parser_cvrplib_unit_tests()
    parse_cvrplib_tests()
end

function parse_cvrplib_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)*
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")

    @test typeof(data) == RVRP.RvrpInstance
    @test data.id == "P-n16-k8"
    @test data.travel_specifications[1].id == "unique_period_cat"
    travel_time_mat = data.travel_specifications[1].travel_time_matrix
    travel_distance_mat = data.travel_specifications[1].travel_distance_matrix
    energy_consum_mat = data.travel_specifications[1].energy_consumption_matrix
    @test size(travel_distance_mat) == (16, 16)
    for i in 1:16
        @test travel_distance_mat[i,i] == 0.0
        for j in i+1:16
            @test travel_distance_mat[i,j] == travel_distance_mat[j,i]
        end
    end
    @test travel_time_mat == Array{Float64,2}(undef, 0, 0)
    @test energy_consum_mat == Array{Float64,2}(undef, 0, 0)
    @test length(data.locations) == 16
    @test data.locations[1].id == "depot"
    @test length(data.location_groups) == length(data.locations)
    for i in 1:length(data.locations)
        @test(string(data.locations[i].id, "_loc_group") ==
                data.location_groups[i].id)
    end
    @test length(data.product_compatibility_classes) == 1
    @test data.product_compatibility_classes[1].id == "default_id"
    @test length(data.product_sharing_classes) == 1
    @test data.product_sharing_classes[1].id == "default_id"
    @test length(data.requests) == 15
    @test length(data.vehicle_categories) == 2
    @test length(data.vehicle_sets) == 1
    @test data.vehicle_categories[1].id == "unique_vehicle_category"
    @test haskey(data.vehicle_categories[1].capacities.of_vehicle, "unique_measure")
    @test(data.vehicle_categories[1].capacities.of_vehicle ==
            Dict{String,Float64}("unique_measure" => 35.0))
    @test length(data.vehicle_sets[1].work_periods) == 1
    @test length(data.vehicle_sets[1].cost_periods) == 1
    @test data.vehicle_sets[1].cost_periods[1].travel_distance_unit_cost == 1.0
    @test data.vehicle_sets[1].id == "unique_vehicle_set"
    @test data.vehicle_sets[1].vehicle_category_id == "unique_vehicle_category"
    @test(data.vehicle_sets[1].departure_location_group_id ==
            data.vehicle_sets[1].arrival_location_group_id == "depot_loc_group")
    @test data.vehicle_sets[1].nb_of_vehicles_range == RVRP.FlexibleRange(
        RVRP.Range(0, 15), RVRP.Range(0, 15), RVRP.Flexibility(0, 0.0, 0.0),
        RVRP.Flexibility(0, 0.0, 0.0)
    )
    for req_idx in 1:length(data.requests)
        req = data.requests[req_idx]
        @test req.product_quantity_range.lb == req.product_quantity_range.ub
        @test req.pickup_location_group_id == data.location_groups[req_idx+1].id
        @test(req.product_sharing_class_id ==
                req.product_compatibility_class_id == "default_id")
        @test req.product_specification_class_id == "unique_p_spec_c"
    end

    # apply checker on cvrp data, computed data
    computed_data = RVRP.build_computed_data(data)
    RVRP.check_instance(data, computed_data)
    RVRP.print_features(computed_data.features)
end
