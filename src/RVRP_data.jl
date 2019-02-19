struct Range
    lb::Float64 # to represent the normal lowerbound
    ub::Float64 # to represent the normal upperbound
end

struct Flexibility
    flexibility_level::Int # in level zero the nominal value is mandatory, in level k the nominal value can unsatisfyied if there was no feasbile solutions to the constraints of level 0 to k-1 that satisfy this level k contraint; a negative level means that the nominal value is optional, i.e. it must be statisfyied only it improves the economic value of the solution.
    fixed_price::Float64 # fixed_cost for not satisfying the nominal value, or fixed reward for satisfying it if it was optional
    unit_price::Float64 # while respecting the hard value, this represent a cost per unit away from the moninal value, or reward per unit away from the moninal value if the nominal value was optional
end

struct FlexibleRange
    soft_range::Range
    hard_range::Range
    lb_flex::Flexibility
    ub_flex::Flexibility
end

mutable struct Location # Location where can be a Depot, Pickup, Delivery, Recharging, ..., or a combination of those services
    id::String
    index::Int # used for matrices such as travel distance, travel time ...
    lat_y::Float64
    long_x::Float64
    opening_time_windows::Vector{Range}
    energy_fixed_cost::Float64 # an entry fee
    energy_unit_cost::Float64 # recharging cost per unit of energy
    energy_recharging_speeds::Vector{Float64} # if recharging in this location: the i-th speep is associted to the i-th energy interval defined for the vehicle
end

mutable struct LocationGroup # optionally defined to identify a set of locations with some commonalities, such as all possible pickups for a request
    id::String
    location_ids::Vector{String}
end

mutable struct ProductCompatibilityClass # To define preceedence or conflict restriction between requested products
    id::String
    conflict_compatib_class_ids::Vector{String}
    prohibited_predecessor_compatib_class_ids::Vector{String}
end

mutable struct ProductSharingClass # To define global availabitily restrictions for a product that is shared between different requests
    id::String
    restricted_pickup_availabitilies::Bool
    restricted_delivery_capacities::Bool
    pickup_availabitilies_at_location_ids::Dict{String,Float64} # defined only if pickup locations have a restricted capacity; provides capcity for each pickup location where the product is avaiblable in restricted capacity
    delivery_capacities_at_location_ids::Dict{String,Float64} # defined only if delivery locations have a restricted capacity; provides capcity for each delivery location where the product can be delivered in restricted capacity
end

mutable struct ProductSpecificationClass # To define capacity consumption of a requested product
    id::String
    capacity_consumptions::Dict{String,Tuple{Float64,Float64}} # to quantify the vehicle/compartment capacity that is used for accomodating lot-sizes of the request along several independant capacity measures whose string id key are in the dictionary: as weight, value, volume; for each such key, the capacity used is the float coef 2 * roundup(quantity / shipment_lot_size = float coef 1)
    property_requirements::Dict{String,Float64} # to check if the vehicle has the property of accomodating the request: yes if request requirement <= vehicle property capacity for each string id referenced requirement
end

mutable struct Request # can be
    # a shipment from a depot to a delivery location, or
    # a shipment from a pickup location to a depot, or
    # a delivery of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a pickup of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a shipment from a given pickup location to a given delivery location of a product that is specific to the request, or
    # a shipment from a given pickup location to any location of a group delivery locations of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to a given delivery location of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to any location of a group delivery locations of a product that is specific to the request.
    id::String
    request_type::Int # 0 : pickup and delivery, 1: pickup only (delivery info is ignored) 2: delivery only (pickup info is ignored)
    product_compatibility_class_id::String
    product_sharing_class_id::String
    product_specification_class_id::String
    split_fulfillment::Bool  # true if split delivery/pickup is allowed, default is false
    request_flexibility::Flexibility
    precedence_status::Int # default = 0 = product predecessor restrictions;  1 = after all pickups, 2 =  after all deliveries.
    product_quantity_range::Range # of the request
    pickup_location_group_id::String # empty string for delivery-only requests. LocationGroup representing alternatives for pickup, otherwise.
    delivery_location_group_id::String # empty string for pickup-only requests. LocationGroup representing alternatives for delivery, otherwise.
    pickup_service_time::Float64 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 # used to measure post-cleaning or unloading time for instance
    max_duration::Float64 # to enforce a max duration between pickup and delivery
    duration_unit_cost::Float64 # to measure the cost of the time spent between pickup and delivery
    pickup_time_windows::Vector{FlexibleRange}
    delivery_time_windows::Vector{FlexibleRange}
end

mutable struct VehicleCharacteristics
    of_vehicle::Dict{String,Float64} # defined only if measured at the vehicle level; for string id key associated with properties or capacity measures that need to be checked on the vehicle, as for instance weight, value, volume
    of_compartments::Dict{String,Dict{String,Float64}}  # defined only if measured at the compartment level; for string id key associated with properties or capacity measures that need to be checked on the vehicle, as for instance weight, value, volume, ... For each such property, the Dictionary specifies the capacity for each compartment id key.
end

mutable struct VehicleCategory
    id::String
    capacities::VehicleCharacteristics
    properties::VehicleCharacteristics
    loading_option::Int # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    energy_interval_lengths::Vector{Float64} # at index i, the length of the i-th energy interval. empty if no recharging.
end

mutable struct CostPeriod
    period::Range

    # CostSpecification
    fixed_cost::Float64
    travel_distance_unit_cost::Float64 # may depend on both driver and vehicle
    travel_time_unit_cost::Float64 # may depend on both driver and vehicle
    service_time_unit_cost::Float64
    waiting_time_unit_cost::Float64
end

mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String
    route_mode::Int # 0 closed at departure and arrival, 1 open at arrival, 2 open at departure, 3 open at both depature and arrival
    vehicle_category_id::String
    cost_periods::Vector{CostPeriod}
    departure_location_group_id::String # Vehicle routes start from one of the depot locations in the group
    arrival_location_group_id::String # Vehicle routes end at one of the depot locations in the group
    # work_periods::Vector{WorkPeriod} # Define the work periods for which vehicles can be used, with some flexibility, does not have to be contiguous
    work_periods::Vector{FlexibleRange} # Define the work periods for which vehicles can be used, with some flexibility, does not have to be contiguous
    initial_energy_charge::Float64
    max_working_time::Float64 # within each work period
    max_travel_distance::Float64 # within each work period
    allow_shipment_over_multiple_work_periods::Bool # true if the vehicles do not need to complete all their requests by the end of each time period of the planning
    nb_of_vehicles_range::FlexibleRange
end

mutable struct TravelSpecification
   id::String
   travel_time_matrix::Array{Float64,2}
   travel_distance_matrix::Array{Float64,2}
   energy_consumption_matrix::Array{Float64,2}
end

mutable struct TravelPeriod
   period::Range
   travel_specification_id::String
end

mutable struct RvrpInstance
    id::String
    distance_mode::Int # 0 (default) - long and lat, 1 - x and y
    coordinate_mode::Int # 0 (default) user-defined, 1 - euc, 2 - manhattan, 3 - gps
    travel_specifications::Vector{TravelSpecification}
    travel_periods::Vector{TravelPeriod}
    locations::Vector{Location}
    location_groups::Vector{LocationGroup}
    product_compatibility_classes::Vector{ProductCompatibilityClass}
    product_sharing_classes::Vector{ProductSharingClass}
    product_specification_classes::Vector{ProductSpecificationClass}
    requests::Vector{Request}
    vehicle_categories::Vector{VehicleCategory}
    vehicle_sets::Vector{HomogeneousVehicleSet}
end

################ Default-valued constructors #################
function Range(; lb = 0.0,
               ub = MAXNUMBER)
    return Range(lb, ub)
end
single_val_range(v::Real) = Range(v, v)

function Flexibility(; flexibility_level = 0,
                     fixed_price = 0.0,
                     unit_price = 0.0)
    return Flexibility(flexibility_level, fixed_price, unit_price)
end

function FlexibleRange(; soft_range = Range(),
                       hard_range=Range(),
                       lb_flex = Flexibility(),
                       ub_flex = Flexibility())
    return FlexibleRange(soft_range, hard_range, lb_flex, ub_flex)
end

simple_flex_range(hard_lb::Float64,
                  soft_lb::Float64,
                  soft_ub::Float64,
                  hard_ub::Float64,
                  soft_violation_price::Float64) =
    FlexibleRange(Range(soft_lb, soft_ub),
                  Range(hard_lb, hard_ub),
                  Flexibility(0,0.0,soft_violation_price),
                  Flexibility(0,0.0,soft_violation_price))

function Location(;
                  id = "",
                  index = -1,
                  lat_y = -1.0,
                  long_x = -1.0,
                  opening_time_windows = [Range()],
                  energy_fixed_cost = 0.0,
                  energy_unit_cost = 0.0,
                  energy_recharging_speeds = Float64[])
    return Location(id, index, lat_y, long_x, opening_time_windows, energy_fixed_cost, energy_unit_cost, energy_recharging_speeds)
end

function LocationGroup(; id = "",
                       location_ids = String[])
    return LocationGroup(id, location_ids)
end

function ProductCompatibilityClass(; id = "",
                                   conflict_compatib_class_ids = String[],
                                   prohibited_predecessor_compatib_class_ids = String[])
    return ProductCompatibilityClass(id, conflict_compatib_class_ids,
                                     prohibited_predecessor_compatib_class_ids)
end

function ProductSharingClass(; id = "",
                             infinite_pickup_availabitilies = true,
                             infinite_delivery_availabitilies = true,
                             pickup_availabitilies_at_location_ids = Dict{String,Float64}(),
                             delivery_capacities_at_location_ids = Dict{String,Float64}())
    return ProductSharingClass(id, infinite_pickup_availabitilies,
                               infinite_delivery_availabitilies,
                               pickup_availabitilies_at_location_ids,
                               delivery_capacities_at_location_ids)
end

function ProductSpecificationClass(; id = "",
                                   capacity_consumptions = Dict{String,Tuple{Float64,Float64}}(),
                                   property_requirements = Dict{String,Float64}())
    return ProductSpecificationClass(id, capacity_consumptions, property_requirements)
end

function Request(; id = "",
                 request_type = 0,
                 product_compatibility_class_id = "default_id",
                 product_sharing_class_id = "default_id",
                 product_specification_class_id = "default_id",
                 split_fulfillment = false,
                 request_flexibility = Flexibility(),
                 precedence_status = 0,
                 product_quantity_range = Range(lb = 1, ub = 1),
                 pickup_location_group_id = "default_id",
                 delivery_location_group_id = "default_id",
                 pickup_service_time = 0.0,
                 delivery_service_time = 0.0,
                 max_duration = MAXNUMBER,
                 duration_unit_cost = 0.0,
                 pickup_time_windows = [FlexibleRange()],
                 delivery_time_windows = [FlexibleRange()])
    return Request(id,
                   request_type,
                   product_compatibility_class_id,
                   product_sharing_class_id,
                   product_specification_class_id,
                   split_fulfillment,
                   request_flexibility,
                   precedence_status,
                   product_quantity_range,
                   pickup_location_group_id,
                   delivery_location_group_id,
                   pickup_service_time,
                   delivery_service_time,
                   max_duration,
                   duration_unit_cost,
                   pickup_time_windows,
                   delivery_time_windows)
end

function VehicleCharacteristics(;of_vehicle = Dict{String,Float64}(),
                                of_compartments = Dict{String,Dict{String,Float64}}())
    return VehicleCharacteristics(of_vehicle,
                                  of_compartments)
end

function VehicleCategory(; id = "",
                         capacities = VehicleCharacteristics(),
                         properties = VehicleCharacteristics(),
                         loading_option = 0,
                         energy_interval_lengths = Float64[])
    return VehicleCategory(id,
                           capacities,
                           properties,
                           loading_option,
                           energy_interval_lengths)
end

function CostPeriod(; period = Range(),
                     fixed_cost = 0.0,
                     travel_distance_unit_cost = 0.0,
                     travel_time_unit_cost = 0.0,
                     service_time_unit_cost = 0.0,
                     waiting_time_unit_cost = 0.0)
    return CostPeriod(period, fixed_cost, travel_distance_unit_cost,
                       travel_time_unit_cost, service_time_unit_cost,
                       waiting_time_unit_cost)
end

function HomogeneousVehicleSet(; id = "",
                               route_mode = 0,
                               departure_location_group_id = "",
                               arrival_location_group_id = "",
                               vehicle_category_id = "default_id",
                               cost_periods = [CostPeriod()],
                               work_periods = [FlexibleRange()],
                               initial_energy_charge = MAXNUMBER,
                               max_working_time = MAXNUMBER,
                               max_travel_distance = MAXNUMBER,
                               allow_shipment_over_multiple_work_periods = false,
                               nb_of_vehicles_range = FlexibleRange())
    return HomogeneousVehicleSet(
        id, route_mode, vehicle_category_id, cost_periods, departure_location_group_id,
        arrival_location_group_id, work_periods, initial_energy_charge,
        max_working_time, max_travel_distance,
        allow_shipment_over_multiple_work_periods, nb_of_vehicles_range)
end

function TravelSpecification(; id = "",
                            travel_time_matrix = Array{Float64,2}(undef,0,0),
                            travel_distance_matrix = Array{Float64,2}(undef,0,0),
                            energy_consumption_matrix = Array{Float64,2}(undef,0,0))
    return TravelSpecification(id,
                            travel_time_matrix,
                            travel_distance_matrix,
                            energy_consumption_matrix)
end

function TravelPeriod(; period = Range(),
                      travel_specification_id = "")
    return TravelPeriod(period,
                        travel_specification_id)
end

function RvrpInstance(; id = "",
                      distance_mode = 0,
                      coordinate_mode = 0,
                      travel_specifications = TravelSpecification[],
                      travel_periods = TravelPeriod[],
                      locations = Location[],
                      location_groups = LocationGroup[],
                      product_compatibility_classes = ProductCompatibilityClass[],
                      product_sharing_classes = ProductSharingClass[],
                      product_specification_classes = ProductSpecificationClass[],
                      requests = Request[],
                      vehicle_categories = VehicleCategory[],
                      vehicle_sets = HomogeneousVehicleSet[])
    return RvrpInstance(id,
                        distance_mode,
                        coordinate_mode,
                        travel_specifications,
                        travel_periods,
                        locations,
                        location_groups,
                        product_compatibility_classes,
                        product_sharing_classes,
                        product_specification_classes,
                        requests,
                        vehicle_categories,
                        vehicle_sets)
end
