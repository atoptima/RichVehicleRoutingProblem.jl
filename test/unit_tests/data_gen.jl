function data_gen_unit_tests()

    generate_symmetric_distance_matrix_tests()
    generate_data_random_tsp_tests()

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
    @test data.services == RVRP.Service[]
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
