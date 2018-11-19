function parser_cvrplib_unit_tests()
    parse_cvrplib_tests()
end

function parse_cvrplib_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")

    @test typeof(data) == RVRP.RvrpInstance
    @test data.id == "P-n16-k8"
    @test size(data.travel_distance_matrix) == (16, 16)
    for i in 1:5
        @test data.travel_distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.travel_distance_matrix[i,j] == data.travel_distance_matrix[j,i]
        end
    end
    @test data.travel_time_matrix == Array{Float64,2}(undef, 0, 0)
    @test data.energy_consumption_matrix == Array{Float64,2}(undef, 0, 0)
    @test length(data.locations) == 16
    @test data.locations[1].id == "depot"
    @test data.location_groups == RVRP.LocationGroup[]
    @test length(data.product_categories) == 1
    @test length(data.specific_products) == 1
    @test length(data.requests) == 15
    @test length(data.vehicle_categories) == 1
    @test length(data.vehicle_sets) == 1
    @test data.vehicle_categories[1].id == "unique_vehicle_category"
    @test size(data.vehicle_categories[1].compartment_capacities) == (1, 1)
    @test data.vehicle_sets[1].id == "unique_vehicle_set"
    @test data.vehicle_sets[1].vehicle_category_id == "unique_vehicle_category"
    @test data.vehicle_sets[1].departure_location_id == data.vehicle_sets[1].arrival_location_id == "depot"
    @test data.vehicle_sets[1].travel_distance_unit_cost == 1.0
    @test data.vehicle_sets[1].nb_of_vehicles_range == RVRP.Range(0, 0, 15, 15, 0.0, 0.0, 0.0)
    for req_idx in 1:length(data.requests)
        req = data.requests[req_idx]
        @test req.product_quantity_range.hard_min == req.product_quantity_range.soft_min == req.product_quantity_range.hard_max == req.product_quantity_range.soft_max
        @test req.pickup_location_id == data.locations[req_idx+1].id
    end

end
