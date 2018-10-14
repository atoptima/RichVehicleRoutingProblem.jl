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

function ==(v1::RVRP.Vehicle, v2::RVRP.Vehicle)
    return (v1.id == v2.id
            && v1.depot == v2.depot
            && v1.v_type == v2.v_type
            && v1.time_schedule == v2.time_schedule
            && v1.return_to_depot == v2.return_to_depot
            && v1.infinite_copies == v2.infinite_copies
            && v1.initial_load == v2.initial_load
            && v1.picked_shipments == v2.picked_shipments
            )
end

function ==(n1::T, n2::T) where T <: Union{RVRP.Pickup, RVRP.Delivery}
    return (n1.location == n2.location
            && n1.capacity_demand == n2.capacity_demand
            && n1.time_windows == n2.time_windows
            && n1.duration == n2.duration
            && n1.req_id == n2.req_id
            )
end

function ==(s1::RVRP.PickupRequest, s2::RVRP.PickupRequest)
    return (s1.id == s2.id
            && s1.node == s2.node
            )
end

function ==(data1::RVRP.RvrpProblem, data2::RVRP.RvrpProblem)
    return (
        data1.problem_id == data2.problem_id
        && data1.problem_type == data2.problem_type
        && data1.vehicles == data2.vehicles
        && data1.vehicle_types == data2.vehicle_types
        && data1.travel_times_matrix == data2.travel_times_matrix
        && data1.distance_matrix == data2.distance_matrix
        && data1.pickups == data2.pickups
        && data1.deliveries == data2.deliveries
        && data1.operations == data2.operations
        && data1.shipments == data2.shipments
        && data1.picked_shipments == data2.picked_shipments
    )
end
