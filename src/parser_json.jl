################################# JSON Parsers #################################
JSON2.@format Range begin
    lb => (default=0.0,)
    ub => (default=MAXNUMBER,)
end

JSON2.@format Flexibility begin
    # flexibility_level => (default=0,)
    fixed_price => (default=0.0,)
    unit_price => (default=0.0,)
end

JSON2.@format FlexibleRange begin
    # soft_range => (default=Range(),)
    hard_range => (default=Range(),)
    lb_flex => (default=Flexibility(),)
    ub_flex => (default=Flexibility(),)
end

JSON2.@format Location begin
    # id => (default="",)
    # index => (default=-1,)
    lat_y => (default=MAXNUMBER,)
    long_x => (default=MAXNUMBER,)
    opening_time_windows => (default=[Range()],)
    energy_fixed_cost => (default=0.0,)
    energy_unit_cost => (default=0.0,)
    energy_recharging_speeds => (default=Float64[],)
end

# JSON2.@format LocationGroup begin
#     # id => (default="",)
#     # location_ids => (default=String[],)
# end

JSON2.@format ProductCompatibilityClass begin
    # id => (default="",)
    conflict_compatib_class_ids => (default=String[],)
    prohibited_predecessor_compatib_class_ids => (default=String[],)
end

JSON2.@format ProductSharingClass begin
    # id => (default="",)
    infinite_pickup_availabitilies => (default=true,)
    infinite_delivery_availabitilies => (default=true,)
    pickup_availabitilies_at_location_ids => (default=Dict{String,Float64}(),)
    delivery_capacities_at_location_ids => (default=Dict{String,Float64}(),)
end

JSON2.@format ProductSpecificationClass begin
    # id => (default="",)
    capacity_consumptions => (default=Dict{String,Tuple{Float64,Float64}}(),)
    property_requirements => (default=Dict{String,Float64}(),)
end

JSON2.@format Request begin
    # id => (default="",)
    product_compatibility_class_id => (default="default_id",)
    product_sharing_class_id => (default="default_id",)
    product_specification_class_id => (default="default_id",)
    split_fulfillment => (default=false,)
    request_flexibility => (default=Flexibility(),)
    precedence_status => (default=0,)
    product_quantity_range => (default=Range(lb = 1, ub = 1),)
    pickup_location_group_id => (default="default_id",)
    delivery_location_group_id => (default="default_id",)
    pickup_service_time => (default=0.0,)
    delivery_service_time => (default=0.0,)
    max_duration => (default=MAXNUMBER,)
    duration_unit_cost => (default=0.0,)
    pickup_time_windows => (default=[FlexibleRange()],)
    delivery_time_windows => (default=[FlexibleRange()],)
end

JSON2.@format VehicleCategory begin
    # id => (default="",)
    capacity_measures => (default=VehicleCharacteristics(),)
    vehicle_properties => (default=VehicleCharacteristics(),)
    loading_option => (default=0,)
    energy_interval_lengths => (default=Float64[],)
end

JSON2.@format WorkPeriod begin
    active_window => (default=FlexibleRange(),)
    travel_distance_unit_cost => (default=0.0,)
    travel_time_unit_cost => (default=0.0,)
    service_time_unit_cost => (default=0.0,)
    waiting_time_unit_cost => (default=0.0,)
    fixed_cost_per_vehicle => (default=0.0,)
end

JSON2.@format HomogeneousVehicleSet begin
    # id => (default="",)
    vehicle_category_id => (default="default_id",)
    # departure_location_group_id => (default="",)
    # arrival_location_group_id => (default="",)
    work_periods => (default=[WorkPeriod()],)
    initial_energy_charge => (default=MAXNUMBER,)
    max_working_time => (default=MAXNUMBER,)
    max_travel_distance => (default=MAXNUMBER,)
    allow_shipment_over_multiple_work_periods => (default=true,)
    nb_of_vehicles_range => (default=FlexibleRange(),)
end

JSON2.@format RvrpInstance begin
    # id => (default="",)
    distance_mode => (default=0,)
    coordinate_mode => (default=0,)
    # travel_matrix_periods => (default=[Range()],)
    # period_to_matrix_id => (default=Dict{Range,String}(Range() => "default_mat"),)
    travel_time_matrices => (default=Dict{String,Array{Float64,2}}(),)
    travel_distance_matrices => (default=Dict{String,Array{Float64,2}}(),)
    energy_consumption_matrices => (default=Dict{String,Array{Float64,2}}(),)
    locations => (default=Location[],)
    location_groups => (default=LocationGroup[],)
    product_compatibility_classes => (default=ProductCompatibilityClass[],)
    product_sharing_classes => (default=ProductSharingClass[],)
    product_specification_classes => (default=ProductSpecificationClass[],)
    requests => (default=Request[],)
    vehicle_categories => (default=VehicleCategory[],)
    vehicle_sets => (default=HomogeneousVehicleSet[],)
end

function parse_to_json(data::RvrpInstance, file_path::String)
    json2_string = JSON2.write(data)
    io = open(file_path, "w")
    write(io, json2_string * "\n")
    close(io)
end

parse_from_json_string(s::String) = JSON2.read(s, RvrpInstance)

function parse_from_json(file_path::String)
    io = open(file_path, "r")
    s = read(io, String)
    close(io)
    return parse_from_json_string(s)
end
