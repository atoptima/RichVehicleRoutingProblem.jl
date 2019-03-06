Base.@kwdef struct Range
    lb::Float64 = 0.0 # to represent the normal lowerbound
    ub::Float64 = MAXNUMBER # to represent the normal upperbound
end
Range(v::Real) = Range(v, v)

Base.@kwdef struct Flexibility
    flexibility_level::Int = 0 # in level zero the nominal value is mandatory, in level k the nominal value can unsatisfyied if there was no feasbile solutions to the constraints of level 0 to k-1 that satisfy this level k contraint; a negative level means that the nominal value is optional, i.e. it must be statisfyied only it improves the economic value of the solution.
    fixed_price::Float64 = 0.0 # fixed_cost for not satisfying the nominal value, or fixed reward for satisfying it if it was optional
    unit_price::Float64 = 0.0 # while respecting the hard value, this represent a cost per unit away from the moninal value, or reward per unit away from the moninal value if the nominal value was optional
end

Base.@kwdef struct FlexibleRange
    soft_range::Range = Range()
    hard_range::Range = Range()
    lb_flex::Flexibility = Flexibility()
    ub_flex::Flexibility = Flexibility()
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

Base.@kwdef mutable struct Location # Location where can be a Depot, Pickup, Delivery, Recharging, ..., or a combination of those services
    id::String = ""
    index::Int = -1 # used for matrices such as travel distance, travel time ...
    lat_y::Float64 = -1.0
    long_x::Float64 = -1.0
    opening_time_windows::Vector{Range} = [Range()]
    energy_fixed_cost::Float64 = 0.0 # an entry fee
    energy_unit_cost::Float64 = 0.0 # recharging cost per unit of energy
    energy_recharging_speeds::Vector{Float64} = Float64[] # if recharging in this location: the i-th speep is associted to the i-th energy interval defined for the vehicle
end

Base.@kwdef mutable struct LocationGroup # optionally defined to identify a set of locations with some commonalities, such as all possible pickups for a request
    id::String = ""
    location_ids::Vector{String} = String[]
end

Base.@kwdef mutable struct ProductCompatibilityClass # To define preceedence or conflict restriction between requested products
    id::String = ""
    conflict_compatib_class_ids::Vector{String} = String[]
    prohibited_predecessor_compatib_class_ids::Vector{String} = String[]
end

Base.@kwdef mutable struct ProductSharingClass # To define global availabitily restrictions for a product that is shared between different requests
    id::String = ""
    restricted_pickup_availabitilies::Bool = true
    restricted_delivery_capacities::Bool = true
    pickup_availabitilies_at_location_ids::Dict{String,Float64} = Dict{String,Float64}() # defined only if pickup locations have a restricted capacity; provides capcity for each pickup location where the product is avaiblable in restricted capacity
    delivery_capacities_at_location_ids::Dict{String,Float64} = Dict{String,Float64}() # defined only if delivery locations have a restricted capacity; provides capcity for each delivery location where the product can be delivered in restricted capacity
end

Base.@kwdef mutable struct ProductSpecificationClass # To define capacity consumption of a requested product
    id::String = ""
    capacity_consumptions::Dict{String,Tuple{Float64,Float64}} = Dict{String,Tuple{Float64,Float64}}() # to quantify the vehicle/compartment capacity that is used for accomodating lot-sizes of the request along several independant capacity measures whose string id key are in the dictionary: as weight, value, volume; for each such key, the capacity used is the float coef 2 * roundup(quantity / shipment_lot_size = float coef 1)
    property_requirements::Dict{String,Float64} = Dict{String,Float64}() # to check if the vehicle has the property of accomodating the request: yes if request requirement <= vehicle property capacity for each string id referenced requirement
end

Base.@kwdef mutable struct Request # can be
    # a shipment from a depot to a delivery location, or
    # a shipment from a pickup location to a depot, or
    # a delivery of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a pickup of a product that is shared by several requests, some of which are supplying the product while others are demanding the product, or
    # a shipment from a given pickup location to a given delivery location of a product that is specific to the request, or
    # a shipment from a given pickup location to any location of a group delivery locations of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to a given delivery location of a product that is specific to the request, or
    # a shipment from any location of a group pickup locations to any location of a group delivery locations of a product that is specific to the request.

    id::String = ""
    request_type::Int = 0 # 0 : pickup and delivery, 1: pickup only (delivery info is ignored) 2: delivery only (pickup info is ignored)
    product_compatibility_class_id::String = "default_id"
    product_sharing_class_id::String = "default_id"
    product_specification_class_id::String = "default_id"
    split_fulfillment::Bool = false # true if split delivery/pickup is allowed, default is false
    request_flexibility::Flexibility = Flexibility()
    precedence_status::Int = 0 # default = 0 = product predecessor restrictions;  1 = after all pickups, 2 =  after all deliveries.
    product_quantity_range::Range = Range(1) # of the request
    pickup_location_group_id::String = "default_id" # empty string for delivery-only requests. LocationGroup representing alternatives for pickup, otherwise.
    delivery_location_group_id::String = "default_id" # empty string for pickup-only requests. LocationGroup representing alternatives for delivery, otherwise.
    pickup_service_time::Float64 = 0.0 # used to measure pre-cleaning or loading time for instance
    delivery_service_time::Float64 = 0.0 # used to measure post-cleaning or unloading time for instance
    max_duration::Float64 = MAXNUMBER # to enforce a max duration between pickup and delivery
    duration_unit_cost::Float64 = 0.0 # to measure the cost of the time spent between pickup and delivery
    pickup_time_windows::Vector{FlexibleRange} = [FlexibleRange()]
    delivery_time_windows::Vector{FlexibleRange} = [FlexibleRange()]
end

Base.@kwdef mutable struct VehicleCharacteristics
    of_vehicle::Dict{String,Float64} = Dict{String,Float64}() # defined only if measured at the vehicle level; for string id key associated with properties or capacity measures that need to be checked on the vehicle, as for instance weight, value, volume
    of_compartments::Dict{String,Dict{String,Float64}} = Dict{String,Float64}() # defined only if measured at the compartment level; for string id key associated with properties or capacity measures that need to be checked on the vehicle, as for instance weight, value, volume, ... For each such property, the Dictionary specifies the capacity for each compartment id key.
end

Base.@kwdef mutable struct VehicleCategory
    id::String = ""
    capacities::VehicleCharacteristics = VehicleCharacteristics()
    properties::VehicleCharacteristics = VehicleCharacteristics()
    loading_option::Int = 0 # 0 = no restriction (=default), 1 = one request per compartment, 2 = removable compartment separation (note that product conflicts are measured within a compartment)
    energy_interval_lengths::Vector{Float64} = Float64[] # at index i, the length of the i-th energy interval. empty if no recharging.
    
end

Base.@kwdef mutable struct CostPeriod
    period::Range = Range()
    # CostSpecification
    fixed_cost::Float64 = 0.0
    travel_distance_unit_cost::Float64 = 0.0 # may depend on both driver and vehicle
    travel_time_unit_cost::Float64 = 0.0 # may depend on both driver and vehicle
    service_time_unit_cost::Float64 = 0.0
    waiting_time_unit_cost::Float64 = 0.0
end

Base.@kwdef mutable struct HomogeneousVehicleSet # vehicle type in optimization instance.
    id::String = ""
    route_mode::Int = 0 # 0 closed at departure and arrival, 1 open at arrival, 2 open at departure, 3 open at both depature and arrival
    vehicle_category_id::String = "default_id"
    cost_periods::Vector{CostPeriod} = [CostPeriod()]
    departure_location_group_id::String = "" # Vehicle routes start from one of the depot locations in the group
    arrival_location_group_id::String = "" # Vehicle routes end at one of the depot locations in the group
    work_periods::Vector{FlexibleRange} = [FlexibleRange()] # Define the work periods for which vehicles can be used, with some flexibility, does not have to be contiguous
    initial_energy_charge::Float64 = MAXNUMBER
    max_working_time::Float64 = MAXNUMBER # within each work period
    max_travel_distance::Float64 = MAXNUMBER # within each work period
    allow_shipment_over_multiple_work_periods::Bool = false # true if the vehicles do not need to complete all their requests by the end of each time period of the planning
    nb_of_vehicles_range::FlexibleRange = FlexibleRange()
end

Base.@kwdef mutable struct TravelSpecification
   id::String = ""
   travel_time_matrix::Array{Float64,2} = Array{Float64,2}(undef, 0, 0)
   travel_distance_matrix::Array{Float64,2} = Array{Float64,2}(undef, 0, 0)
   energy_consumption_matrix::Array{Float64,2} = Array{Float64,2}(undef, 0, 0)
end

Base.@kwdef mutable struct TravelPeriod
   period::Range = Range()
   travel_specification_id::String = ""
end

Base.@kwdef mutable struct RvrpInstance
    id::String = ""
    distance_mode::Int = 0 # 0 (default) - long and lat, 1 - x and y
    coordinate_mode::Int = 0 # 0 (default) user-defined, 1 - euc, 2 - manhattan, 3 - gps
    travel_specifications::Vector{TravelSpecification} = TravelSpecification[]
    travel_periods::Vector{TravelPeriod} = TravelPeriod[]
    locations::Vector{Location} = Location[]
    location_groups::Vector{LocationGroup} = LocationGroup[]
    product_compatibility_classes::Vector{ProductCompatibilityClass} = ProductCompatibilityClass[]
    product_sharing_classes::Vector{ProductSharingClass} = ProductSharingClass[]
    product_specification_classes::Vector{ProductSpecificationClass} = ProductSpecificationClass[]
    requests::Vector{Request} = Request[]
    vehicle_categories::Vector{VehicleCategory} = VehicleCategory[]
    vehicle_sets::Vector{HomogeneousVehicleSet} = HomogeneousVehicleSet[]
end
