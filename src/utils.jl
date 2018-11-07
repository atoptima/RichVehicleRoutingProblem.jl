function gather_all_locations(data::RvrpInstance)
    all_locations = Set{Location}()
    for d in data.depot_points
        push!(all_locations, d.location)
    end
    for p in data.pickup_points
        push!(all_locations, p.location)
    end
    for d in data.delivery_points
        push!(all_locations, d.location)
    end
    for recharging_p in data.recharging_points
        push!(all_locations, recharging_p.location)
    end
    return all_locations
end

function set_indices(data::RvrpInstance)
    all_locations::Set{Location} = gather_all_locations(data)
    loc_idx = 1
    for l in all_locations
        l.index = loc_idx
        loc_idx += 1
    end
    depot_id_to_idx = Dict{String,Int}()
    for depot_idx in 1:length(data.depot_points)
        data.depot_points[depot_idx].index = depot_idx
        depot_id_to_idx[data.depot_points[depot_idx].id] = depot_idx
    end
    for pc_idx in 1:length(data.product_categories)
        data.product_categories[pc_idx].index = pc_idx
    end
    for product_idx in 1:length(data.products)
        data.products[product_idx].index = product_idx
    end
    for vc_idx in 1:length(data.vehicle_categories)
        data.vehicle_categories[vc_idx].index = vc_idx
    end
    for vs_idx in 1:length(data.vehicle_sets)
        data.vehicle_sets[vs_idx].index = vs_idx
        if data.vehicle_sets[vs_idx].departure_depot_ids == Int[]
            data.vehicle_sets[vs_idx].departure_depot_index = -1
        else
            data.vehicle_sets[vs_idx].departure_depot_index = depot_id_to_idx[data.vehicle_sets[vs_idx].departure_depot_ids[1]]
        end
        for arrival_idx in 1:length(data.vehicle_sets[vs_idx].arrival_depot_ids)
            data.vehicle_sets[vs_idx].arrival_depot_indices = Int[]
            push!(data.vehicle_sets[vs_idx].arrival_depot_indices, depot_id_to_idx[data.vehicle_sets[vs_idx].arrival_depot_ids[arrival_idx]])
        end
    end
    for p_idx in 1:length(data.pickup_points)
        data.pickup_points[p_idx].index = p_idx
    end
    for d_idx in 1:length(data.delivery_points)
        data.delivery_points[d_idx].index = d_idx
    end
    for r_idx in 1:length(data.requests)
        data.requests[r_idx].index = r_idx
    end
    for recharging_p_idx in 1:length(data.recharging_points)
        data.requests[recharging_p_idx].index = recharging_p_idx
    end
end
