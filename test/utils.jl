import Base: ==

function ==(l1::RVRP.Location, l2::RVRP.Location)
    return (
        l1.id == l2.id
        && l1.coord.x == l2.coord.x
        && l1.coord.y == l2.coord.y
    )
end

function ==(d1::RVRP.DepotPoint, d2::RVRP.DepotPoint)
    return (
        d1.id == d1.id
        && d1.location == d2.location
        && d1.opening_time_windows == d2.opening_time_windows
        && d1.access_time == d2.access_time
    )
end

function ==(vc1::RVRP.VehicleCategory, vc2::RVRP.VehicleCategory)
    return (
        vc1.id == vc2.id
        && vc1.fixed_cost == vc2.fixed_cost
        && vc1.unit_pricing == vc2.unit_pricing
        && vc1.compartment_capacities == vc2.compartment_capacities
        && vc1.energy_recharges == vc2.energy_recharges
        && vc1.loading_option == vc2.loading_option
        && vc1.prohibited_product_category_ids == vc2.prohibited_product_category_ids
    )
end

function ==(v1::RVRP.HomogeneousVehicleSet, v2::RVRP.HomogeneousVehicleSet)
    return (
        v1.id == v2.id
        && v1.departure_depot_ids == v2.departure_depot_ids
        && v1.arrival_depot_ids == v2.arrival_depot_ids
        && v1.vehicle_category == v2.vehicle_category
        && v1.working_time_window == v2.working_time_window
        && v1.initial_energy_charge == v2.initial_energy_charge
        && v1.min_nb_of_vehicles == v2.min_nb_of_vehicles
        && v1.max_nb_of_vehicles == v2.max_nb_of_vehicles
        && v1.max_working_time == v2.max_working_time
        && v1.max_travel_distance == v2.max_travel_distance
        && v1.allow_ongoing == v2.allow_ongoing
    )
end

function ==(n1::T, n2::T) where T <: Union{RVRP.PickupPoint, RVRP.DeliveryPoint}
    return (
        n1.id == n2.id
        && n1.location == n2.location
        && n1.opening_time_windows == n2.opening_time_windows
        && n1.access_time == n2.access_time
    )
end

function ==(n1::RVRP.RechargingPoint, n2::RVRP.RechargingPoint)
    return (
        n1.id == n2.id
        && n1.location == n2.location
        && n1.opening_time_windows == n2.opening_time_windows
        && n1.energy_recharging_times == n3.energy_recharging_times
        && n1.access_time == n2.access_time
    )
end

function ==(pc1::RVRP.ProductCategory, pc2::RVRP.ProductCategory)
    return (
        pc1.id == pc2.id
        && pc1.conflicting_product_ids == pc2.conflicting_product_ids
        && pc1.prohibited_predecessor_product_ids == pc2.prohibited_predecessor_product_ids
    )
end

function ==(specific_p1::RVRP.SpecificProduct, specific_p2::RVRP.SpecificProduct)
    return (
        specific_p1.id == specific_p2.id
        && specific_p1.product_category_id == specific_p2.product_category_id
        && specific_p1.pickup_availabitilies_at_point_ids == specific_p2.pickup_availabitilies_at_point_ids
        && specific_p1.delivery_capacities_at_point_ids == specific_p2.delivery_capacities_at_point_ids
    )
end

function ==(r1::RVRP.Request, r2::RVRP.Request)
    return (
        r1.id == r2.id
        && r1.product_id == r2.product_id
        && r1.is_optional == r2.is_optional
        && r1.price_reward == r2.price_reward
        && r1.product_quantity == r2.product_quantity
        && r1.compartment_capacity_consumption == r2.compartment_capacity_consumption
        && r1.split_fulfillment == r2.split_fulfillment
        && r1.precedence_restriction == r2.precedence_restriction
        && r1.alternative_pickup_point_ids == r2.alternative_pickup_point_ids
        && r1.alternative_delivery_point_ids == r2.alternative_delivery_point_ids
        && r1.pickup_service_time == r2.pickup_service_time
        && r1.delivery_service_time == r2.delivery_service_time
        && r1.max_duration == r2.max_duration
    )
end

function ==(data1::RVRP.RvrpInstance, data2::RVRP.RvrpInstance)
    return (
        data1.id == data2.id
        && data1.travel_distance_matrix == data2.travel_distance_matrix
        && data1.travel_time_matrix == data2.travel_time_matrix
        && data1.energy_consumption_matrix == data2.energy_consumption_matrix
        && data1.locations == data2.locations
        && data1.pickup_points == data2.pickup_points
        && data1.delivery_points == data2.delivery_points
        && data1.depot_points == data2.depot_points
        && data1.recharging_points == data2.recharging_points
        && data1.product_categories == data2.product_categories
        && data1.products == data2.products
        && data1.requests == data2.requests
        && data1.vehicle_categories == data2.vehicle_categories
        && data1.vehicle_sets == data2.vehicle_sets
    )
end
