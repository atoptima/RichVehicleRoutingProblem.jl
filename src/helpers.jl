function get_vehicle_category(v_set::HomogeneousVehicleSet,
                              data::RvrpInstance,
                              computed_data::RvrpComputedData)
    return data.vehicle_categories[
        computed_data.vehicle_category_id_2_index[
            v_set.vehicle_category_id
        ]
    ]
end

function get_locations_from_group_id(group_id::String,
                                     data::RvrpInstance,
                                     computed_data::RvrpComputedData)
    return [
        data.locations[computed_data.location_id_2_index[id]]
        for id in data.location_groups[
            computed_data.location_group_id_2_index[group_id]
        ].location_ids
    ]
end

function get_departure_locations(v_set::HomogeneousVehicleSet,
                                 data::RvrpInstance,
                                 computed_data::RvrpComputedData)
    return get_locations_from_group_id(v_set.departure_location_group_id,
                                       data, computed_data)
end

function get_arrival_locations(v_set::HomogeneousVehicleSet,
                                 data::RvrpInstance,
                                 computed_data::RvrpComputedData)
    return get_locations_from_group_id(v_set.arrival_location_group_id,
                                       data, computed_data)
end

function get_pickup_locations(req::Request,
                              data::RvrpInstance,
                              computed_data::RvrpComputedData)
    return get_locations_from_group_id(req.pickup_location_group_id,
                                       data, computed_data)
end

function get_delivery_locations(req::Request,
                              data::RvrpInstance,
                              computed_data::RvrpComputedData)
    return get_locations_from_group_id(req.delivery_location_group_id,
                                       data, computed_data)
end
