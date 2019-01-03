import Base: ==
 
function ==(r1::RVRP.Range, r2::RVRP.Range)
    return (
        r1.lb == r2.lb
        && r1.ub == r2.ub
    )
end

function ==(f1::RVRP.Flexibility, f2::RVRP.Flexibility)
    return (
        f1.flexibility_level == f2.flexibility_level
        && f1.fixed_price == f2.fixed_price
        && f1.unit_price == f2.unit_price
    )
end

function ==(fr1::RVRP.FlexibleRange, fr2::RVRP.FlexibleRange)
    return (
        fr1.soft_range == fr2.soft_range
        && fr1.hard_range == fr2.hard_range
        && fr1.lb_flex == fr2.lb_flex
        && fr1.ub_flex == fr2.ub_flex
    )
end

function ==(l1::RVRP.Location, l2::RVRP.Location)
    return (
        l1.id == l2.id
        && l1.index == l2.index
        && l1.latitude == l2.latitude
        && l1.longitude == l2.longitude
        && l1.opening_time_windows == l2.opening_time_windows
        && l1.energy_fixed_cost == l2.energy_fixed_cost
        && l1.energy_unit_cost == l2.energy_unit_cost
        && l1.energy_recharging_speeds == l2.energy_recharging_speeds
    )
end

function ==(lg1::RVRP.LocationGroup, lg2::RVRP.LocationGroup)
    return (
        lg1.id == lg2.id
        && lg1.location_ids == lg2.location_ids
    )
end

function ==(pc1::RVRP.ProductCompatibilityClass, pc2::RVRP.ProductCompatibilityClass)
    return (
        pc1.id == pc2.id
        && pc1.conflict_compatib_class_ids == pc2.conflict_compatib_class_ids
        && pc1.prohibited_predecessor_compatib_class_ids == pc2.prohibited_predecessor_compatib_class_ids
    )
end

function ==(pcc1::RVRP.ProductCompatibilityClass, pcc2::RVRP.ProductCompatibilityClass)
    return (
        pcc1.id == pcc2.id
        && pcc1.pickup_availabitilies_at_location_ids == pcc2.pickup_availabitilies_at_location_ids
        && pcc1.delivery_capacities_at_location_ids == pcc2.delivery_capacities_at_location_ids
    )
end

function ==(ps1::RVRP.ProductSpecificationClass, ps2::RVRP.ProductSpecificationClass)
    return (
        sp1.id == sp2.id
        && ps1.capacity_consumptions == ps2.capacity_consumptions
        && ps1.property_requirements == ps2.property_requirements
    )
end

function ==(req1::RVRP.Request, req2::RVRP.Request)
    return (
        req1.id == req2.id
        && req1.product_compatibility_class_id == req2.product_compatibility_class_id
        && req1.product_sharing_class_id == req2.product_sharing_class_id
        && req1.product_specification_class_id == req2.product_specification_class_id
        && req1.split_fulfillment == req2.split_fulfillment
        && req1.request_flexibility == req2.request_flexibility
        && req1.precedence_status == req2.precedence_status
        && req1.product_quantity_range == req2.product_quantity_range
        && req1.pickup_location_group_id == req2.pickup_location_group_id
        && req1.delivery_location_group_id == req2.delivery_location_group_id
        && req1.pickup_service_time == req2.pickup_service_time
        && req1.delivery_service_time == req2.delivery_service_time
        && req1.max_duration == req2.max_duration
        && req1.duration_unit_cost == req2.duration_unit_cost
        && req1.pickup_time_windows == req2.pickup_time_windows
        && req1.delivery_time_windows == req2.delivery_time_windows
    )
end

function ==(vc1::RVRP.VehicleCategory, vc2::RVRP.VehicleCategory)
    return (
        vc1.id == vc2.id
        && vc1.capacity_measures == vc2.capacity_measures
        && vc1.vehicle_properties == vc2.vehicle_properties
        && vc1.loading_option == vc2.loading_option
        && vc1.energy_interval_lengths == vc2.energy_interval_lengths
    )
end

function ==(vc1::RVRP.VehicleCost, vc2::RVRP.VehicleCost)
    return (
        && vc1.work_period == vc2.work_period
        && vc1.travel_distance_unit_cost == vc2.travel_distance_unit_cost
        && vc1.travel_time_unit_cost == vc2.travel_time_unit_cost
        && vc1.service_time_unit_cost == vc2.service_time_unit_cost
        && vc1.waiting_time_unit_cost == vc2.waiting_time_unit_cost
        && vc1.fixed_cost == vc2.fixed_cost
    )
end

function ==(hvs1::RVRP.HomogeneousVehicleSet, hvs2::RVRP.HomogeneousVehicleSet)
    return (
        hvs1.id == hvs2.id
        && hvs1.vehicle_category_id == hvs2.vehicle_category_id
        && hvs1.vehicle_costs == hvs2.vehicle_costs
        && hvs1.work_periods == hvs2.work_periods
        && hvs1.departure_location_group_id == hvs2.departure_location_group_id
        && hvs1.arrival_location_group_id == hvs2.arrival_location_group_id
        && hvs1.initial_energy_charge == hvs2.initial_energy_charge
        && hvs1.max_working_time == hvs2.max_working_time
        && hvs1.max_travel_distance == hvs2.max_travel_distance
        && hvs1.allow_shipment_over_multiple_work_periods == hvs2.allow_shipment_on_multiple_work_periods
        && hvs1.nb_of_vehicles_range == hvs2.nb_of_vehicles_range
    )
end

function ==(data1::RVRP.RvrpInstance, data2::RVRP.RvrpInstance)
    return (
        data1.id == data2.id
        && data1.coordinate_mode == data2.coordinate_mode
        && data1.distance_mode == data2.distance_mode
        && data1.travel_matrix_periods == data2.travel_matrix_periods
        && data1.period_to_matrix_id == data2.period_to_matrix_id
        && data1.travel_time_matrices == data2.travel_time_matrices
        && data1.travel_distance_matrices == data2.travel_distance_matrices
        && data1.energy_consumption_matrices == data2.energy_consumption_matrices
        && data1.locations == data2.locations
        && data1.location_groups == data2.location_groups
        && data1.product_compatibility_classes == data2.product_compatibility_classes
        && data1.product_sharing_classes == data2.product_sharing_classes
        && data1.product_specification_classes == data2.product_specification_classes
        && data1.requests == data2.requests
        && data1.vehicle_categories == data2.vehicle_categories
        && data1.vehicle_sets == data2.vehicle_sets
    )
end
