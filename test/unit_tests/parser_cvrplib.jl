function parser_cvrplib_unit_tests()
    parse_cvrplib_tests()
end

function parse_cvrplib_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")

    @test typeof(data) == RVRP.RvrpInstance
    @test data.id == "P-n16-k8"
    @test haskey(data.travel_distance_matrices, "unique_mat")
    @test size(data.travel_distance_matrices["unique_mat"]) == (16, 16)
    for i in 1:16
        @test data.travel_distance_matrices["unique_mat"][i,i] == 0.0
        for j in i+1:16
            @test data.travel_distance_matrices["unique_mat"][i,j] == data.travel_distance_matrices["unique_mat"][j,i]
        end
    end
    @test data.travel_time_matrices == Dict{String,Array{Float64,2}}()
    @test data.energy_consumption_matrices == Dict{String,Array{Float64,2}}()
    @test length(data.locations) == 16
    @test data.locations[1].id == "depot"
    @test length(data.location_groups) == length(data.locations)
    for i in 1:length(data.locations)
        @test string(data.locations[i].id, "_loc_group") == data.location_groups[i].id
    end
    @test length(data.product_compatibility_classes) == 1
    @test length(data.product_sharing_classes) == 1
    @test length(data.product_specification_classes) == 1
    @test length(data.requests) == 15
    @test length(data.vehicle_categories) == 1
    @test length(data.vehicle_sets) == 1
    @test data.vehicle_categories[1].id == "unique_vehicle_category"
    @test haskey(data.vehicle_categories[1].vehicle_capacities, "unique_measure")
    @test data.vehicle_categories[1].vehicle_capacities == Dict{String,Float64}("unique_measure" => 35.0)
    @test data.vehicle_sets[1].id == "unique_vehicle_set"
    @test data.vehicle_sets[1].vehicle_category_id == "unique_vehicle_category"
    @test data.vehicle_sets[1].departure_location_group_id == data.vehicle_sets[1].arrival_location_group_id == "depot_loc_group"
    @test data.vehicle_sets[1].travel_distance_unit_cost == 1.0
    @test data.vehicle_sets[1].nb_of_vehicles_range == RVRP.FlexibleRange(
        RVRP.Range(0, 15), RVRP.Range(0, 15), RVRP.Flexibility(0, 0.0, 0.0),
        RVRP.Flexibility(0, 0.0, 0.0)
    )
    for req_idx in 1:length(data.requests)
        req = data.requests[req_idx]
        @test req.product_quantity_range.lb == req.product_quantity_range.ub
        @test req.pickup_location_group_id == data.location_groups[req_idx+1].id
    end

end
