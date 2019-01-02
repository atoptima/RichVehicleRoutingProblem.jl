function check_range_bounds(ranges::Vector{Range}, target_value::Float64)
    
    for range in ranges
        if target_value <= range.ub && target_value >= range.lb
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
    v_set = data.vehicle_sets[computed_data.vehicle_set_id_2_index[route.vehicle_set_id]]
    v_category = data.vehicle_categories[computed_data.vehicle_category_id_2_index[v_set.vehicle_category_id]]
    vehicle_properties = v_category.vehicle_properties.of_vehicle
    vehicle_capacities = v_category.capacity_measures.of_vehicle
    used_capacity = Dict{String,Float64}(
        k => 0.0 for k in keys(vehicle_capacities)
    )
    for act_idx in 1:length(route.sequence)
        act = route.sequence[act_idx]
        if (act.operation_type != 0 && act.request_id == ""
            || act.operation_type == 0 && act.request_id != "")
            error("In action ", act.id, " of route ", route.id,
                  ": operation type (", act.operation_type, ") and reques id (",
                  act.request_id, " are not consistent.")
        end

        if act.operation_type in [1, 2] # Pickup or delivery (has req.id)
            req = data.requests[computed_data.request_id_2_index[act.request_id]]
            product_specification = data.product_specification_classes[computed_data.product_specification_class_id_2_index[req.product_specification_class_id]]
            # Check properties
            for (k,v) in product_specification.property_requirements
                if v < vehicle_properties[k]
                    error("In action ", act.id, " of route ", route.id,
                          ": Uses property (", k, ") that vehicle ",
                          v_set.id, " does not have. Vehicle properties: ",
                          vehicle_properties, ".")
                end
            end
            if in(req.id, complete_req_ids)
                error("Request ", req.id, " is performed more than once.")
            end
            if req.request_type == 0 && act.operation_type == 1
                push!(ongoing_req_ids, req.id)
            elseif req.request_type == 0 && act.operation_type == 2
                if in(req.id, ongoing_req_ids) == false
                    error("Request ", req.id, " is delivered before being picked-up.")
                end
                push!(complete_req_ids, req.id)
            elseif req.request_type in [1, 2]
                if req.request_type != act.operation_type
                    error("Action ", act.id, " has operation type ", act.operation_type,
                          " but is from a request of type ", req.request_type, ".")
                end                    
                push!(complete_req_ids, req.id)
            end
            if act.operation_type == 1
                # Check capacity
                for (k,v) in product_specification.capacity_consumptions
                    used_capacity[k] += (
                        ceil(req.product_quantity_range.ub/v[2]) * v[1]
                    )
                    if used_capacity[k] > vehicle_capacities[k]
                        error("In action ", act.id, " of route ", route.id,
                              ": Consumes ", v, " usint of capacity ", k, ", ",
                              " but vehicle ", v_set.id, " has capacity of ",
                              " only ", vehicle_capacities[k], " units.")
                    end
                end
                req_tws = [range.soft_range for range in req.pickup_time_windows]
            elseif act.operation_type == 2
                # Check capacity
                for (k,v) in product_specification.capacity_consumptions
                    used_capacity[k] -= (
                        ceil(req.product_quantity_range.ub/v[2]) * v[1]
                    )
                    if used_capacity[k] > vehicle_capacities[k]
                        error("In action ", act.id, " of route ", route.id,
                              ": Consumes ", v, " usint of capacity ", k, ", ",
                              " but vehicle ", v_set.id, " has capacity of ",
                              " only ", vehicle_capacities[k], " units.")
                    end
                end
               req_tws = [range.soft_range for range in req.delivery_time_windows]
            end
            feas_1 = check_range_bounds(req_tws, act.scheduled_start_time)
            loc_tws = data.locations[computed_data.location_id_2_index[act.location_id]].opening_time_windows
            feas_2 = check_range_bounds(loc_tws, act.scheduled_start_time)
            if !feas_1 || !feas_2
                error("Action ", act.id, " of route ", route.id,
                      " does not respect time windows: \n Request tws: ",
                      req_tws, ".\n Location tws: ", loc_tws,
                      ". \n Starts at time ", act.scheduled_start_time, ".")
            end
        end
        if act_idx >= 2 && !isempty(travel_times)
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
        if (nb_used_vehicles[v_set.id] > v_set.nb_of_vehicles_range.soft_range.ub
            || nb_used_vehicles[v_set.id] < v_set.nb_of_vehicles_range.soft_range.lb)
            error("Solution infeasible: used ",  nb_used_vehicles[v_set.id],
                  ", vehicles of set <", v_set.id, "> . Maximum is ",
                  v_set.nb_of_vehicles_range.soft_range.ub, ". Minimum is ",
                  v_set.nb_of_vehicles_range.soft_range.lb, ".")
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
        if (!check_range_bounds([v_set.work_periods[1].active_window.soft_range], r.sequence[1].scheduled_start_time)
            || !check_range_bounds([v_set.work_periods[1].active_window.soft_range], r.sequence[end].scheduled_start_time))
            if total_time > v_set.max_working_time
                error("Solution infeasible: Route ", r.id,
                      " does not respect working_time_window ",
                      "of vehicle set ", v_set.id, ".")
            end
        end

    end
    return true
end
