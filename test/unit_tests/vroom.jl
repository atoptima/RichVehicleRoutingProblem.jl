function vroom_cpp_unit_tests()
    c_func_vroom_input_tests()
    c_func_vroom_add_matrix_tests()
    c_func_vroom_add_vehicle_tests()
    c_func_vroom_add_job_tests()
    vroom_add_jobs_tests()
    vroom_add_vehicles_tests()
    vroom_create_input_tests()
    vroom_solve_tests()
    # rvrp_vroom_check_data_tests()
    vroom_transform_solution_tests()
    rvrp_vroom_solve_tests()
    rvrp_vroom_supported_features_tests()
end

function c_func_vroom_input_tests()
    data = Ref{Ptr{Cvoid}}()
    status = RVRP.@vroom_ccall(input, Cint, (Bool, Ref{Ptr{Cvoid}}),
                                      false, data)
    @test status == 0
end

function c_func_vroom_add_matrix_tests()
    data = Ref{Ptr{Cvoid}}()
    RVRP.@vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false data
    mat = fill(0, 5, 5)
    mat_size = 5
    array::Vector{Int32} = reshape(mat, (mat_size*mat_size))
    status = RVRP.@vroom_ccall(add_matrix, Cint, (Ptr{Cvoid}, Cint,
            Ptr{Cint}), data[], Int32(mat_size), array)
    @test status == 0
end

function c_func_vroom_add_vehicle_tests()
    data = Ref{Ptr{Cvoid}}()
    RVRP.@vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false data
    status = RVRP.@vroom_ccall(add_vehicle, Cint, (Ptr{Cvoid}, Cint,
            Cint, Cint, Cint, Bool, Cint, Cint), data[], UInt64(1),
            Int64(5), UInt16(1), UInt16(1), true, UInt32(5), UInt32(10))
    @test status == 0
end

function c_func_vroom_add_job_tests()
    data = Ref{Ptr{Cvoid}}()
    RVRP.@vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false data
    tws::Vector{Int32} = [3, 10]
    twe::Vector{Int32} = [4, 15]
    status = RVRP.@vroom_ccall(add_job, Cint, (Ptr{Cvoid}, Cint, Cint,
            Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}), data[], UInt64(1),
            UInt16(1), UInt32(10), Int64(2), Cint(2), tws, twe)
    @test status == 0
end

# function rvrp_vroom_check_data_tests()
#     data = generate_random_vroom_data(10, 10, false)
#     @test_nowarn RVRP.check_data(data, RVRP.VroomSolver(;with_tw = false))
# end

############################ VROOM interface tests ##################

function vroom_create_input_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    vroom_ptr = RVRP.vroom_create_input(data, computed_data, false)

    #TODO add tests
end


function vroom_add_jobs_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    vroomdata = Ref{Ptr{Cvoid}}()
    RVRP.@vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false vroomdata
    RVRP.vroom_add_jobs(vroomdata[], computed_data, data.requests,
            data.location_groups, data.product_specification_classes)

    #TODO add tests
end

function vroom_add_vehicles_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    vroomdata = Ref{Ptr{Cvoid}}()
    RVRP.@vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false vroomdata
    RVRP.vroom_add_vehicles(vroomdata[], false, computed_data,
            data.vehicle_categories, data.location_groups, data.vehicle_sets)

    #TODO add tests
end

function vroom_solve_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    vroom_ptr = RVRP.vroom_create_input(data, computed_data, false)
    sol = RVRP.vroom_solve(vroom_ptr, 1, 1)
    cost = RVRP.@vroom_ccall get_sol_cost Cint (Ptr{Cvoid},) sol
    service = RVRP.@vroom_ccall get_service Cint (Ptr{Cvoid},) sol
    duration = RVRP.@vroom_ccall get_duration Cint (Ptr{Cvoid},) sol
    wait = RVRP.@vroom_ccall get_waiting_time Cint (Ptr{Cvoid},) sol
    distance = RVRP.@vroom_ccall get_distance Cint (Ptr{Cvoid},) sol
    @test cost == 450
    @test service == 0
    @test duration == 450
    @test wait == 0
    @test distance == 0
end

function vroom_transform_solution_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    computed_data = RVRP.build_computed_data(data)
    vroom_ptr = RVRP.vroom_create_input(data, computed_data, false)
    sol_ptr = RVRP.vroom_solve(vroom_ptr, 1, 1)
    solver = RVRP.VroomSolver(;with_tw = false)
    rvrp_sol = RVRP.vroom_transform_solution(data, solver, computed_data, sol_ptr)
    @test typeof(rvrp_sol) == RVRP.RvrpSolution
    @test rvrp_sol.instance_id == data.id
    @test rvrp_sol.cost == 450
    @test length(rvrp_sol.routes) == 8
    for route in rvrp_sol.routes
        @test (route.sequence[1].operation_type
               == route.sequence[end].operation_type == 0)
    end
    @test length(rvrp_sol.unassigned_request_ids) == 0
end

############################ RVRPSolver tests ################################

function rvrp_vroom_solve_tests()
    data = RVRP.parse_cvrplib(dirname(@__FILE__) *
                              "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    rvrp_sol = RVRP.solve(data, RVRP.VroomSolver(;with_tw = true))
    @test typeof(rvrp_sol) == RVRP.RvrpSolution
    @test rvrp_sol.instance_id == data.id
    @test rvrp_sol.cost == 450
    @test length(rvrp_sol.routes) == 8
    for route in rvrp_sol.routes
        @test (route.sequence[1].operation_type
               == route.sequence[end].operation_type == 0)
    end
    @test length(rvrp_sol.unassigned_request_ids) == 0

    data = RVRP.RvrpInstance()
    rvrp_sol = RVRP.solve(data, RVRP.VroomSolver(;with_tw = true))
    @test rvrp_sol.cost == 0.0
    @test rvrp_sol.routes == RVRP.Route[]
    @test rvrp_sol.unassigned_request_ids == String[]

end

function rvrp_vroom_supported_features_tests()
    features_list = RVRP.supported_features(RVRP.VroomSolver)
    @test RVRP.HAS_PICKUPONLY_REQUESTS in features_list[1]
    @test RVRP.HAS_DELIVERYONLY_REQUESTS in features_list[2]
    non_supported_features = BitSet([RVRP.HAS_PICKUPONLY_REQUESTS,
                                     RVRP.HAS_DELIVERYONLY_REQUESTS])
    @test !(issubset(non_supported_features, features_list[1]))
    @test !(issubset(non_supported_features, features_list[2]))
end
