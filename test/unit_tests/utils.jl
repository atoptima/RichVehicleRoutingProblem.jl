import Base: ==

function ==(l1::RVRP.Location, l2::RVRP.Location)
    return (l1.id == l2.id
            && l1.index == l2.index
            && l1.coord.x == l2.coord.x
            && l1.coord.y == l2.coord.y
            )
end

function ==(d1::RVRP.Depot, d2::RVRP.Depot)
    return (d1.location == d2.location
            && d1.time_windows == d2.time_windows
            )
end

function ==(vc1::RVRP.VehicleCategory, vc2::RVRP.VehicleCategory)
    return (vc1.id == vc2.id
            && vc1.index == vc2.index
            && vc1.fixed_cost == vc2.fixed_cost
            && vc1.unit_pricing == vc2.unit_pricing
            && vc1.capacity == vc2.capacity
            )
end

function ==(v1::RVRP.HomogeneousVechicleSet, v2::RVRP.HomogeneousVechicleSet)
    return (v1.id == v2.id
            && v1.index == v2.index
            && v1.departure_depot_index == v2.departure_depot_index
            && v1.arrival_depot_indices == v2.arrival_depot_indices
            && v1.vehicle_category == v2.vehicle_category
            && v1.working_time_window == v2.working_time_window
            && v1.min_nb_of_vehicles == v2.min_nb_of_vehicles
            && v1.max_nb_of_vehicles == v2.max_nb_of_vehicles
            && v1.initial_load == v2.initial_load
            && v1.max_travel_time == v2.max_travel_time
            && v1.max_travel_distance == v2.max_travel_distance
            )
end

function ==(n1::T, n2::T) where T <: Union{RVRP.Pickup, RVRP.Delivery}
    return (n1.id == n2.id
            && n1.index == n2.index
            && n1.location == n2.location
            && n1.capacity_demand == n2.capacity_demand
            && n1.time_windows == n2.time_windows
            && n1.service_time == n2.service_time
            )
end

function ==(s1::RVRP.Shipment, s2::RVRP.Shipment)
    return (s1.id == s2.id
            && s1.index == s2.index
            && s1.pickup == s2.pickup
            && s1.delivery == s2.delivery
            && s1.max_duration == s2.max_duration
            )
end

function ==(data1::RVRP.RvrpProblem, data2::RVRP.RvrpProblem)
    return (
        data1.problem_id == data2.problem_id
        && data1.problem_type == data2.problem_type
        && data1.vehicle_categories == data2.vehicle_categories
        && data1.vehicle_sets == data2.vehicle_sets
        && data1.travel_distance_matrix == data2.travel_distance_matrix
        && data1.travel_time_matrix == data2.travel_time_matrix
        && data1.depots == data2.depots
        && data1.pickups == data2.pickups
        && data1.deliveries == data2.deliveries
        && data1.shipments == data2.shipments
    )
end
