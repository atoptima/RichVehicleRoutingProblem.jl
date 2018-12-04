####################### RVRP FEATURES #############################

# Location based features  #
const HAS_OPENING_TIME_WINDOWS = 1
const HAS_MULTIPLE_OPENING_TIME_WINDOWS = 2
const HAS_FLEXIBLE_OPENING_TIME_WINDOWS = 3
const HAS_A_RECHARGING_STATION = 4

# Product based features #
const HAS_PRODUCT_COMPATIBILITY_CONFLICT_ISSUES = 10
const HAS_PRODUCT_PROHIBITED_PREDECESSOR_ISSUES = 11
const HAS_PRODUCT_LIMITED_AVAILABILITIES_AT_PICKUP_POINTS = 12
const HAS_PRODUCT_LIMITED_CAPACITIES_AT_DELIVERY_POINTS = 13

# Request based features
const HAS_SHIPMENT_REQUESTS = 109
const HAS_PICKUPONLY_REQUESTS = 110
const HAS_DELIVERYONLY_REQUESTS = 111
const HAS_SHARED_PRODUCTS_DELIVERIES_BEING_SATISFIED_FROM_PICKUPS = 112
const HAS_ALTERNATIVE_PICKUP_LOCATIONS_FOR_REQUESTS = 112 #
const HAS_ALTERNATIVE_DELIVERY_LOCATIONS_FOR_REQUESTS = 113 #
const HAS_MAX_DURATION_FOR_REQUESTS = 114
const HAS_DURATION_UNIT_COSTS_FOR_REQUESTS = 115 #
const HAS_PICKUP_TIME_WINDOWS_FOR_REQUESTS = 116
const HAS_DELIVERY_TIME_WINDOWS_FOR_REQUESTS = 117
const HAS_MULTIPLE_PICKUP_TIME_WINDOWS_FOR_REQUESTS = 118
const HAS_MULTIPLE_DELIVERY_TIME_WINDOWS_FOR_REQUESTS = 119
const HAS_FLEXIBLE_PICKUP_TIME_WINDOWS_FOR_REQUESTS = 120 #
const HAS_FLEXIBLE_DELIVERY_TIME_WINDOWS_FOR_REQUESTS = 121 #
const HAS_FLEXIBLE_REQUESTS = 122 #
const HAS_ALLOWED_SPLIT_FULFILLMENT_FOR_REQUESTS = 123 #

# VehicleCategory based features
const HAS_VEHICLE_CAPACITIES = 224
const HAS_VEHICLE_PROPERTIES = 225
const HAS_COMPARTMENT_CAPACITIES = 226 #
const HAS_COMPARTMENT_PROPERTIES = 227 #
const HAS_MULTIPLE_VEHICLE_CAPACITIES = 228
const HAS_MULTIPLE_VEHICLE_PROPERTIES = 229
const HAS_MULTIPLE_COMPARTMENT_CAPACITIES = 230 #
const HAS_MULTIPLE_COMPARTMENT_PROPERTIES = 231 #
const HAS_ENERGY_RECHARGING_ISSUES_FOR_VEHICLES = 232 #

# HomogeneousVehicleSet based features
const HAS_TRAVEL_TIME_UNIT_COST_FOR_VEHICLES = 333
const HAS_SERVICE_TIME_UNIT_COST_FOR_VEHICLES = 334
const HAS_WAITING_TIME_UNIT_COST_FOR_VEHICLES = 335
const HAS_TRAVEL_DISTANCE_UNIT_COST_FOR_VEHICLES = 339 #
const HAS_MAX_WORKING_TIME_FOR_VEHICLES = 337 #
const HAS_MAX_TRAVEL_DISTANCE_FOR_VEHICLES = 338 #
const HAS_MIN_NB_VEHICLES = 340 #
const HAS_MAX_NB_VEHICLES = 341
const HAS_FLEXIBLE_NB_VEHICLES_RANGE = 342 #
const HAS_WORKING_TIME_WINDOW_FOR_VEHICLES = 343
const HAS_FLEXIBLE_WORKING_TIME_WINDOWS_FOR_VEHICLES = 345 #
const HAS_FIXED_COST_PER_VEHICLE = 346
const HAS_OPEN_DEPARTURE_FOR_VEHICLES = 347
const HAS_OPEN_ARRIVAL_FOR_VEHICLES = 348
const HAS_ALTERNATIVE_DEPARTURE_LOCATIONS_FOR_VEHICLES = 349 #
const HAS_ALTERNATIVE_ARRIVAL_LOCATIONS_FOR_VEHICLES = 350 #

# Instance based features
const HAS_WORK_PERIODS = 447
const HAS_MUTLIPLE_TRAVEL_SPECIFICATION_PERIODS = 448
# const HAS_VEHICLE_CATEGORIES = 449 (not needed, duplicate of caps props)
const HAS_MULTIPLE_VEHICLE_CATEGORIES = 450
const HAS_MULTIPLE_VEHICLE_SETS = 451

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

function check_locations(locations::Vector{Location},
                         computed_data::RvrpComputedData)

    for loc in locations
        if loc.latitude < - 100.0 || loc.latitude > 100.0
            error("Location $(loc.id) must have latitude in [-100.0, +100.0]")
        elseif loc.longitude < - 100.0 || loc.longitude > 100.0
            error("Location $(loc.id) must have longitude in [-100.0, +100.0]")
        elseif loc.index < 1 || loc.index > length(locations)
            error("Location $(loc.id) must have index in [1, length(locations)]")
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

        # filling REQUEST based features
        features = computed_data.features
        if req.request_type == 0
            union!(features, HAS_SHIPMENT_REQUESTS)
        elseif req.request_type == 1
            union!(features, HAS_PICKUPONLY_REQUESTS)
        elseif req.request_type == 0
            union!(features, HAS_DELIVERYONLY_REQUESTS)
        end
        if req.max_duration > 0
            union!(features, HAS_MAX_DURATION)
        end
        if req.pickup_time_windows[1].soft_range.lb > 0 ||
           req.pickup_time_windows[1].soft_range.ub < 10^9
            union!(features, HAS_PICKUP_TIME_WINDOWS)
        end
        if req.delivery_time_windows[1].soft_range.lb > 0 ||
           req.delivery_time_windows[1].soft_range.ub < 10^9
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
        if length(vc.vehicle_capacities) > 0
            union!(features, HAS_VEHICLE_CAPACITIES)
        end
        if length(vc.compartment_capacities) > 0
            union!(features, HAS_COMPARTMENT_CAPACITIES)
        end
        if length(vc.vehicle_properties) > 0
            union!(features, HAS_VEHICLE_PROPERTIES)
        end
        if length(vc.compartment_properties) > 0
            union!(features, HAS_COMPARTMENT_PROPERTIES)
        end
        if length(vc.vehicle_capacities) > 1
            union!(features, HAS_MULTIPLE_VEHICLE_CAPACITIES)
        end
        if length(vc.compartment_capacities) > 1
            union!(features, HAS_MULTIPLE_COMPARTMENT_CAPACITIES)
        end
        if length(vc.vehicle_properties) > 1
            union!(features, HAS_MULTIPLE_VEHICLE_PROPERTIES)
        end
        if length(vc.compartment_properties) > 1
            union!(features, HAS_MULTIPLE_COMPARTMENT_PROPERTIES)
        end
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
        check_positive_range(vs.working_time_window.soft_range,
                 "VehicleSet $(vs.id), working_time_window[1].soft_range : ")
        check_positive_range(vs.nb_of_vehicles_range.soft_range,
                 "VehicleSet $(vs.id), nb_of_vehicles_range.soft_range : ")
        if vs.travel_time_unit_cost < 0
            error("VehicleSet $(vs.id) must have travel_time_unit_cost > 0")
        elseif vs.service_time_unit_cost < 0
            error("VehicleSet $(vs.id) must have service_time_unit_cost > 0")
        elseif vs.waiting_time_unit_cost < 0
            error("VehicleSet $(vs.id) must have waiting_time_unit_cost > 0")
        elseif vs.fixed_cost_per_vehicle < 0
            error("VehicleSet $(vs.id) must have fixed_cost_per_vehicle > 0")
        end

        # filling HomogeneousVehicleSet based features
        features = computed_data.features
        if vs.route_mode in [1,3]
            union!(features, HAS_OPEN_ARRIVAL)
        end
        if vs.route_mode in [1,3]
            union!(features, HAS_OPEN_DEPARTURE)
        end
        if vs.travel_time_unit_cost > 0
            union!(features, HAS_TRAVEL_TIME_UNIT_COST)
        end
        if vs.service_time_unit_cost > 0
            union!(features, HAS_SERVICE_TIME_UNIT_COST)
        end
        if vs.travel_time_unit_cost > 0
            union!(features, HAS_WAITING_TIME_UNIT_COST)
        end
        if vs.travel_time_unit_cost > 0
            union!(features, HAS_TRAVEL_TIME_UNIT_COST)
        end
        if vs.travel_distance_unit_cost > 0
            union!(features, HAS_TRAVEL_DISTANCE_UNIT_COST)
        end
        if vs.fixed_cost_per_vehicle > 0
            union!(features, HAS_FIXED_COST_PER_VEHICLE)
        end
        if vs.nb_of_vehicles_range.soft_range.ub < 10^9
            union!(features, HAS_MAX_NB_VEHICLES)
        end
        if vs.working_time_window.soft_range.lb > 0 ||
           vs.working_time_window.soft_range.ub < 10^9
            union!(features, HAS_PICKUP_TIME_WINDOWS)
        end
        if vs.vehicle_category_id == "default_id"
            computed_data.uses_default_vehicle_category = true
        end
    end
end

function check_instance(data::RvrpInstance, computed_data::RvrpComputedData)

    tt_period = data.travel_periods[1]
    check_id(computed_data.travel_specification_id_2_index,
             tt_period.travel_specification_id,
             "TavelTimePeriods[1] : ")

    check_locations(data.locations, computed_data)
    check_location_groups(data.location_groups, computed_data)
    check_requests(data.requests, computed_data)
    check_vehicle_categories(data.vehicle_categories, computed_data)
    check_vehicle_sets(data.vehicle_sets, computed_data)

    # filling Instance based features
    features = computed_data.features
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
    if length(data.work_periods) > 1
        union!(features, HAS_WORK_PERIODS)
    end
    if length(data.travel_periods) > 1
        union!(features, HAS_MUTLIPLE_TRAVEL_TIME_PERIODS)
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
