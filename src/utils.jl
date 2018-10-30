function gather_all_locations(data::RvrpInstance)
    all_locations = Set{Location}()
    for d in data.depots
        push!(all_locations, d.location)
    end
    for p in data.pickups
        push!(all_locations, p.location)
    end
    for d in data.deliveries
        push!(all_locations, d.location)
    end
    for s in data.shipments
        push!(all_locations, s.pickup.location)
        push!(all_locations, s.delivery.location)
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
    for depot_idx in 1:length(data.depots)
        data.depots[depot_idx].index = depot_idx
        depot_id_to_idx[data.depots[depot_idx].id] = depot_idx
    end
    for vc_idx in 1:length(data.vehicle_categories)
        data.vehicle_categories[vc_idx].index = vc_idx
    end
    for vs_idx in 1:length(data.vehicle_sets)
        data.vehicle_sets[vs_idx].index = vs_idx
        if data.vehicle_sets[vs_idx].departure_depot_id == ""
            data.vehicle_sets[vs_idx].departure_depot_index = -1
        else
            data.vehicle_sets[vs_idx].departure_depot_index = depot_id_to_idx[data.vehicle_sets[vs_idx].departure_depot_id]
        end
        for arrival_idx in 1:length(data.vehicle_sets[vs_idx].arrival_depot_ids)
            data.vehicle_sets[vs_idx].arrival_depot_indices = Int[]
            push!(data.vehicle_sets[vs_idx].arrival_depot_indices, depot_id_to_idx[data.vehicle_sets[vs_idx].arrival_depot_ids[arrival_idx]])
        end
    end
    for p_idx in 1:length(data.pickups)
        data.pickups[p_idx].index = p_idx
    end
    for d_idx in 1:length(data.deliveries)
        data.deliveries[d_idx].index = d_idx
    end
    for s_idx in 1:length(data.shipments)
        data.shipments[s_idx].index = s_idx
    end
end
