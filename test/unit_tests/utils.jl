import Base: ==

function ==(data1::RVRP.RvrpProblem, data2::RVRP.RvrpProblem)
    return (
        data1.problem_id == data2.problem_id
        && data1.problem_type == data2.problem_type
        && data1.vehicles == data2.vehicles
        && data1.vehicle_types == data2.vehicle_types
        && data1.travel_times_matrix == data2.travel_times_matrix
        && data1.distance_matrix == data2.distance_matrix
        && data1.services == data2.services
        && data1.shipments == data2.shipments
        && data1.picked_shipments == data2.picked_shipments
    )
end
