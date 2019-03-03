####################### RVRP FEATURES #############################

# Location based features  #
const HAS_OPENING_TIME_WINDOWS = 1
const HAS_MULTIPLE_OPENING_TIME_WINDOWS = 2
const HAS_FLEXIBLE_OPENING_TIME_WINDOWS = 3

# Product based features #
const HAS_PRODUCT_CONFLICT_CLASSES = 4
const HAS_PRODUCT_PROHIBITED_PREDECESSOR_CLASSES = 5
const HAS_PRODUCT_PICKUPONLY_SHARING_CLASSES = 6
const HAS_PRODUCT_DELIVERYONLY_SHARING_CLASSES = 7
const HAS_PRODUCT_SHIPMENT_SHARING_CLASSES = 8
const HAS_PRODUCT_CAPACITY_CONSUMPTIONS = 9
const HAS_PRODUCT_PROPERTIES_REQUIREMENTS = 10
const HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS = 11
const HAS_MULTIPLE_PRODUCT_PROPERTIES_REQUIREMENTS = 12

# Request based features
const HAS_SHIPMENT_REQUESTS = 109
const HAS_PICKUPONLY_REQUESTS = 110
const HAS_DELIVERYONLY_REQUESTS = 111
const HAS_ALTERNATIVE_PICKUP_LOCATIONS = 112 #
const HAS_ALTERNATIVE_DELIVERY_LOCATIONS = 113 #
const HAS_MAX_DURATION = 114
const HAS_DURATION_UNIT_COSTS = 115 #
const HAS_PICKUP_TIME_WINDOWS = 116
const HAS_DELIVERY_TIME_WINDOWS = 117
const HAS_MULTIPLE_PICKUP_TIME_WINDOWS = 118
const HAS_MULTIPLE_DELIVERY_TIME_WINDOWS = 119
const HAS_FLEXIBLE_PICKUP_TIME_WINDOWS = 120 #
const HAS_FLEXIBLE_DELIVERY_TIME_WINDOWS = 121 #
const HAS_FLEXIBLE_REQUESTS = 122 #

# VehicleCategory based features
const HAS_VEHICLE_CAPACITIES = 224
const HAS_VEHICLE_PROPERTIES = 225
const HAS_COMPARTMENT_CAPACITIES = 226 #
const HAS_COMPARTMENT_PROPERTIES = 227 #
const HAS_MULTIPLE_VEHICLE_CAPACITIES = 228
const HAS_MULTIPLE_VEHICLE_PROPERTIES = 229
const HAS_MULTIPLE_COMPARTMENT_CAPACITIES = 230 #
const HAS_MULTIPLE_COMPARTMENT_PROPERTIES = 231 #

# HomogeneousVehicleSet based features
const HAS_TRAVEL_TIME_UNIT_COST = 333
const HAS_SERVICE_TIME_UNIT_COST = 334
const HAS_WAITING_TIME_UNIT_COST = 335
const HAS_TRAVEL_DISTANCE_UNIT_COST = 339
const HAS_MAX_WORKING_TIME = 337 #
const HAS_MAX_TRAVEL_DISTANCE = 338 #
const HAS_MIN_NB_VEHICLES = 340 #
const HAS_MAX_NB_VEHICLES = 341
const HAS_FLEXIBLE_NB_VEHICLES_RANGE = 342 #
const HAS_WORKING_TIME_WINDOW = 343
const HAS_FLEXIBLE_WORKING_TIME_WINDOWS = 345 #
const HAS_FIXED_COST_PER_VEHICLE = 346
const HAS_OPEN_DEPARTURE = 347
const HAS_OPEN_ARRIVAL = 348
const HAS_ARRIVAL_DIFFERENT_FROM_DEPARTURE = 349
const HAS_ALTERNATIVE_DEPARTURE_LOCATIONS = 350 #
const HAS_ALTERNATIVE_ARRIVAL_LOCATIONS = 351 #
const HAS_MULTIPLE_WORKING_TIME_WINDOWS = 352 #
const HAS_MULTIPLE_COSTS = 353 #

# Instance based features
const HAS_WORK_PERIODS = 447 # TO BE REMOVED
const HAS_MUTLIPLE_TRAVEL_TIME_PERIODS = 448
# const HAS_VEHICLE_CATEGORIES = 449 (not needed, duplicate of caps props)
const HAS_MULTIPLE_VEHICLE_CATEGORIES = 450
const HAS_MULTIPLE_VEHICLE_SETS = 451
const HAS_ENERGY_FEATURES = 452 # to be detailed later as needed #
const HAS_X_Y = 453

function check_if_supports(supported_vec::Vector{BitSet},
                           instance_features::BitSet)
    for supported in supported_vec
        if issubset(instance_features, supported)
            return true
        end
    end
    return false
end

function check_id(id_to_index_dict, key, error_prefix::String)
    if !haskey(id_to_index_dict, key)
        error(error_prefix, "There is no object with id $key")
    end
end

function check_positive_range(range::Range, error_prefix::String)
    if range.lb < 0.0
        error(error_prefix, "lb must be >= 0")
    elseif range.ub < 0.0
        error(error_prefix, "lb must be >= 0")
    elseif range.ub < range.lb
        error(error_prefix, "lb must be less or equal ub")
    end
end

function check_time_windows(tws::Vector{Range}, error_prefix::String)
    check_positive_range(tws[1], "Time window ")
    for idx in 2:length(tws)
        check_positive_range(tws[idx], "Time window ")
        if (tws[idx-1].lb > tws[idx].lb || tws[idx-1].ub > tws[idx].ub
            || tws[idx-1].ub > tws[idx].lb)
            error(error_prefix, "must not intersect and must be increasing: ", tws)
        end
    end
end

function check_locations(locations::Vector{Location},
                         computed_data::RvrpComputedData,
                         coordinate_mode::Int, features::BitSet)

    for loc in locations
        # If in long_lat mode
        if coordinate_mode == 0
            if loc.lat_y < - 90.0 || loc.lat_y > 90.0
                error("Location $(loc.id) must have lat_y in [-90.0, +90.0]")
            elseif loc.long_x < - 180.0 || loc.long_x > 180.0
                error("Location $(loc.id) must have long_x in [-180.0, +180.0]")
            end
        end
        if loc.index < 1 || loc.index > length(locations)
            error("Location $(loc.id) must have index in [1, length(locations)]")
        end
        check_time_windows(loc.opening_time_windows,
                           string("Time windows of location ", loc.id, " "))
    end

    # filling LOCATION based features
    for loc in locations
        if loc.opening_time_windows != [Range()]
            union!(features, HAS_OPENING_TIME_WINDOWS)
        end
        if length(loc.opening_time_windows) > 1
            union!(features, HAS_MULTIPLE_OPENING_TIME_WINDOWS)
        end
    end

end

function check_location_groups(location_groups::Vector{LocationGroup},
                               computed_data::RvrpComputedData)

    for grp in location_groups
        for loc_id in grp.location_ids
            check_id(computed_data.location_id_2_index, loc_id,
                     "LocationGroup $(grp.id), location_ids : ")
        end
    end
end

function check_requests(requests::Vector{Request},
                        computed_data::RvrpComputedData)

    for req in requests
        if req.request_type in [0, 1]
            check_id(computed_data.location_group_id_2_index,
                     req.pickup_location_group_id,
                     "Request $(req.id), pickup_location_group_id : ")
        elseif req.request_type in [0, 2]
            check_id(computed_data.location_group_id_2_index,
                     req.delivery_location_group_id,
                     "Request $(req.id), delivery_location_group_id : ")
        end
        check_positive_range(req.product_quantity_range,
                 "Request $(req.id), product_quantity_range : ")
        check_positive_range(req.pickup_time_windows[1].soft_range,
                 "Request $(req.id), pickup_time_windows[1].soft_range : ")
        check_positive_range(req.delivery_time_windows[1].soft_range,
                 "Request $(req.id), delivery_time_windows[1].soft_range : ")
        if req.precedence_status < 0 || req.precedence_status > 2
            error("Request $(req.id) must have precedence_status in {0,1,2}")
        elseif req.pickup_service_time < 0
            error("Request $(req.id) must have pickup_service_time > 0")
        elseif req.delivery_service_time < 0
            error("Request $(req.id) must have delivery_service_time > 0")
        elseif req.max_duration < 0
            error("Request $(req.id) must have max_duration > 0")
        elseif req.duration_unit_cost < 0
            error("Request $(req.id) must have duration_unit_cost > 0")
        end
        check_time_windows([tw.soft_range for tw in req.pickup_time_windows],
            string("Time windows of pickup of request ", req.id, " "))
        check_time_windows([tw.soft_range for tw in req.delivery_time_windows],
            string("Time windows of delivery of request ", req.id, " "))

        # filling REQUEST based features
        features = computed_data.features
        if req.request_type == 0
            union!(features, HAS_SHIPMENT_REQUESTS)
        elseif req.request_type == 1
            union!(features, HAS_PICKUPONLY_REQUESTS)
        elseif req.request_type == 0
            union!(features, HAS_DELIVERYONLY_REQUESTS)
        end
        if req.max_duration < MAXNUMBER
            union!(features, HAS_MAX_DURATION)
        end
        if req.pickup_time_windows[1].soft_range.lb > 0 ||
           req.pickup_time_windows[1].soft_range.ub < MAXNUMBER
            union!(features, HAS_PICKUP_TIME_WINDOWS)
        end
        if req.delivery_time_windows[1].soft_range.lb > 0 ||
           req.delivery_time_windows[1].soft_range.ub < MAXNUMBER
            union!(features, HAS_DELIVERY_TIME_WINDOWS)
        end
    end
end

function check_vehicle_categories(vehicle_categories::Vector{VehicleCategory},
                                  computed_data::RvrpComputedData)

    for vc in vehicle_categories
        if vc.loading_option < 0 || vc.loading_option > 2
            error("VehicleCategory $(vc.id) must have loading_option in",
                  "{0,1,2}")
        end

        # filling VehicleCategory based features
        features = computed_data.features
        if length(vc.capacities.of_vehicle) > 0
            union!(features, HAS_VEHICLE_CAPACITIES)
        end
        if length(vc.capacities.of_compartments) > 0
            union!(features, HAS_COMPARTMENT_CAPACITIES)
        end
        if length(vc.properties.of_vehicle) > 0
            union!(features, HAS_VEHICLE_PROPERTIES)
        end
        if length(vc.properties.of_compartments) > 0
            union!(features, HAS_COMPARTMENT_PROPERTIES)
        end
        if length(vc.capacities.of_vehicle) > 1
            union!(features, HAS_MULTIPLE_VEHICLE_CAPACITIES)
        end
        if length(vc.capacities.of_compartments) > 1
            union!(features, HAS_MULTIPLE_COMPARTMENT_CAPACITIES)
        end
        if length(vc.properties.of_vehicle) > 1
            union!(features, HAS_MULTIPLE_VEHICLE_PROPERTIES)
        end
        if length(vc.properties.of_compartments) > 1
            union!(features, HAS_MULTIPLE_COMPARTMENT_PROPERTIES)
        end
    end
end

function check_vehicle_cost(vs_id::String, cost_period::CostPeriod,
                            computed_data::RvrpComputedData)
    check_positive_range(cost_period.period,
        "VehicleSet $(vs_id), cost_period.period : ")
    if cost_period.travel_time_unit_cost < 0
        error("VehicleSet $(vs_id) must have all travel_time_unit_cost > 0")
    elseif cost_period.service_time_unit_cost < 0
        error("VehicleSet $(vs_id) must have all service_time_unit_cost > 0")
    elseif cost_period.waiting_time_unit_cost < 0
        error("VehicleSet $(vs_id) must have all waiting_time_unit_cost > 0")
    elseif cost_period.fixed_cost < 0
        error("VehicleSet $(vs_id) must have all fixed_cost > 0")
    end

    # filling CostPeriod based features
    features = computed_data.features
    if cost_period.travel_time_unit_cost > 0
        union!(features, HAS_TRAVEL_TIME_UNIT_COST)
    end
    if cost_period.service_time_unit_cost > 0
        union!(features, HAS_SERVICE_TIME_UNIT_COST)
    end
    if cost_period.waiting_time_unit_cost > 0
        union!(features, HAS_WAITING_TIME_UNIT_COST)
    end
    if cost_period.travel_distance_unit_cost > 0
        union!(features, HAS_TRAVEL_DISTANCE_UNIT_COST)
    end
    if cost_period.fixed_cost > 0
        union!(features, HAS_FIXED_COST_PER_VEHICLE)
    end
end

function check_vehicle_sets(vehicle_sets::Vector{HomogeneousVehicleSet},
                            computed_data::RvrpComputedData)

    for vs in vehicle_sets
        check_id(computed_data.vehicle_category_id_2_index,
                 vs.vehicle_category_id,
                 "VehicleSet $(vs.id), vehicle_category_id : ")
        check_id(computed_data.location_group_id_2_index,
                 vs.departure_location_group_id,
                 "VehicleSet $(vs.id), departure_location_group_id : ")
        check_id(computed_data.location_group_id_2_index,
                 vs.arrival_location_group_id,
                 "VehicleSet $(vs.id), arrival_location_group_id : ")
        check_positive_range(vs.nb_of_vehicles_range.soft_range,
                 "VehicleSet $(vs.id), nb_of_vehicles_range.soft_range : ")
        check_time_windows([tw.soft_range for tw in vs.work_periods],
            string("Work periods of HomogeneousVehicleSet ", vs.id, " "))
        for wp in vs.work_periods
            check_positive_range(wp.soft_range,
                "VehicleSet $(vs.id), work_period.soft_range : ")
        end
        for cost_period in vs.cost_periods
            check_vehicle_cost(vs.id, cost_period, computed_data)
        end

        # filling HomogeneousVehicleSet based features
        features = computed_data.features
        if vs.route_mode in [1,3]
            union!(features, HAS_OPEN_ARRIVAL)
        end
        if vs.route_mode in [1,3]
            union!(features, HAS_OPEN_DEPARTURE)
        end
        if vs.nb_of_vehicles_range.soft_range.ub < MAXNUMBER
            union!(features, HAS_MAX_NB_VEHICLES)
        end
        if length(vs.work_periods) > 1
            union!(features, HAS_MULTIPLE_WORKING_TIME_WINDOWS)
        end
        if length(vs.cost_periods) > 1
            union!(features, HAS_MULTIPLE_COSTS)
        end
        if vs.vehicle_category_id == "default_id"
            computed_data.uses_default_vehicle_category = true
        end
        for wp in vs.work_periods
            if wp.soft_range.lb > 0 ||
                wp.soft_range.ub < MAXNUMBER
                union!(features, HAS_WORKING_TIME_WINDOW)
            end
        end
    end
end

function check_product_specification_classes(
    product_specification_classes::Vector{ProductSpecificationClass},
    computed_data::RvrpComputedData)

    features = computed_data.features

    for prod_spec_class in product_specification_classes
        for (k,v) in prod_spec_class.capacity_consumptions
            if v[1] < 0.0 || v[2] < 0.0
                error("Product ", prod_spec_class.id,
                      " must have a non-negative consumption of all ",
                      "of all capacity measures.",
                      " Consumption is ", v[1], " per lot of ", v[2])
            end
        end
        for (k,v) in prod_spec_class.property_requirements
            if v < 0.0
                error("Product ", prod_spec_class.id,
                      " must have a non-negative requirement for all properties.",
                      " Requirement is ", v[1])
            end
        end
    end

    nb_capacities_specificartions = 0
    nb_properties_requirements = 0
    for prod_spec_class in product_specification_classes
        if !isempty(prod_spec_class.capacity_consumptions)
            union!(features, HAS_PRODUCT_CAPACITY_CONSUMPTIONS)
            nb_capacities_specificartions += 1
        end
        if !isempty(prod_spec_class.property_requirements)
            union!(features, HAS_PRODUCT_PROPERTIES_REQUIREMENTS)
            nb_properties_requirements += 1
        end
    end
    if nb_capacities_specificartions > 1
        union!(features, HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS)
    end
    if nb_properties_requirements > 1
        union!(features, HAS_MULTIPLE_PRODUCT_PROPERTIES_REQUIREMENTS)
    end

end

function check_ids_in_vector(vec::Vector{T}) where T <: Union{
    Location, TravelSpecification, LocationGroup,
    ProductSharingClass, ProductSpecificationClass,
    ProductCompatibilityClass, Request, VehicleCategory,
    HomogeneousVehicleSet}
    all_ids = Set{String}()
    for obj in vec
        if obj.id in all_ids
            error("Id ", obj.id, " is used more that ",
                  "once in vector of ", Symbol(eltype(vec)))
        end
        push!(all_ids, obj.id)
    end
end

function check_repeated_ids(data::RvrpInstance)

    check_ids_in_vector(data.locations)
    check_ids_in_vector(data.travel_specifications)
    check_ids_in_vector(data.location_groups)
    check_ids_in_vector(data.product_compatibility_classes)
    check_ids_in_vector(data.product_specification_classes)
    check_ids_in_vector(data.product_sharing_classes)
    check_ids_in_vector(data.requests)
    check_ids_in_vector(data.vehicle_categories)
    check_ids_in_vector(data.vehicle_sets)

end

function check_instance(data::RvrpInstance, computed_data::RvrpComputedData)

    if data.id == ""
        error("Invalid instance id: ", data.id)
    end
    check_repeated_ids(data)

    tt_period = data.travel_periods[1]
    check_id(computed_data.travel_specification_id_2_index,
             tt_period.travel_specification_id,
             "TavelTimePeriods[1] : ")

    features = computed_data.features
    check_locations(data.locations, computed_data, data.coordinate_mode, features)
    check_location_groups(data.location_groups, computed_data)
    check_requests(data.requests, computed_data)
    check_vehicle_categories(data.vehicle_categories, computed_data)
    check_vehicle_sets(data.vehicle_sets, computed_data)
    check_product_specification_classes(data.product_specification_classes, computed_data)

    if !(data.coordinate_mode in [0, 1])
        error("Invalid value for coordinate_mode: $data.coordinate_mode")
    end

    features = computed_data.features

    if (in(HAS_PRODUCT_CAPACITY_CONSUMPTIONS, features) &&
        !in(HAS_VEHICLE_CAPACITIES, features))
        error("Instance is inconsistent. It features produtct capacity",
              " consumptions, but does not feature vehicles with capacity",
              " specifications")
    end
    if (in(HAS_PRODUCT_PROPERTIES_REQUIREMENTS, features) &&
        !in(HAS_VEHICLE_PROPERTIES, features))
        error("Instance is inconsistent. It features produtct property",
              " requirements, but does not feature vehicles property",
              " specifications")
    end

    # filling Instance based features
    # if length(data.vehicle_categories) > 0
    #     union!(features, HAS_VEHICLE_CATEGORIES)
    # end
    if (length(data.vehicle_categories) == 2 &&
        computed_data.uses_default_vehicle_category) ||
       (length(data.vehicle_categories) > 2)

        union!(features, HAS_MULTIPLE_VEHICLE_CATEGORIES)
    end
    if length(data.vehicle_sets) > 1
        union!(features, HAS_MULTIPLE_VEHICLE_SETS)
    end
    if length(data.travel_periods) > 1
        union!(features, HAS_MUTLIPLE_TRAVEL_TIME_PERIODS)
    end
    if data.coordinate_mode == 1
        union!(features, HAS_X_Y)
    end

    # TODO check matrices sizes (based on features)
end

function print_features(features::BitSet)
    println("The features are : ")
    # Location based features  #
    if in(HAS_OPENING_TIME_WINDOWS, features)
        println("HAS_OPENING_TIME_WINDOWS,")
    end
    if in(HAS_MULTIPLE_OPENING_TIME_WINDOWS, features)
        println("HAS_MULTIPLE_OPENING_TIME_WINDOWS,")
    end
    if in(HAS_FLEXIBLE_OPENING_TIME_WINDOWS, features)
        println("HAS_FLEXIBLE_OPENING_TIME_WINDOWS,")
    end

    # Product based features #
    if in(HAS_PRODUCT_CONFLICT_CLASSES, features)
        println("HAS_PRODUCT_CONFLICT_CLASSES,")
    end
    if in(HAS_PRODUCT_PROHIBITED_PREDECESSOR_CLASSES, features)
        println("HAS_PRODUCT_PROHIBITED_PREDECESSOR_CLASSES,")
    end
    if in(HAS_PRODUCT_PICKUPONLY_SHARING_CLASSES, features)
        println("HAS_PRODUCT_PICKUPONLY_SHARING_CLASSES,")
    end
    if in(HAS_PRODUCT_DELIVERYONLY_SHARING_CLASSES, features)
        println("HAS_PRODUCT_DELIVERYONLY_SHARING_CLASSES,")
    end
    if in(HAS_PRODUCT_SHIPMENT_SHARING_CLASSES, features)
        println("HAS_PRODUCT_SHIPMENT_SHARING_CLASSES,")
    end
    if in(HAS_PRODUCT_CAPACITY_CONSUMPTIONS, features)
        println("HAS_PRODUCT_CAPACITY_CONSUMPTIONS,")
    end
    if in(HAS_PRODUCT_PROPERTIES_REQUIREMENTS, features)
        println("HAS_PRODUCT_PROPERTIES_REQUIREMENTS,")
    end
    if in(HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS, features)
        println("HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS,")
    end
    if in(HAS_MULTIPLE_PRODUCT_PROPERTIES_REQUIREMENTS, features)
        println("HAS_MULTIPLE_PRODUCT_PROPERTIES_REQUIREMENTS,")
    end

    # Request based features
    if in(HAS_SHIPMENT_REQUESTS, features)
        println("HAS_SHIPMENT_REQUESTS,")
    end
    if in(HAS_PICKUPONLY_REQUESTS, features)
        println("HAS_PICKUPONLY_REQUESTS,")
    end
    if in(HAS_DELIVERYONLY_REQUESTS, features)
        println("HAS_DELIVERYONLY_REQUESTS,")
    end
    if in(HAS_ALTERNATIVE_PICKUP_LOCATIONS, features)
        println("HAS_ALTERNATIVE_PICKUP_LOCATIONS,")
    end
    if in(HAS_ALTERNATIVE_DELIVERY_LOCATIONS, features)
        println("HAS_ALTERNATIVE_DELIVERY_LOCATIONS,")
    end
    if in(HAS_MAX_DURATION, features)
        println("HAS_MAX_DURATION,")
    end
    if in(HAS_DURATION_UNIT_COSTS, features)
        println("HAS_DURATION_UNIT_COSTS,")
    end
    if in(HAS_PICKUP_TIME_WINDOWS, features)
        println("HAS_PICKUP_TIME_WINDOWS,")
    end
    if in(HAS_DELIVERY_TIME_WINDOWS, features)
        println("HAS_DELIVERY_TIME_WINDOWS,")
    end
    if in(HAS_MULTIPLE_PICKUP_TIME_WINDOWS, features)
        println("HAS_MULTIPLE_PICKUP_TIME_WINDOWS,")
    end
    if in(HAS_MULTIPLE_DELIVERY_TIME_WINDOWS, features)
        println("HAS_MULTIPLE_DELIVERY_TIME_WINDOWS,")
    end
    if in(HAS_FLEXIBLE_PICKUP_TIME_WINDOWS, features)
        println("HAS_FLEXIBLE_PICKUP_TIME_WINDOWS,")
    end
    if in(HAS_FLEXIBLE_DELIVERY_TIME_WINDOWS, features)
        println("HAS_FLEXIBLE_DELIVERY_TIME_WINDOWS,")
    end
    if in(HAS_FLEXIBLE_REQUESTS, features)
        println("HAS_FLEXIBLE_REQUESTS,")
    end

    # VehicleCategory based features
    if in(HAS_VEHICLE_CAPACITIES, features)
        println("HAS_VEHICLE_CAPACITIES,")
    end
    if in(HAS_VEHICLE_PROPERTIES, features)
        println("HAS_VEHICLE_PROPERTIES,")
    end
    if in(HAS_COMPARTMENT_CAPACITIES, features)
        println("HAS_COMPARTMENT_CAPACITIES,")
    end
    if in(HAS_COMPARTMENT_PROPERTIES, features)
        println("HAS_COMPARTMENT_PROPERTIES,")
    end
    if in(HAS_MULTIPLE_VEHICLE_CAPACITIES, features)
        println("HAS_MULTIPLE_VEHICLE_CAPACITIES,")
    end
    if in(HAS_MULTIPLE_VEHICLE_PROPERTIES, features)
        println("HAS_MULTIPLE_VEHICLE_PROPERTIES,")
    end
    if in(HAS_MULTIPLE_COMPARTMENT_CAPACITIES, features)
        println("HAS_MULTIPLE_COMPARTMENT_CAPACITIES,")
    end
    if in(HAS_MULTIPLE_COMPARTMENT_PROPERTIES, features)
        println("HAS_MULTIPLE_COMPARTMENT_PROPERTIES,")
    end

    # HomogeneousVehicleSet based features
    if in(HAS_TRAVEL_TIME_UNIT_COST, features)
        println("HAS_TRAVEL_TIME_UNIT_COST,")
    end
    if in(HAS_SERVICE_TIME_UNIT_COST, features)
        println("HAS_SERVICE_TIME_UNIT_COST,")
    end
    if in(HAS_WAITING_TIME_UNIT_COST, features)
        println("HAS_WAITING_TIME_UNIT_COST,")
    end
    if in(HAS_TRAVEL_DISTANCE_UNIT_COST, features)
        println("HAS_TRAVEL_DISTANCE_UNIT_COST,")
    end
    if in(HAS_MAX_WORKING_TIME, features)
        println("HAS_MAX_WORKING_TIME,")
    end
    if in(HAS_MAX_TRAVEL_DISTANCE, features)
        println("HAS_MAX_TRAVEL_DISTANCE,")
    end
    if in(HAS_MIN_NB_VEHICLES, features)
        println("HAS_MIN_NB_VEHICLES,")
    end
    if in(HAS_MAX_NB_VEHICLES, features)
        println("HAS_MAX_NB_VEHICLES,")
    end
    if in(HAS_FLEXIBLE_NB_VEHICLES_RANGE, features)
        println("HAS_FLEXIBLE_NB_VEHICLES_RANGE,")
    end
    if in(HAS_WORKING_TIME_WINDOW, features)
        println("HAS_WORKING_TIME_WINDOW,")
    end
    if in(HAS_FLEXIBLE_WORKING_TIME_WINDOWS, features)
        println("HAS_FLEXIBLE_WORKING_TIME_WINDOWS,")
    end
    if in(HAS_FIXED_COST_PER_VEHICLE, features)
        println("HAS_FIXED_COST_PER_VEHICLE,")
    end

    # Instance based features
    if in(HAS_WORK_PERIODS, features)
        println("HAS_WORK_PERIODS,")
    end
    if in(HAS_MUTLIPLE_TRAVEL_TIME_PERIODS, features)
        println("HAS_MUTLIPLE_TRAVEL_TIME_PERIODS,")
    end
    # if in(HAS_VEHICLE_CATEGORIES, features)
    #     println("HAS_VEHICLE_CATEGORIES,")
    # end
    if in(HAS_MULTIPLE_VEHICLE_CATEGORIES, features)
        println("HAS_MULTIPLE_VEHICLE_CATEGORIES,")
    end
    if in(HAS_MULTIPLE_VEHICLE_SETS, features)
        println("HAS_MULTIPLE_VEHICLE_SETS,")
    end
    if in(HAS_ENERGY_FEATURES, features)
        println("HAS_ENERGY_FEATURES,")
    end
end
