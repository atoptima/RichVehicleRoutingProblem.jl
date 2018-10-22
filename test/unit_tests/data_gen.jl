function data_gen_unit_tests()

    generate_symmetric_distance_matrix_tests()
    generate_data_random_tsp_tests()
    generate_random_costs_tests()
    generate_random_vehicle_type_tests()
    generate_random_depot_tests()
    generate_random_vehicles_tests()
    generate_random_pickups_tests()
    generate_full_data_tests()

end

function generate_symmetric_distance_matrix_tests()
    matrix = RVRP.generate_symmetric_distance_matrix(5)
    @test size(matrix) == (5,5)
    for i in 1:5
        @test matrix[i,i] == 0.0
        for j in i+1:5
            @test matrix[i,j] == matrix[j,i]
        end
    end
end

function generate_data_random_tsp_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test typeof(data) == RVRP.RvrpProblem
    @test data.problem_id[1:11] == "tsp_random_"
    @test data.problem_type.fleet_size == "FINITE"
    @test data.problem_type.fleet_composition == "HOMOGENEOUS"
    @test data.vehicles == RVRP.Vehicle[]
    @test data.vehicle_types == RVRP.VehicleType[]
    @test data.pickups == RVRP.PickupRequest[]
    @test data.deliveries == RVRP.DeliveryRequest[]
    @test data.operations == RVRP.OperationRequest[]
    @test data.shipments == RVRP.Shipment[]
    @test data.picked_shipments == RVRP.Shipment[]
    @test data.travel_times_matrix == Array{Float64,2}(undef, 0, 0)
    @test size(data.distance_matrix) == (5,5)
    for i in 1:5
        @test data.distance_matrix[i,i] == 0.0
        for j in i+1:5
            @test data.distance_matrix[i,j] == data.distance_matrix[j,i]
        end
    end
end

function generate_random_costs_tests()
    costs = RVRP.generate_random_costs()
    @test typeof(costs) == RVRP.Costs
end

function generate_random_vehicle_type_tests()
    v_types = RVRP.generate_random_vehicle_type(5)
    @test eltype(v_types) == RVRP.VehicleType
    @test length(v_types) == 5
end

function generate_random_depot_tests()
    depot = RVRP.generate_random_depot(3)
    @test typeof(depot) == RVRP.Depot
    @test depot.location.index == 3
    @test depot.location.id == "depot_3"
end

function generate_random_vehicles_tests()
    v_types = RVRP.generate_random_vehicle_type(2)
    depots = [RVRP.generate_random_depot(i+1) for i in 1:2]
    vs = RVRP.generate_random_vehicles(3, v_types, depots)
    @test length(vs) == 3
    @test eltype(vs) == RVRP.Vehicle
    for v in vs
        @test v.depot.location.index >= 2
        @test v.depot.location.index <= 3
    end
end

function generate_random_pickups_tests()
    ps = RVRP.generate_random_pickups(3, 2)
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
    @test length(data.operations) == 0
    @test typeof(data) == RVRP.RvrpProblem
end
