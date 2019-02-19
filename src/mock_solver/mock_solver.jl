struct MockSolver end

mutable struct CurentState
    route_idx::Int
    v_set_idx::Int
    v_idx::Int # inside a set idx
    act_idx::Int # inside a route
    t::Float64 # inside a route
    c::Dict{String,Float64} # inside a route
    CurentState() = new(1, 1, 1, 1, 0.0, Dict{String,Float64}())
end

function create_action(cur_state::CurentState, data::RvrpInstance,
                       loc::Location, act_type::Int; req_id = "")
    return Action(string("act_", cur_state.act_idx),
                       loc.id, act_type, req_id, cur_state.t)
end

function init_route(cur_state::CurentState, data::RvrpInstance,
                    computed_data::RvrpComputedData)

    v_cat = get_vehicle_category(data.vehicle_sets[cur_state.v_set_idx],
                                      data, computed_data)
    cur_state.c = Dict{String,Float64}(k => 0.0 for k in keys(v_cat.capacities.of_vehicle))
    cur_state.t = data.vehicle_sets[cur_state.v_set_idx].work_periods[1].soft_range.lb
    loc = get_departure_locations(data.vehicle_sets[cur_state.v_set_idx], data, computed_data)[1]

    act = create_action(cur_state, data, loc, 0)
    return Route(string("r_", cur_state.route_idx), data.vehicle_sets[cur_state.v_set_idx].id, [act], 0)
end

function finalize_route(r::Route, data::RvrpInstance,
                        computed_data::RvrpComputedData,
                        cur_state::CurentState, travel_times::Array{Float64,2})
    depot_loc = get_arrival_locations(data.vehicle_sets[cur_state.v_set_idx],
                                           data, computed_data)[1]
    if !isempty(travel_times)
        prev_location_idx = computed_data.location_id_2_index[r.sequence[end].location_id]
        cur_state.t += travel_times[prev_location_idx,depot_loc.index]
    end
    cur_state.act_idx += 1
    depot_act = create_action(cur_state, data, depot_loc, 0)
    push!(r.sequence, depot_act)

    cur_state.v_idx += 1
    cur_state.route_idx += 1
    cur_state.act_idx = 1
    # Check if need to change v_set_idx every time before initialize the route
    if cur_state.v_idx > data.vehicle_sets[cur_state.v_set_idx].nb_of_vehicles_range.soft_range.ub
        cur_state.v_set_idx += 1
        if cur_state.v_set_idx > length(data.vehicle_sets)
            return false
        end
        cur_state.v_idx = 1
    end
    return true
end

function check_if_feasible(req::Request, cur_state::CurentState,
                           r::Route, data::RvrpInstance,
                           computed_data::RvrpComputedData,
                           travel_times::Array{Float64,2})

    cap_cons = get_capacity_consumptions(req, data.product_specification_classes, computed_data)

    v_cat = get_vehicle_category(data.vehicle_sets[cur_state.v_set_idx],
                                      data, computed_data)
    for (k,v) in v_cat.capacities.of_vehicle
        if cur_state.c[k] + cap_cons[k] > v_cat.capacities.of_vehicle[k]
            return false, -1, cap_cons
        end
    end

    prev_loc_idx = computed_data.location_id_2_index[r.sequence[end].location_id]
    t = cur_state.t
    if req.request_type == 0 || req.request_type == 1
        p_loc_idx = get_pickup_locations(req, data, computed_data)[1].index
        # Time of arrival
        if !isempty(travel_times)
            t += travel_times[prev_loc_idx,p_loc_idx]
        end
        t = max(t, req.pickup_time_windows[1].soft_range.lb)
        if (t > req.pickup_time_windows[1].soft_range.ub ||
            t > data.locations[p_loc_idx].opening_time_windows[1].ub)
            return false, -1, cap_cons
        end
        t += req.pickup_service_time # Leaving time
        prev_loc_idx = p_loc_idx
    end

    if req.request_type == 0 || req.request_type == 2
        d_loc_idx = get_delivery_locations(req, data, computed_data)[1].index
        if !isempty(travel_times)
            t += travel_times[prev_loc_idx,d_loc_idx]
        end
        t = max(t, req.delivery_time_windows[1].soft_range.lb)
        if (t > req.delivery_time_windows[1].soft_range.ub ||
            t > data.locations[d_loc_idx].opening_time_windows[1].ub)
            return false, -1, cap_cons
        end
        t += req.delivery_service_time
        prev_loc_idx = d_loc_idx
    end

    depot_loc_idx = get_arrival_locations(data.vehicle_sets[cur_state.v_set_idx],
                                               data, computed_data)[1].index
    return_to_base_time = 0
    if !isempty(travel_times)
        return_to_base_time = travel_times[prev_loc_idx,depot_loc_idx]
    end
    if t + return_to_base_time > data.vehicle_sets[cur_state.v_set_idx].work_periods[1].soft_range.ub
        return false, -1, cap_cons
    end

    return true, t, cap_cons

end

function check_initial_feasibility(v_sets::Vector{HomogeneousVehicleSet},
                                   nb_reqs::Int)
    nb_vehicles = 0
    for v_set in v_sets
        nb_vehicles += v_set.nb_of_vehicles_range.soft_range.ub
    end
    if nb_vehicles == 0 && nb_reqs > 0
        return false
    else
        return true
    end
end

function build_routes(data::RvrpInstance, solver::MockSolver,
                      computed_data::RvrpComputedData)
    unassigned = String[]
    travel_times = data.travel_specifications[1].travel_time_matrix
    routes = Route[]
    cur_state = CurentState()
    route = init_route(cur_state, data, computed_data)
    req_idx = 1
    while req_idx <= length(data.requests)
        req = data.requests[req_idx]
        feas, t, cap_cons = check_if_feasible(req, cur_state, route, data, computed_data, travel_times)
        if feas
            cur_state.t = t
            if req.request_type != 0
                for k in keys(cap_cons)
                    cur_state.c[k] += cap_cons[k]
                end
            end
            if req.request_type == 0 || req.request_type == 1
                p_loc = get_pickup_locations(req, data, computed_data)[1]
                cur_state.act_idx += 1
                p_act = create_action(cur_state, data, p_loc, 1, req_id = req.id)
                push!(route.sequence, p_act)
            end

            if req.request_type == 0 || req.request_type == 2
                d_loc = get_delivery_locations(req, data, computed_data)[1]
                cur_state.act_idx += 1
                d_act = create_action(cur_state, data, d_loc, 2, req_id = req.id)
                push!(route.sequence, d_act)
            end
            req_idx += 1
        end
        # If not feasible or the last req was just inserted
        if !feas || req_idx == length(data.requests) + 1 
            feas = finalize_route(route, data, computed_data, cur_state, travel_times)
            push!(routes, route)
            if !feas
                unassigned = [req.id for req in data.requests[req_idx:end]]
                break
            end
            if req_idx <= length(data.requests) # If not all requests were done
                route = init_route(cur_state, data, computed_data)
            else
                break
            end
        end
    end
    return routes, unassigned
end

function solve(data::RvrpInstance, solver::MockSolver)

    id = string(data.id, "_mock_SOL_", rand(1:10000))
    if !check_initial_feasibility(data.vehicle_sets, length(data.requests))
        unassigned = [req.id for req in data.requests]
        problem_id = data.id
        sol = RvrpSolution(id, problem_id, -1.0, Route[], unassigned)
        return sol
    end
    computed_data = build_computed_data(data)
    routes, unassigned =  build_routes(data, solver, computed_data)
    problem_id = data.id
    sol = RvrpSolution(id, problem_id, 0.0, routes, unassigned)
    compute_cost_and_scheduled_times(sol, data, computed_data)
    return sol

end

mutable struct SolutionTimes
    current::Float64
    in_service::Float64
    in_travel::Float64
    in_waiting::Float64
    total_distance::Float64
end

function update_times_waiting(solution_times::SolutionTimes,
                              req::Request, act::Action,
                              waiting_time::Float64)
    # Waiting time based on the request
    if act.operation_type == 1
        tws = [_tw.soft_range for _tw in
               req.pickup_time_windows]
    elseif act.operation_type == 2
        tws = [_tw.soft_range for _tw in
               req.delivery_time_windows]
    end
    tw = get_closest_tw(tws, solution_times.current)
    waiting_time = max(0, max(waiting_time, tw.lb - solution_times.current))
    solution_times.in_waiting += waiting_time
    solution_times.current += waiting_time
    # Scheduled start time
    act.scheduled_start_time = solution_times.current
end

function update_times_service(solution_times::SolutionTimes,
                              req::Request, operation_type::Int)
    if operation_type == 1
        service_time = req.pickup_service_time
    elseif operation_type == 2
        service_time = req.delivery_service_time
    end
    solution_times.current += service_time
    solution_times.in_service += service_time
end

function compute_route_cost(solution_times::SolutionTimes,
                           v_set::HomogeneousVehicleSet)
    return (
        + v_set.cost_periods[1].travel_distance_unit_cost * solution_times.total_distance
        + v_set.cost_periods[1].travel_time_unit_cost * solution_times.in_travel
        + v_set.cost_periods[1].service_time_unit_cost * solution_times.in_service
        + v_set.cost_periods[1].waiting_time_unit_cost * solution_times.in_waiting
        + v_set.cost_periods[1].fixed_cost
    )
end

function compute_cost_and_scheduled_times(sol::RvrpSolution,
                                          data::RvrpInstance,
                                          computed_data::RvrpComputedData)

    cost = 0.0
    distances = data.travel_specifications[1].travel_distance_matrix
    times = data.travel_specifications[1].travel_time_matrix
    has_distances = !isempty(distances)
    has_times = !isempty(times)

    for r in sol.routes
        v_set = data.vehicle_sets[computed_data.vehicle_set_id_2_index[r.vehicle_set_id]]
        solution_times = SolutionTimes(v_set.work_periods[1].soft_range.lb,
                                       0.0, 0.0, 0.0, 0.0)
        prev_act = r.sequence[1]

        for act in r.sequence[2:end]

            prev_loc_idx = computed_data.location_id_2_index[prev_act.location_id]
            curr_loc_idx = computed_data.location_id_2_index[act.location_id]

            # Distance
            if has_distances
                solution_times.total_distance += distances[prev_loc_idx,curr_loc_idx]
            end

            # Travel time
            if has_times
                travel_time = times[prev_loc_idx,curr_loc_idx]
                solution_times.current += travel_time
                solution_times.in_travel += travel_time
            end

            # Waiting time based on the location
            tw = get_closest_tw(data.locations[prev_loc_idx].opening_time_windows,
                                solution_times.current)
            waiting_time = max(0, tw.lb - solution_times.current)

            req_id = act.request_id
            # If action is from a request
            if haskey(computed_data.request_id_2_index, req_id)
                req = data.requests[computed_data.request_id_2_index[req_id]]
                update_times_waiting(solution_times, req, act, waiting_time)
                update_times_service(solution_times, req, act.operation_type)
            end

            prev_act = act
        end
        # Update costs
        cost += compute_route_cost(solution_times, v_set)
    end
    sol.cost = cost
end

function supported_features(::Type{MockSolver})
    features = BitSet()

    # Location based features  #
    union!(features, HAS_OPENING_TIME_WINDOWS)

    # Product based features #
    union!(features, HAS_PRODUCT_CAPACITY_CONSUMPTIONS)
    union!(features, HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS)

    # Request based features
    union!(features, HAS_SHIPMENT_REQUESTS)
    union!(features, HAS_PICKUPONLY_REQUESTS)
    union!(features, HAS_DELIVERYONLY_REQUESTS)
    union!(features, HAS_PICKUP_TIME_WINDOWS)
    union!(features, HAS_DELIVERY_TIME_WINDOWS)

    # VehicleCategory based features
    union!(features, HAS_VEHICLE_CAPACITIES)
    union!(features, HAS_MULTIPLE_VEHICLE_CAPACITIES)

    # HomogeneousVehicleSet based features
    union!(features, HAS_TRAVEL_TIME_UNIT_COST)
    union!(features, HAS_SERVICE_TIME_UNIT_COST)
    union!(features, HAS_WAITING_TIME_UNIT_COST)
    union!(features, HAS_TRAVEL_DISTANCE_UNIT_COST)
    union!(features, HAS_MAX_NB_VEHICLES)
    union!(features, HAS_WORKING_TIME_WINDOW)
    union!(features, HAS_FIXED_COST_PER_VEHICLE)
    union!(features, HAS_ARRIVAL_DIFFERENT_FROM_DEPARTURE)

    # Instance based features
    union!(features, HAS_MULTIPLE_VEHICLE_CATEGORIES)
    union!(features, HAS_MULTIPLE_VEHICLE_SETS)

    return [features]
end
