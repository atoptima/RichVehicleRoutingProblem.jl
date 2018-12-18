function check_tw_bounds(tws::Vector{Range}, target_time::Float64)
    
    for tw in tws
        if target_time <= tw.ub && target_time >= tw.lb
            return true
        end
    end
    return false

end

function check_sequence(route::Route, data::RvrpInstance,
                        computed_data::RvrpComputedData, solution::RvrpSolution,
                        complete_req_ids::Set{String},
                        ongoing_req_ids::Set{String})

    travel_times = data.travel_specifications[1].travel_time_matrix
    act_idx = 1
    prev_act = route.sequence[1]
    for act in route.sequence
        if act.request_id != "" # Part of a request
            req = data.requests[computed_data.request_id_2_index[act.request_id]]
            if req.request_type == 0
                if act.operation_type == 1
                    if in(req.id, complete_req_ids)
                        error("Request ", req.id, " is performed more than once.")
                    end
                    push!(ongoing_req_ids, req.id)
                elseif act.operation_type == 2
                    if in(req.id, ongoing_req_ids) == false
                        error("Request ", req.id, " is delivered before being picked-up.")
                    end
                    push!(complete_req_ids, req.id)
                end
            else # request_type in [1, 2]
                if in(req.id, complete_req_ids)
                    error("Request ", req.id, " is performed more than once.")
                end
                push!(complete_req_ids, req.id)
            end
            if act.operation_type == 1
                req_tws = [range.soft_range for range in req.pickup_time_windows]
            elseif act.operation_type == 2
                req_tws = [range.soft_range for range in req.delivery_time_windows]
            end
            feas_1 = check_tw_bounds(req_tws, act.scheduled_start_time)
            loc_tws = data.locations[computed_data.location_id_2_index[act.location_id]].opening_time_windows
            feas_2 = check_tw_bounds(loc_tws, act.scheduled_start_time)
            if !feas_1 || !feas_2
                error("Action ", act.id, " of route ", route.id,
                      " does not respect time windows: \n Request tws: ",
                      req_tws, ".\n Location tws: ", loc_tws,
                      ". \n Starts at time ", act.scheduled_start_time, ".")
            end
        end
        if act_idx >= 2
            serv_time = 0.0
            if prev_act.request_id != ""
                prev_req = data.requests[computed_data.request_id_2_index[prev_act.request_id]]
                if prev_act.operation_type == 1
                    serv_time = prev_req.pickup_service_time
                elseif prev_act.operation_type == 2
                    serv_time = prev_req.delivery_service_time
                end
            end
            l_idx_1 = computed_data.location_id_2_index[prev_act.location_id]
            l_idx_2 = computed_data.location_id_2_index[act.location_id]
            if travel_times[l_idx_1,l_idx_2] + serv_time > act.scheduled_start_time - prev_act.scheduled_start_time
                error("The time between start of actions ", act.id, " and ",
                      prev_act.id, " of route ", route.id,
                      " is smaller than the minimum transition time between both.",
                      "\n . Minimum time: ", travel_times[l_idx_1,l_idx_2]
                      + serv_time, ". Time difference: ",
                      act.scheduled_start_time - prev_act.scheduled_start_time, ".")
            end
        end
        prev_act = act
        act_idx += 1
    end
    return true
end

function check_solution(data::RvrpInstance, computed_data::RvrpComputedData,
                        solution::RvrpSolution)

    nb_used_vehicles = Dict{String,Int}(vehicle_set.id => 0 for vehicle_set in data.vehicle_sets)
    complete_req_ids = Set{String}()
    ongoing_req_ids = Set{String}()

    for r in solution.routes
        v_set = data.vehicle_sets[computed_data.vehicle_set_id_2_index[r.vehicle_set_id]]
        nb_used_vehicles[v_set.id] += 1
        if nb_used_vehicles[v_set.id] > v_set.nb_of_vehicles_range.soft_range.ub
            error("Solution infeasible: used ",  nb_used_vehicles[v_set.id],
                  ", vehicles of set <", v_set.id, "> . Maximum is ",
                  v_set.nb_of_vehicles_range.soft_range.ub, ".")
        end

        # Check begin
        departure_locs = data.location_groups[computed_data.location_group_id_2_index[v_set.departure_location_group_id]].location_ids
        arrival_locs = data.location_groups[computed_data.location_group_id_2_index[v_set.arrival_location_group_id]].location_ids
        route_mode = v_set.route_mode
        if (route_mode in [0, 1]) && !(r.sequence[1].location_id in departure_locs)
            error("Solution infeasible: Route ", r.id,
                  " does not respect start and end depot ",
                  "constraints of vehicle set ", v_set.id, ".")
        end

        # Check end
        if r.end_status == 0 && r.sequence[1].location_id != r.sequence[end].location_id
            error("Solution infeasible: Route ", r.id,
                  " does not respect start and end depot ",
                  "constraints of vehicle set ", v_set.id, ".")
        end
        if (route_mode in [0, 2]) && !(r.sequence[1].location_id in arrival_locs)
            error("Solution infeasible: Route ", r.id,
                  " does not respect start and end depot ",
                  "constraints of vehicle set ", v_set.id, ".")
        end

        # Check sequence
        check_sequence(r, data, computed_data, solution,
                       complete_req_ids, ongoing_req_ids)

        # Check route time windows
        total_time = r.sequence[end].scheduled_start_time - r.sequence[1].scheduled_start_time
        if total_time > v_set.max_working_time
            error("Solution infeasible: Route ", r.id,
                  " does not respect max_working_time ",
                  "of vehicle set ", v_set.id, ".")
        end
        if (!check_tw_bounds([v_set.working_time_window.soft_range], r.sequence[1].scheduled_start_time)
            || !check_tw_bounds([v_set.working_time_window.soft_range], r.sequence[end].scheduled_start_time))
            if total_time > v_set.max_working_time
                error("Solution infeasible: Route ", r.id,
                      " does not respect working_time_window ",
                      "of vehicle set ", v_set.id, ".")
            end
        end

    end
    return true
end
