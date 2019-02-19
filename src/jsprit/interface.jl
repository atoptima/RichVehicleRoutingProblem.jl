import JavaCall
include("java_types.jl")

struct JspritSolver
    params::Dict{String,String}
    JspritSolver() = new(Dict{String,String}())
end

# RADIAL_BEST("radial_best"),
# RADIAL_REGRET("radial_regret"),
# RANDOM_BEST("random_best"),
# RANDOM_REGRET("random_regret"),
# WORST_BEST("worst_best"),
# WORST_REGRET("worst_regret"),
# CLUSTER_BEST("cluster_best"),
# CLUSTER_REGRET("cluster_regret"),
# STRING_BEST("string_best"),
# STRING_REGRET("string_regret");
# FIXED_COST_PARAM("fixed_cost_param"),
# VEHICLE_SWITCH("vehicle_switch"),
# REGRET_TIME_WINDOW_SCORER("regret.tw_scorer"),
# REGRET_DISTANCE_SCORER("regret.distance_scorer"),
# INITIAL_THRESHOLD("initial_threshold"),
# ITERATIONS("iterations"),
# THREADS("threads"),
# RANDOM_REGRET_MIN_SHARE("random_regret.min_share"),
# RANDOM_REGRET_MAX_SHARE("random_regret.max_share"),
# RANDOM_BEST_MIN_SHARE("random_best.min_share"),
# RANDOM_BEST_MAX_SHARE("random_best.max_share"),
# RADIAL_MIN_SHARE("radial.min_share"),
# RADIAL_MAX_SHARE("radial.max_share"),
# CLUSTER_MIN_SHARE("cluster.min_share"),
# CLUSTER_MAX_SHARE("cluster.max_share"),
# WORST_MIN_SHARE("worst.min_share"),
# WORST_MAX_SHARE("worst.max_share"),
# THRESHOLD_ALPHA("threshold.alpha"),
# THRESHOLD_INI("threshold.ini"),
# THRESHOLD_INI_ABS("threshold.ini_abs"),
# INSERTION_NOISE_LEVEL("insertion.noise_level"),
# INSERTION_NOISE_PROB("insertion.noise_prob"),
# RUIN_WORST_NOISE_LEVEL("worst.noise_level"),
# RUIN_WORST_NOISE_PROB("worst.noise_prob"),
# FAST_REGRET("regret.fast"),
# MAX_TRANSPORT_COSTS("max_transport_costs"),
# CONSTRUCTION("construction"),
# BREAK_SCHEDULING("break_scheduling"),
# STRING_K_MIN("string_kmin"),
# STRING_K_MAX("string_kmax"),
# STRING_L_MIN("string_lmin"),
# STRING_L_MAX("string_lmax"),
# MIN_UNASSIGNED("min_unassigned"),
# PROPORTION_UNASSIGNED("proportion_unassigned");

function setup_jvm()
    cd(dirname(@__FILE__))
    JavaCall.addClassPath("./jsprit-core.jar")
    JavaCall.init()
end

################################################
############### Jsprit functions ###############
################################################


function build_routes(data::RvrpInstance, solver::JspritSolver,
                      computed_data::RvrpComputedData,
                      jsp_sol, jsp_types::JspritJavaTypes)
    routes = Route[]
    jsp_routes_collection = JavaCall.jcall(jsp_sol, "getRoutes", jsp_types.JCollection, ())
    jsp_routes = JavaCall.jcall(jsp_routes_collection, "toArray",
                     Array{JavaCall.JObject, 1}, ())

    nb_routes =  length(jsp_routes)
    for r_idx in 1:nb_routes

        r_id = string("route_", r_idx)
        jsp_route = jsp_types.JVehicleRoute(jsp_routes[r_idx].ptr)

        jsp_vehicle = JavaCall.jcall(jsp_route, "getVehicle",
                                     jsp_types.JVehicleI, ())
        jsp_vehicle_type = JavaCall.jcall(jsp_vehicle, "getType",
                                          jsp_types.JVTypeI, ())
        v_set_id = JavaCall.jcall(jsp_vehicle_type, "getTypeId",
                                  JavaCall.JString, ())

        sequence = Action[]
        # Start action
        jsp_start_act = JavaCall.jcall(jsp_route, "getStart",
                            jsp_types.JStartActivity, ())
        arr_time = JavaCall.jcall(jsp_start_act, "getArrTime", JavaCall.jdouble, ())
        jsp_loc = JavaCall.jcall(jsp_start_act, "getLocation",
                            jsp_types.JLocation, ())
        loc_id = JavaCall.jcall(jsp_loc, "getId", JavaCall.JString, ())
        name = JavaCall.jcall(jsp_start_act, "getName", JavaCall.JString, ())
        operation_type = 0
        if name in ["pickupShipment", "pickup"]
            operation_type = 1
        elseif name in ["deliverShipment", "deliver"]
            operation_type = 2
        end
        push!(sequence, Action("action_1", loc_id, 0, "", arr_time))
        jsp_action_list = JavaCall.jcall(jsp_route, "getActivities",
                                         jsp_types.JList, ())
        jsp_actions = JavaCall.jcall(jsp_action_list, "toArray",
                                     Array{JavaCall.JObject, 1}, ())
        nb_actions = length(jsp_actions)
        for action_idx in 1:nb_actions
            jsp_act = jsp_types.JJobActivity(jsp_actions[action_idx].ptr)
            jsp_loc = JavaCall.jcall(jsp_act, "getLocation",
                                     jsp_types.JLocation, ())
            loc_id = JavaCall.jcall(jsp_loc, "getId", JavaCall.JString, ())
            jsp_job = JavaCall.jcall(jsp_act, "getJob", jsp_types.JJob, ())
            req_id = JavaCall.jcall(jsp_job, "getId", JavaCall.JString, ())
            arr_time = JavaCall.jcall(jsp_act, "getArrTime", JavaCall.jdouble, ())
            req = data.requests[computed_data.request_id_2_index[req_id]]
            name = JavaCall.jcall(jsp_act, "getName", JavaCall.JString, ())
            if name in ["pickupShipment", "pickup"]
                tws = [tw.soft_range for tw in req.pickup_time_windows]
                tw = get_closest_tw(tws, arr_time)
                if arr_time < tw.lb
                    arr_time = tw.lb
                end
                operation_type = 1
            elseif name in ["deliverShipment", "deliver"]
                tws = [tw.soft_range for tw in req.delivery_time_windows]
                tw = get_closest_tw(tws, arr_time)
                if arr_time < tw.lb
                    arr_time = tw.lb
                end
                operation_type = 2
            end
            push!(sequence, Action(string("action_", action_idx+1), loc_id,
                                        operation_type, req_id, arr_time))
        end
        # End action -> Assumes for now that always returns to depot
        jsp_end_act = JavaCall.jcall(jsp_route, "getEnd",
                                     jsp_types.JEndActivity, ())
        jsp_loc = JavaCall.jcall(jsp_end_act, "getLocation",
                                 jsp_types.JLocation, ())
        loc_id = JavaCall.jcall(jsp_loc, "getId", JavaCall.JString, ())
        arr_time = JavaCall.jcall(jsp_end_act, "getArrTime", JavaCall.jdouble, ())
        name = JavaCall.jcall(jsp_end_act, "getName", JavaCall.JString, ())
        operation_type = 0
        if name in ["pickupShipment", "pickup"]
            operation_type = 1
        elseif name in ["deliverShipment", "deliver"]
            operation_type = 2
        end
        push!(sequence, Action(string("action_", nb_actions+2),
                                    loc_id, operation_type, "", arr_time))

        push!(routes, Route(
            r_id, v_set_id, sequence, 0
        ))
    end

    return routes
end

function jsprit_build_and_add_locations(locations::Vector{Location},
                                        vrp_builder, jsp_types::JspritJavaTypes)
    JLocationBuilder = jsp_types.JLocationBuilder
    jsp_locs = jsp_types.JLocation[]
    for l in locations
        jsp_loc_builder = JLocationBuilder(())
        JavaCall.jcall(jsp_loc_builder, "setId", JLocationBuilder,
                       (JavaCall.JString,), l.id)
        JavaCall.jcall(jsp_loc_builder, "setName", JLocationBuilder,
                       (JavaCall.JString,), l.id)
        JavaCall.jcall(jsp_loc_builder, "setIndex", JLocationBuilder,
                       (JavaCall.jint,), l.index-1)
        c = jsp_types.JCoord((JavaCall.jdouble, JavaCall.jdouble),
                             l.long_x, l.lat_y)
        JavaCall.jcall(jsp_loc_builder, "setCoordinate", JLocationBuilder,
                       (jsp_types.JCoord,), c)
        jsp_loc = jsp_types.JLocation((JLocationBuilder,), jsp_loc_builder)
        push!(jsp_locs, jsp_loc)
    end
    return jsp_locs
end

function jsprit_build_vehicle_type(v_cats::Vector{VehicleCategory},
                                   v_set::HomogeneousVehicleSet,
                                   computed_data::RvrpComputedData,
                                   jsp_types::JspritJavaTypes)
    # Assumptions:
    # 1. Properties are binary properties, thus can be transformed to skills
    # 1.1 Only the ids of the properties are useful

    vc = v_cats[computed_data.vehicle_category_id_2_index[v_set.vehicle_category_id]]

    JVTypeBuilder = jsp_types.JVTypeBuilder

    jsp_vt_builder = JVTypeBuilder((JavaCall.JString,), v_set.id)
    JavaCall.jcall(jsp_vt_builder, "setCostPerDistance", JVTypeBuilder,
                   (JavaCall.jdouble,), v_set.cost_periods[1].travel_distance_unit_cost)
    JavaCall.jcall(jsp_vt_builder, "setCostPerTransportTime", JVTypeBuilder,
                   (JavaCall.jdouble,), v_set.cost_periods[1].travel_time_unit_cost)
    JavaCall.jcall(jsp_vt_builder, "setCostPerServiceTime", JVTypeBuilder,
                   (JavaCall.jdouble,), v_set.cost_periods[1].service_time_unit_cost)
    JavaCall.jcall(jsp_vt_builder, "setCostPerWaitingTime", JVTypeBuilder,
                   (JavaCall.jdouble,), v_set.cost_periods[1].waiting_time_unit_cost)
    JavaCall.jcall(jsp_vt_builder, "setFixedCost", JVTypeBuilder,
                   (JavaCall.jdouble,), v_set.cost_periods[1].fixed_cost)
    for (k,v) in vc.capacities.of_vehicle
        cap_dim = computed_data.capacity_id_2_index[k]
        JavaCall.jcall(jsp_vt_builder, "addCapacityDimension", JVTypeBuilder,
                       (JavaCall.jint, JavaCall.jint), cap_dim-1, v)
    end
    for s in collect(keys(vc.properties.of_vehicle))
        JavaCall.jcall(jsp_vt_builder, "addSkill", JVTypeBuilder,
                       (JavaCall.JString), s)
    end

    jsp_vt = JavaCall.jcall(jsp_vt_builder, "build", jsp_types.JVType, ())
    return jsp_vt
end

function jsprit_add_vehicles(v_cats::Vector{VehicleCategory},
                             v_sets::Vector{HomogeneousVehicleSet},
                             locations::Vector{Location},
                             lgs::Vector{LocationGroup},
                             computed_data::RvrpComputedData,
                             vrp_builder, jsp_locs, jsp_types::JspritJavaTypes)

    loc_id_2_idx = computed_data.location_id_2_index
    JVehicleBuilder = jsp_types.JVehicleBuilder
    # Assumptions:
    # 1. A vehicle has a single departure point and a single arrival point
    # 2. JS working time window equals HomogeneousVehicleSet.work_periods[1].soft_range
    # 3. We use only soft ranges
    # 4. departure_depot_id is never empty

    for v_set in v_sets
        # JVType:
        jsp_vt = jsprit_build_vehicle_type(v_cats, v_set, computed_data,
                                           jsp_types)

        # For start location:
        lg_idx = computed_data.location_group_id_2_index[v_set.departure_location_group_id]
        start_depot_idx = computed_data.location_id_2_index[lgs[lg_idx].location_ids[1]]
        # For end location:
        lg_idx = computed_data.location_group_id_2_index[v_set.arrival_location_group_id]
        lg = lgs[lg_idx]
        if isempty(lg.location_ids)
            end_depot_idx = -1
            return_to_depot = false
        else
            end_depot_idx = computed_data.location_id_2_index[lg.location_ids[1]]
            return_to_depot = true
        end

        # Define start and end locations from jsp_locations
        start_loc = jsp_locs[start_depot_idx]
        end_loc = nothing
        if end_depot_idx != -1
            end_loc = jsp_locs[end_depot_idx]
        end

        early_start_time = v_set.work_periods[1].soft_range.lb
        late_arrival_time = v_set.work_periods[1].soft_range.ub

        # Add as many copies as there are in the class
        for idx in 1:v_set.nb_of_vehicles_range.soft_range.ub
            id = string(v_set.id, "_", idx)

            jsp_vehicle_builder = JavaCall.jcall(JVehicleBuilder, "newInstance",
                JVehicleBuilder, (JavaCall.JString,), id)

            JavaCall.jcall(jsp_vehicle_builder, "setType",
                JVehicleBuilder, (jsp_types.JVTypeI,), jsp_vt)
            JavaCall.jcall(jsp_vehicle_builder, "setEarliestStart",
                JVehicleBuilder, (JavaCall.jdouble,), early_start_time)
            JavaCall.jcall(jsp_vehicle_builder, "setLatestArrival",
                JVehicleBuilder, (JavaCall.jdouble,), late_arrival_time)
            JavaCall.jcall(jsp_vehicle_builder, "setReturnToDepot",
                JVehicleBuilder, (JavaCall.jboolean,), return_to_depot)
            JavaCall.jcall(jsp_vehicle_builder, "setStartLocation",
                JVehicleBuilder, (jsp_types.JLocation,), start_loc)
            if return_to_depot
                JavaCall.jcall(jsp_vehicle_builder, "setEndLocation",
                    JVehicleBuilder, (jsp_types.JLocation,), end_loc)
            end

            jsp_vehicle = JavaCall.jcall(jsp_vehicle_builder, "build",
                                         jsp_types.JVehicle, ())
            JavaCall.jcall(vrp_builder, "addVehicle", jsp_types.JVrpBuilder,
                           (jsp_types.JAbstractVehicle,), jsp_vehicle)
        end
    end
end

function jsprit_build_service(req::Request, jsp_loc, serv_time::Float64,
                              consumptions::Dict{String,Float64},
                              skills::Vector{String},
                              tws::Vector{FlexibleRange}, vrp_builder,
                              JSpecificService, JSpecificServiceBuilder,
                              computed_data::RvrpComputedData,
                              jsp_types::JspritJavaTypes)

    # Assumptions:
    # 2. Maximum time in vehicle is always infinite, so no need to set
    JService = jsp_types.JService
    JServiceBuilder = jsp_types.JServiceBuilder
    JLocation = jsp_types.JLocation
    JTW = jsp_types.JTW

    jsp_service_builder = JavaCall.jcall(JSpecificServiceBuilder, "newInstance",
        JSpecificServiceBuilder, (JavaCall.JString,), req.id)
    JavaCall.jcall(jsp_service_builder, "setServiceTime", JServiceBuilder,
                   (JavaCall.jdouble,), serv_time)
    JavaCall.jcall(jsp_service_builder, "setLocation", JServiceBuilder,
                   (JLocation,), jsp_loc)
    for tw in tws
        jsp_tw = JTW((JavaCall.jdouble, JavaCall.jdouble), tw.soft_range.lb,
                     tw.soft_range.ub)
        JavaCall.jcall(jsp_service_builder, "addTimeWindow", JServiceBuilder,
                       (JTW,), jsp_tw)
    end
    for (cap_id,cons) in consumptions
        cons_idx = computed_data.capacity_id_2_index[cap_id]
        JavaCall.jcall(jsp_service_builder, "addSizeDimension", JServiceBuilder,
                       (JavaCall.jint, JavaCall.jint), cons_idx-1, cons)
    end
    for s in skills
        JavaCall.jcall(jsp_service_builder, "addRequiredSkill",
                       JServiceBuilder, (JavaCall.JString), s)
    end
    return JavaCall.jcall(jsp_service_builder, "build", JSpecificService, ())
end

function jsprit_build_shipment(req::Request, jsp_pickup_loc,
                               jsp_delivery_loc,
                               consumptions::Dict{String,Float64},
                               skills::Vector{String},
                               vrp_builder, computed_data::RvrpComputedData,
                               jsp_types::JspritJavaTypes)
    # Assumptions:
    JShipment = jsp_types.JShipment
    JShipmentBuilder = jsp_types.JShipmentBuilder
    JLocation = jsp_types.JLocation
    JTW = jsp_types.JTW

    jsp_shipment_builder = JavaCall.jcall(JShipmentBuilder, "newInstance",
        JShipmentBuilder, (JavaCall.JString,), req.id)
    JavaCall.jcall(jsp_shipment_builder, "setPickupLocation", JShipmentBuilder,
                   (JLocation,), jsp_pickup_loc)
    JavaCall.jcall(jsp_shipment_builder, "setDeliveryLocation", JShipmentBuilder,
                   (JLocation,), jsp_delivery_loc)
    JavaCall.jcall(jsp_shipment_builder, "setPickupServiceTime",
        JShipmentBuilder, (JavaCall.jdouble,), req.pickup_service_time)
    JavaCall.jcall(jsp_shipment_builder, "setDeliveryServiceTime",
        JShipmentBuilder, (JavaCall.jdouble,), req.delivery_service_time)
    JavaCall.jcall(jsp_shipment_builder, "setMaxTimeInVehicle",
         JShipmentBuilder, (JavaCall.jdouble,), req.max_duration)
    for tw in req.pickup_time_windows
        jsp_tw = JTW((JavaCall.jdouble, JavaCall.jdouble), tw.soft_range.lb,
                     tw.soft_range.ub)
        JavaCall.jcall(jsp_shipment_builder, "addPickupTimeWindow",
                       JShipmentBuilder, (JTW,), jsp_tw)
    end
    for tw in req.delivery_time_windows
        jsp_tw = JTW((JavaCall.jdouble, JavaCall.jdouble), tw.soft_range.lb,
                     tw.soft_range.ub)
        JavaCall.jcall(jsp_shipment_builder, "addDeliveryTimeWindow",
                       JShipmentBuilder, (JTW,), jsp_tw)
    end
    for (cap_id,cons) in consumptions
        cons_idx = computed_data.capacity_id_2_index[cap_id]
        JavaCall.jcall(jsp_shipment_builder, "addSizeDimension",
            JShipmentBuilder, (JavaCall.jint, JavaCall.jint), cons_idx-1, cons)
    end
    for s in skills
        JavaCall.jcall(jsp_service_builder, "addRequiredSkill",
                       JServiceBuilder, (JavaCall.JString), s)
    end
    return JavaCall.jcall(jsp_shipment_builder, "build",
                          jsp_types.JShipment, ())
end

function jsprit_add_jobs(reqs::Vector{Request},
                         locations::Vector{Location},
                         lgs::Vector{LocationGroup},
                         p_spec_classes::Vector{ProductSpecificationClass},
                         computed_data::RvrpComputedData,
                         vrp_builder, jsp_locs, jsp_types::JspritJavaTypes)
    # Assumptions:
    # 1. Properties are binary properties, thus can be transformed to skills
    for req in reqs
        p_spec_class = p_spec_classes[computed_data.product_specification_class_id_2_index[req.product_specification_class_id]]
        skills = collect(keys(p_spec_class.property_requirements))
        c = get_capacity_consumptions(req, p_spec_classes, computed_data)
        # Decide if it is a shipment, pickup or delivery
        if req.request_type == 0 # Pickup and delivery
            pickup_loc_idx = computed_data.location_id_2_index[lgs[computed_data.location_group_id_2_index[req.pickup_location_group_id]].location_ids[1]]
            delivery_loc_idx = computed_data.location_id_2_index[lgs[computed_data.location_group_id_2_index[req.delivery_location_group_id]].location_ids[1]]
            jsp_job = jsprit_build_shipment(req, jsp_locs[pickup_loc_idx],
                 jsp_locs[delivery_loc_idx], c, skills, vrp_builder,
                 computed_data, jsp_types)
        else
            if req.request_type == 1 # Pickup only
                service_type = jsp_types.JPickup
                service_builder = jsp_types.JPickupBuilder
                loc_idx = computed_data.location_id_2_index[lgs[computed_data.location_group_id_2_index[req.pickup_location_group_id]].location_ids[1]]
                s = req.pickup_service_time
                tws = req.pickup_time_windows
            elseif req.request_type == 2 # Delivery only
                service_type = jsp_types.JDelivery
                service_builder = jsp_types.JDeliveryBuilder
                loc_idx = computed_data.location_id_2_index[lgs[computed_data.location_group_id_2_index[req.delivery_location_group_id]].location_ids[1]]
                s = req.delivery_service_time
                tws = req.delivery_time_windows
            end
            jsp_job = jsprit_build_service(req, jsp_locs[loc_idx], s, c,
                skills, tws, vrp_builder, service_type, service_builder,
                computed_data, jsp_types)
        end
        JavaCall.jcall(vrp_builder, "addJob", jsp_types.JVrpBuilder,
                       (jsp_types.JAbstractJob,), jsp_job)
    end

end

function jsprit_add_transport_costs(jsp_vrp_builder,
             locations::Vector{Location},
             travel_specifications::Vector{TravelSpecification},
             travel_periods::Vector{TravelPeriod},
             computed_data::RvrpComputedData,
             jsp_types::JspritJavaTypes)

    JCostsBuilder = jsp_types.JCostsBuilder

    nb_mats = length(travel_specifications)
    nb_periods = length(travel_periods)

    is_matrix_symetric = false
    # is_matrix_symetric = LinearAlgebra.issymetric(dist_mat)

    jsp_costs_builder = JavaCall.jcall(JCostsBuilder, "newInstance",
        JCostsBuilder, (JavaCall.jint, JavaCall.jint, JavaCall.jint,
        JavaCall.jboolean), length(locations), nb_mats, nb_periods,
        is_matrix_symetric)

    # Add the periods
    for p_idx in 1:nb_periods
        p = travel_periods[p_idx].period
        spec_id = travel_periods[p_idx].travel_specification_id
        mat_idx = computed_data.travel_specification_id_2_index[spec_id]
        JavaCall.jcall(jsp_costs_builder, "addTravelPeriod",
            JCostsBuilder, (JavaCall.jint, JavaCall.jdouble, JavaCall.jdouble,
            JavaCall.jint), p_idx-1, p.lb, p.ub, mat_idx-1)
    end

    for travel_spec in travel_specifications
        dist_mat = travel_spec.travel_distance_matrix
        time_mat = travel_spec.travel_time_matrix
        mat_idx = computed_data.travel_specification_id_2_index[travel_spec.id]
        for l1_idx in 1:length(locations)
            for l2_idx in 1:length(locations)
                if dist_mat != Array{Float64,2}(undef, 0, 0)
                    JavaCall.jcall(jsp_costs_builder, "addTransportDistance",
                        JCostsBuilder, (JavaCall.jint, JavaCall.jint,
                        JavaCall.jint, JavaCall.jdouble),
                        l1_idx-1, l2_idx-1, mat_idx-1, dist_mat[l1_idx, l2_idx])
                end
                if time_mat != Array{Float64,2}(undef, 0, 0)
                    JavaCall.jcall(jsp_costs_builder, "addTransportTime",
                        JCostsBuilder, (JavaCall.jint, JavaCall.jint,
                        JavaCall.jint, JavaCall.jdouble),
                        l1_idx-1, l2_idx-1, mat_idx-1, time_mat[l1_idx, l2_idx])
                end
            end
        end
    end

    jsp_costs = JavaCall.jcall(jsp_costs_builder, "build", jsp_types.JCosts, ())
    JavaCall.jcall(jsp_vrp_builder, "setRoutingCost", jsp_types.JVrpBuilder,
                   (jsp_types.JCostsI,), jsp_costs)
end

function jsprit_create_input(data::RvrpInstance,
                             computed_data::RvrpComputedData,
                             jsp_types::JspritJavaTypes)

    jsp_vrp_builder = jsp_types.JVrpBuilder(())
    FS = jsp_types.FleetSize
    # To set fleet size : get the possible values and set one of them
    # using function setFleetSize
    # println("fleetzise methods: ", JavaCall.listmethods(FS))
    vals = JavaCall.jcall(FS, "values", Vector{FS}, ())
    JavaCall.jcall(jsp_vrp_builder, "setFleetSize",  jsp_types.JVrpBuilder,
                   (FS,), vals[1]) # FINITE

    jsp_locs = jsprit_build_and_add_locations(data.locations, jsp_vrp_builder,
                                              jsp_types)
    jsprit_add_vehicles(
        data.vehicle_categories, data.vehicle_sets, data.locations,
        data.location_groups, computed_data, jsp_vrp_builder, jsp_locs,
        jsp_types
    )
    jsprit_add_jobs(
        data.requests, data.locations, data.location_groups,
        data.product_specification_classes, computed_data, jsp_vrp_builder,
        jsp_locs, jsp_types
    )
    jsprit_add_transport_costs(
        jsp_vrp_builder, data.locations, data.travel_specifications,
        data.travel_periods, computed_data, jsp_types
    )

    return JavaCall.jcall(jsp_vrp_builder, "build", jsp_types.JVrp, ())
end

function jsprit_transform_solution(data::RvrpInstance, solver::JspritSolver,
                                 computed_data::RvrpComputedData,
                                 jsp_sol, jsp_types::JspritJavaTypes)
    instance_id = string(data.id, "_jsprit_SOL_", rand(1:10000))
    problem_id = data.id
    cost = JavaCall.jcall(jsp_sol, "getCost", JavaCall.jdouble, ())
    routes = build_routes(data, solver, computed_data, jsp_sol, jsp_types)

    jsp_unassigned_collection = JavaCall.jcall(jsp_sol, "getUnassignedJobs",
                                               jsp_types.JCollection, ())
    jsp_unassigned = JavaCall.jcall(jsp_unassigned_collection, "toArray",
                                     Array{JavaCall.JObject, 1}, ())
    unassigned = String[]
    for idx in 1:length(jsp_unassigned)
        jsp_job = jsp_types.JJob(jsp_unassigned[idx].ptr)
        id = JavaCall.jcall(jsp_job, "getId", JavaCall.JString, ())
        push!(unassigned, id)
    end

    return RvrpSolution(instance_id, problem_id, cost, routes, unassigned)
end

function jsprit_create_algorithm(jsp_vrp, jsp_types::JspritJavaTypes,
                                 solver::JspritSolver)

    jsp_builder = JavaCall.jcall(jsp_types.JSPBuilder, "newInstance",
        jsp_types.JSPBuilder, (jsp_types.JVrp,), jsp_vrp)

    # Set params here
    for (k,v) in solver.params
        println("Setting param: ", k, " to value ", v)
        JavaCall.jcall(jsp_builder, "setProperty", jsp_types.JSPBuilder,
            (JavaCall.JString, JavaCall.JString), k, v)
    end

    return JavaCall.jcall(jsp_builder, "buildAlgorithm",
                          jsp_types.JAlgorithm, ())
end

function jsprit_search_best_solution(jsp_algo, jsp_types::JspritJavaTypes)
    jsp_sols = JavaCall.jcall(jsp_algo, "searchSolutions",
                              jsp_types.JCollection, ())
    return JavaCall.jcall(jsp_types.JSolutions, "bestOf", jsp_types.JSolution,
                          (jsp_types.JCollection,), jsp_sols)
end

############################ RVRP SOLVER functions #########################

function solve(data::RvrpInstance, solver::JspritSolver)
    if !JavaCall.isloaded()
        setup_jvm()
    end
    computed_data = build_computed_data(data)
    jsp_types = JspritJavaTypes()
    jsp_vrp = jsprit_create_input(data, computed_data, jsp_types)
    jsp_algo = jsprit_create_algorithm(jsp_vrp, jsp_types, solver)
    jsp_sol = jsprit_search_best_solution(jsp_algo, jsp_types)
    rvrp_sol = jsprit_transform_solution(data, solver, computed_data,
                                         jsp_sol, jsp_types)
    return rvrp_sol
end

function supported_features(::Type{JspritSolver})
    features = BitSet()

    # Location based features  #
    # A location in jsprit has no time window
    # union!(features, HAS_OPENING_TIME_WINDOWS)
    # union!(features, HAS_MULTIPLE_OPENING_TIME_WINDOWS)
    # union!(features, HAS_FLEXIBLE_OPENING_TIME_WINDOWS)

    # Product based features #
    # union!(features, HAS_PRODUCT_CONFLICT_CLASSES)
    # union!(features, HAS_PRODUCT_PROHIBITED_PREDECESSOR_CLASSES)
    # union!(features, HAS_PRODUCT_PICKUPONLY_SHARING_CLASSES)
    # union!(features, HAS_PRODUCT_DELIVERYONLY_SHARING_CLASSES)
    # union!(features, HAS_PRODUCT_SHIPMENT_SHARING_CLASSES)
    union!(features, HAS_PRODUCT_PROPERTIES_REQUIREMENTS)
    union!(features, HAS_PRODUCT_CAPACITY_CONSUMPTIONS)
    union!(features, HAS_MULTIPLE_PRODUCT_CAPACITY_CONSUMPTIONS)

    # Request based features
    union!(features, HAS_SHIPMENT_REQUESTS)
    union!(features, HAS_PICKUPONLY_REQUESTS)
    union!(features, HAS_DELIVERYONLY_REQUESTS)
    union!(features, HAS_MAX_DURATION)
    union!(features, HAS_PICKUP_TIME_WINDOWS)
    union!(features, HAS_DELIVERY_TIME_WINDOWS)
    union!(features, HAS_MULTIPLE_PICKUP_TIME_WINDOWS)
    union!(features, HAS_MULTIPLE_DELIVERY_TIME_WINDOWS)

    # VehicleCategory based features
    union!(features, HAS_VEHICLE_CAPACITIES)
    union!(features, HAS_VEHICLE_PROPERTIES)
    union!(features, HAS_MULTIPLE_VEHICLE_CAPACITIES)
    union!(features, HAS_MULTIPLE_VEHICLE_PROPERTIES)

    # HomogeneousVehicleSet based features
    union!(features, HAS_TRAVEL_TIME_UNIT_COST)
    union!(features, HAS_SERVICE_TIME_UNIT_COST)
    union!(features, HAS_WAITING_TIME_UNIT_COST)
    union!(features, HAS_TRAVEL_DISTANCE_UNIT_COST)
    union!(features, HAS_MAX_NB_VEHICLES)
    union!(features, HAS_WORKING_TIME_WINDOW)
    union!(features, HAS_FIXED_COST_PER_VEHICLE)
    union!(features, HAS_OPEN_DEPARTURE)
    union!(features, HAS_OPEN_ARRIVAL)
    union!(features, HAS_ARRIVAL_DIFFERENT_FROM_DEPARTURE)

    # Instance based features
    union!(features, HAS_WORK_PERIODS)
    union!(features, HAS_MUTLIPLE_TRAVEL_TIME_PERIODS)
    union!(features, HAS_MULTIPLE_VEHICLE_CATEGORIES)
    union!(features, HAS_MULTIPLE_VEHICLE_SETS)

    return [features]
end
