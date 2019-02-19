struct VroomSolver
    exploration_level::Int
    nb_threads::Int
    with_tw::Bool
end

function VroomSolver(;exploration_level::Int = 1, nb_threads::Int = 1,
                     with_tw::Bool = false)
    return VroomSolver(exploration_level, nb_threads, with_tw)
end

const VROOM_ERROR_INPUT_INSTANTIATION = 1
const VROOM_ERROR_ADD_MATRIX = 2
const VROOM_ERROR_ADD_VEHICLE = 3
const VROOM_ERROR_ADD_JOB = 4
const VROOM_ERROR_SOLVE = 5

macro vroom_ccall(func, args...)
    args = map(esc,args)
    f = "vroom_$(func)"
    quote
        ccall(($f,$(string(dirname(@__FILE__),"/c_interface/libvroominterface"))), $(args...))
    end
end

abstract type VroomException <: Exception end
struct VroomInputException   <: VroomException end
struct VroomMatrixException  <: VroomException end
struct VroomVehicleException <: VroomException
    vehicle_idx::Int
end
struct VroomJobException     <: VroomException
    job_idx::Int
end
struct VroomSolveException   <: VroomException end

function Base.showerror(io::IO, e::VroomInputException)
    print(io, "Vroom failed to instantiate the input")
end
function Base.showerror(io::IO, e::VroomMatrixException)
    print(io, "Vroom failed to load the matrix in the input")
end
function Base.showerror(io::IO, e::VroomJobException)
    print(io, "Vroom failed to load the job $(e.job_idx) in the input")
end
function Base.showerror(io::IO, e::VroomVehicleException)
    print(io, "Vroom failed to load the vehicle $(e.vehicle_idx) in the input")
end
function Base.showerror(io::IO, e::VroomSolveException)
    print(io, "Vroom failed to solve the input")
end

########################################################
############## vroom interface functions ###############
########################################################
function vroom_create_input(data::RvrpInstance,
                            computed_data::RvrpComputedData, with_tw::Bool)

    vroomdata = Ref{Ptr{Cvoid}}()
    status = @vroom_ccall input Cint (Bool, Ref{Ptr{Cvoid}},) false vroomdata
    if status == VROOM_ERROR_INPUT_INSTANTIATION
        throw(VroomInputException())
    end
    @assert status == 0

    # only one matrix is supported
    # k = collect(keys(data.travel_distance_matrices))
    # mat = data.travel_distance_matrices[k[1]]
    mat = data.travel_specifications[1].travel_distance_matrix    
    # Distance matrix: vroom does not support floats
    mat_size = size(mat, 1)
    array::Vector{Int32} = reshape(mat, (mat_size*mat_size))
    @vroom_ccall add_matrix Cvoid (Ptr{Cvoid}, Cint, Ptr{Cint},
                 ) vroomdata[] Int32(mat_size) array

    vroom_add_jobs(vroomdata[], computed_data, data.requests, data.location_groups,
             data.product_specification_classes)
    vroom_add_vehicles(vroomdata[], with_tw, computed_data, data.vehicle_categories,
                 data.location_groups, data.vehicle_sets)
    return vroomdata[]
end

function vroom_add_jobs(data_ptr::Ptr{Cvoid},
                  computed_data::RvrpComputedData,
                  requests::Vector{Request},
                  lgs::Vector{LocationGroup},
                  product_specification_classes::Vector{ProductSpecificationClass})
    for r_idx in 1:length(requests)
        req = requests[r_idx]
        nb_tw = length(req.pickup_time_windows)
        tw_starts::Vector{Cint} = [
            req.pickup_time_windows[i].soft_range.lb for i in 1:nb_tw
        ]
        tw_ends::Vector{Cint} = [
            req.pickup_time_windows[i].soft_range.ub for i in 1:nb_tw
        ]
        lg_idx = computed_data.location_group_id_2_index[req.pickup_location_group_id]
        l_idx = computed_data.location_id_2_index[lgs[lg_idx].location_ids[1]]
        d = req.pickup_service_time
        c = get_capacity_consumptions(req, product_specification_classes,
                                           computed_data)

        status = @vroom_ccall(add_job, Cint, (Ptr{Cvoid}, Cint, Cint, Cint,
                Cint, Cint, Ptr{Cint}, Ptr{Cint}), data_ptr, UInt64(r_idx-1),
                UInt16(l_idx-1), UInt32(d), Int64(first(c)[2]), nb_tw,
                tw_starts, tw_ends)
        if status == VROOM_ERROR_ADD_JOB
            throw(VroomJobException(r_idx))
        end
        @assert status == 0
    end
end

function vroom_add_vehicles(data_ptr::Ptr{Cvoid}, with_tw::Bool,
                      computed_data::RvrpComputedData,
                      categories::Vector{VehicleCategory},
                      lgs::Vector{LocationGroup},
                      vehicle_sets::Vector{HomogeneousVehicleSet})
    v_idx = 1
    for v_set in vehicle_sets
        cat_idx = computed_data.vehicle_category_id_2_index[v_set.vehicle_category_id]
        caps = [v for (k,v) in categories[cat_idx].capacities.of_vehicle]

        lg_idx = computed_data.location_group_id_2_index[v_set.departure_location_group_id]
        s_idx = computed_data.location_id_2_index[lgs[lg_idx].location_ids[1]]
        lg_idx = computed_data.location_group_id_2_index[v_set.arrival_location_group_id]
        e_idx = computed_data.location_id_2_index[lgs[lg_idx].location_ids[1]]

        tws = v_set.work_periods[1].soft_range.lb
        twe = v_set.work_periods[1].soft_range.ub
        for i in 1:v_set.nb_of_vehicles_range.soft_range.ub
            status = @vroom_ccall(add_vehicle, Cint, (Ptr{Cvoid}, Cint, Cint,
                    Cint, Cint, Bool, Cint, Cint), data_ptr, UInt64(v_idx-1),
                    Int64(caps[1]), UInt16(s_idx-1), UInt16(e_idx-1), with_tw,
                    UInt32(tws), UInt32(twe))
            if status == VROOM_ERROR_ADD_VEHICLE
                throw(VroomVehicleException(v_idx))
            end
            @assert status == 0
            v_idx += 1
        end
    end
end

function vroom_solve(vroom_input::Ptr{Cvoid}, exploration_level::Int,
                     nb_thread::Int)
    sol = Ref{Ptr{Cvoid}}()
    status = @vroom_ccall(solve, Cint, (Ptr{Cvoid}, Cint, Cint, Ref{Ptr{Cvoid}}),
            vroom_input, Cint(exploration_level), Cint(nb_thread), sol)
    if status == VROOM_ERROR_SOLVE
        throw(VroomSolveException())
    end
    @assert status == 0

    return sol[]
end

function vroom_build_routes(data::RvrpInstance, solver::VroomSolver,
                      computed_data::RvrpComputedData,
                      sol_ptr::Ptr{Cvoid})
    vehicle_index_to_set_index = Dict{Int,Int}()
    vroom_idx = 0 # vehicle index in vroom
    for v_set_idx in 1:length(data.vehicle_sets)
        for i in 1:data.vehicle_sets[v_set_idx].nb_of_vehicles_range.soft_range.ub
            vehicle_index_to_set_index[vroom_idx] = v_set_idx
            vroom_idx += 1
        end
    end
    routes = Route[]
    nb_routes = @vroom_ccall get_nb_routes Cint (Ptr{Cvoid},) sol_ptr
    for r_idx in 1:nb_routes
        r_id = string("route_", r_idx)
        vroom_v_idx = @vroom_ccall get_route_vehicle_id Cint (Ptr{Cvoid}, Cint, ) sol_ptr Cint(r_idx-1)
        v_set_idx = vehicle_index_to_set_index[vroom_v_idx]
        nb_actions = @vroom_ccall get_route_nb_actions Cint (Ptr{Cvoid}, Cint, ) sol_ptr Cint(r_idx-1)
        sequence = Action[]
        for action_idx in 1:nb_actions
            if action_idx == 1 || action_idx == nb_actions
                req_id = ""; action_type = 0
                loc_id = data.location_groups[computed_data.location_group_id_2_index[data.vehicle_sets[v_set_idx].departure_location_group_id]].location_ids[1]
            else
                vroom_job_idx = @vroom_ccall get_step_job_id Cint (Ptr{Cvoid}, Cint, Cint,) sol_ptr Cint(r_idx-1) Cint(action_idx-1)
                req_id = data.requests[vroom_job_idx+1].id; action_type = 1
                loc_id = data.location_groups[computed_data.location_group_id_2_index[data.requests[vroom_job_idx+1].pickup_location_group_id]].location_ids[1]
            end
            scheduled_start_time = @vroom_ccall get_step_arrival Cint (Ptr{Cvoid}, Cint, Cint,) sol_ptr Cint(r_idx-1) Cint(action_idx-1)
            push!(sequence, Action(string("action_", action_idx), loc_id,
                                        action_type, req_id,
                                        scheduled_start_time))
        end
        push!(routes, Route(
            r_id, data.vehicle_sets[v_set_idx].id, sequence, 0
        ))
    end
    return routes
end

function vroom_transform_solution(data::RvrpInstance,
        solver::VroomSolver,computed_data::RvrpComputedData,
        sol_ptr::Ptr{Cvoid})

    id = string(data.id, "_RVRPSOL_", rand(1:1000))
    problem_id = data.id
    cost = @vroom_ccall get_sol_cost Cint (Ptr{Cvoid},) sol_ptr
    routes = vroom_build_routes(data, solver, computed_data, sol_ptr)
    unassigned = String[]
    nb_unassigned = @vroom_ccall get_nb_unassigned Cint (Ptr{Cvoid},) sol_ptr
    for i in 1:nb_unassigned
        vroom_idx = @vroom_ccall get_unassigned_job_id Cint (Ptr{Cvoid}, Cint,) sol_ptr Cint(i-1)
        unassigned_id = data.requests[vroom_idx+1].id
        push!(unassigned, unassigned_id)
    end
    return RvrpSolution(id, problem_id, cost, routes, unassigned)
end


########################################################
############## RvrpSolver functions ####################
########################################################

function solve(data::RvrpInstance, solver::VroomSolver)
    computed_data = build_computed_data(data)
    # check_data(data, solver)
    vroom_ptr = vroom_create_input(data, computed_data, solver.with_tw)
    sol_ptr = vroom_solve(vroom_ptr, solver.exploration_level,
                          solver.nb_threads)
    return vroom_transform_solution(data, solver, computed_data, sol_ptr)
end

function supported_features(::Type{VroomSolver})
    pickonly_features = BitSet()

    # Request based features
    union!(pickonly_features, HAS_PICKUPONLY_REQUESTS)
    union!(pickonly_features, HAS_MAX_DURATION)
    union!(pickonly_features, HAS_PICKUP_TIME_WINDOWS)
    union!(pickonly_features, HAS_MULTIPLE_PICKUP_TIME_WINDOWS)

    # VehicleCategory based features
    union!(pickonly_features, HAS_VEHICLE_CAPACITIES)
    union!(pickonly_features, HAS_VEHICLE_PROPERTIES)
    union!(pickonly_features, HAS_MULTIPLE_VEHICLE_PROPERTIES)

    # HomogeneousVehicleSet based features
    union!(pickonly_features, HAS_MAX_NB_VEHICLES)
    union!(pickonly_features, HAS_WORKING_TIME_WINDOW)
    union!(pickonly_features, HAS_TRAVEL_DISTANCE_UNIT_COST)
    union!(pickonly_features, HAS_ARRIVAL_DIFFERENT_FROM_DEPARTURE)

    # Instance based features
    union!(pickonly_features, HAS_MULTIPLE_VEHICLE_CATEGORIES)
    union!(pickonly_features, HAS_MULTIPLE_VEHICLE_SETS)

    #TODO support these features with a transformation
    deliveronly_features = BitSet()

    # Request based features
    union!(deliveronly_features, HAS_DELIVERYONLY_REQUESTS)
    union!(deliveronly_features, HAS_MAX_DURATION)
    union!(deliveronly_features, HAS_DELIVERY_TIME_WINDOWS)
    union!(deliveronly_features, HAS_MULTIPLE_DELIVERY_TIME_WINDOWS)

    # VehicleCategory based features
    union!(deliveronly_features, HAS_VEHICLE_CAPACITIES)
    union!(deliveronly_features, HAS_VEHICLE_PROPERTIES)
    union!(deliveronly_features, HAS_MULTIPLE_VEHICLE_PROPERTIES)

    # HomogeneousVehicleSet based features
    union!(deliveronly_features, HAS_MAX_NB_VEHICLES)
    union!(deliveronly_features, HAS_WORKING_TIME_WINDOW)
    union!(deliveronly_features, HAS_TRAVEL_DISTANCE_UNIT_COST)
    union!(deliveronly_features, HAS_ARRIVAL_DIFFERENT_FROM_DEPARTURE)

    # Instance based features
    union!(deliveronly_features, HAS_MULTIPLE_VEHICLE_CATEGORIES)
    union!(deliveronly_features, HAS_MULTIPLE_VEHICLE_SETS)

    return [pickonly_features, deliveronly_features]
end
