function  mock_solver_unit_tests()

    mock_tests()

end

function mock_tests()

    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    rvrp_sol = RVRP.solve(data, RVRP.MockSolver())
    @test typeof(rvrp_sol) == RVRP.RvrpSolution
    @test rvrp_sol.cost == 644.0

    for act_idx in 1:length(rvrp_sol.routes[4].sequence)
        @test rvrp_sol.routes[4].sequence[act_idx].id == string("act_", act_idx)
    end

    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    data.vehicle_sets[1].nb_of_vehicles_range = RVRP.FlexibleRange(soft_range = RVRP.Range(0, 3))
    rvrp_sol = RVRP.solve(data, RVRP.MockSolver())
    @test rvrp_sol.unassigned_request_ids == ["req_4", "req_5", "req_6", "req_7", "req_8", "req_9", "req_10", "req_11", "req_12", "req_13", "req_14", "req_15"]

    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    data.vehicle_sets = RVRP.HomogeneousVehicleSet[]
    rvrp_sol = RVRP.solve(data, RVRP.MockSolver())
    @test rvrp_sol.routes == RVRP.Route[]
    @test rvrp_sol.unassigned_request_ids == ["req_1", "req_2", "req_3", "req_4", "req_5", "req_6", "req_7", "req_8", "req_9", "req_10", "req_11", "req_12", "req_13", "req_14", "req_15"]

end
