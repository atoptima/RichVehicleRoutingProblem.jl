import JavaCall

function jsprit_java_unit_tests()

    setup_jvm_tests()
    jsprit_build_and_add_locations_tests()
    jsprit_build_vehicle_type_tests()
    jsprit_add_vehicles_tests()
    jsprit_add_jobs_tests()
    jsprit_create_input_tests()
    jsprit_create_algorithm_tests()
    jsprit_search_best_solution_tests()
    jsprit_transform_solution_tests()

    rvrp_jsprit_solve_tests()
    rvrp_jsprit_supported_features_tests()

end

function setup_jvm_tests()
    RVRP.setup_jvm()
    ghcoord = JavaCall.@jimport com.graphhopper.jsprit.core.util.Coordinate
    c = ghcoord((JavaCall.jdouble, JavaCall.jdouble,), 13.0, 124.0)
    x = JavaCall.jcall(c, "getX", JavaCall.jdouble, ())
    @test x == 13.0
end

function jsprit_build_and_add_locations_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    vrp_builder = jsp_types.JVrpBuilder(())
    locs = RVRP.jsprit_build_and_add_locations(data.locations,
                                                      vrp_builder, jsp_types)
    @test eltype(locs) == jsp_types.JLocation
end

function jsprit_build_vehicle_type_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    vrp_builder = jsp_types.JVrpBuilder(())
    jsvt = RVRP.jsprit_build_vehicle_type(data.vehicle_categories,
                                                 data.vehicle_sets[1],
                                                 computed_data, jsp_types)
    @test typeof(jsvt) == jsp_types.JVType
    @test JavaCall.jcall(jsvt, "getTypeId", JavaCall.JString, ()) == data.vehicle_sets[1].id
end

function jsprit_add_vehicles_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    vrp_builder = jsp_types.JVrpBuilder(())
    jsp_locs = RVRP.jsprit_build_and_add_locations(data.locations,
                                                          vrp_builder, jsp_types)
    RVRP.jsprit_add_vehicles(
        data.vehicle_categories, data.vehicle_sets, data.locations,
        data.location_groups, computed_data, vrp_builder, jsp_locs, jsp_types
    )
end

function jsprit_add_jobs_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    vrp_builder = jsp_types.JVrpBuilder(())
    jsp_locs = RVRP.jsprit_build_and_add_locations(data.locations,
                                                          vrp_builder, jsp_types)
    RVRP.jsprit_add_jobs(
        data.requests, data.locations, data.location_groups,
        data.product_specification_classes, computed_data, vrp_builder, jsp_locs,
        jsp_types
    )
end

function jsprit_create_input_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    jsp_vrp = RVRP.jsprit_create_input(data, computed_data,
                                                   jsp_types)
    @test typeof(jsp_vrp) == jsp_types.JVrp
    jsp_jobs = JavaCall.jcall(jsp_vrp, "getJobs", jsp_types.JMap, ())
    n_jobs = JavaCall.jcall(jsp_jobs, "size", JavaCall.jint, ())
    @test n_jobs == 15
end

function jsprit_create_algorithm_tests()
    solver = RVRP.JspritSolver()
    solver.params["iterations"] = "1000"
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    jsp_vrp = RVRP.jsprit_create_input(data, computed_data, jsp_types)
    jsp_algo = RVRP.jsprit_create_algorithm(jsp_vrp, jsp_types, solver)
    @test typeof(jsp_algo) == jsp_types.JAlgorithm
end

function jsprit_search_best_solution_tests()
    solver = RVRP.JspritSolver()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)*
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    jsp_vrp = RVRP.jsprit_create_input(data, computed_data, jsp_types)
    jsp_algo = RVRP.jsprit_create_algorithm(jsp_vrp, jsp_types, solver)
    jsp_sol = RVRP.jsprit_search_best_solution(jsp_algo, jsp_types)
    cost = JavaCall.jcall(jsp_sol, "getCost", JavaCall.jdouble, ())
    @test typeof(jsp_sol) == jsp_types.JSolution
    @test cost == 450
end

function jsprit_transform_solution_tests()
    solver = RVRP.JspritSolver()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    jsp_vrp = RVRP.jsprit_create_input(data, computed_data, jsp_types)
    jsp_algo = RVRP.jsprit_create_algorithm(jsp_vrp, jsp_types, solver)
    jsp_sol = RVRP.jsprit_search_best_solution(jsp_algo, jsp_types)
    rvrp_sol = RVRP.jsprit_transform_solution(data, solver, computed_data,
                                       jsp_sol, jsp_types)
    @test typeof(rvrp_sol) == RVRP.RvrpSolution
    @test rvrp_sol.cost == 450
    @test length(rvrp_sol.routes) == 8
    for r in rvrp_sol.routes
        @test r.sequence[1].location_id == r.sequence[end].location_id
    end
    @test length(rvrp_sol.unassigned_request_ids) == 0

    data.requests[1].product_quantity_range = RVRP.Range(100.0, 100.0)
    computed_data = RVRP.build_computed_data(data)
    jsp_vrp = RVRP.jsprit_create_input(data, computed_data, jsp_types)
    jsp_algo = RVRP.jsprit_create_algorithm(jsp_vrp, jsp_types, solver)
    jsp_sol = RVRP.jsprit_search_best_solution(jsp_algo, jsp_types)
    rvrp_sol = RVRP.jsprit_transform_solution(data, solver, computed_data,
                                       jsp_sol, jsp_types)
    @test rvrp_sol.unassigned_request_ids == ["req_1"]

end

function rvrp_jsprit_solve_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    jsp_types = RVRP.JspritJavaTypes()
    rvrp_sol = RVRP.solve(data, RVRP.JspritSolver())
    @test typeof(rvrp_sol) == RVRP.RvrpSolution
    @test rvrp_sol.cost == 450
    @test length(rvrp_sol.routes) == 8
    for r in rvrp_sol.routes
        @test r.sequence[1].location_id == r.sequence[end].location_id
    end
    @test length(rvrp_sol.unassigned_request_ids) == 0

    # Empty instance
    data = RVRP.RvrpInstance()
    rvrp_sol = RVRP.solve(data, RVRP.JspritSolver())
    @test rvrp_sol.cost == 0.0
    @test rvrp_sol.routes == RVRP.Route[]
    @test rvrp_sol.unassigned_request_ids == String[]
end

function rvrp_jsprit_supported_features_tests()
    features_list = RVRP.supported_features(RVRP.JspritSolver)
    example_features = BitSet([RVRP.HAS_PICKUPONLY_REQUESTS,
                                     RVRP.HAS_DELIVERYONLY_REQUESTS])
    @test (issubset(example_features, features_list[1]))
end
