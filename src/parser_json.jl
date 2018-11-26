################################# JSON Parsers #################################
JSON2.@format Range begin
    lb => (default=0.0,)
    ub => (default=typemax(Int32),)
end

JSON2.@format Flexibility begin
    flexibility_level => (default=0,)
    fixed_price => (default=0.0,)
    unit_price => (default=0.0,)
end

JSON2.@format FlexibleRange begin
    soft_range => (default=Range(),)
    hard_range => (default=Range(),)
    lb_flex => (default=Flexibility(),)
    ub_flex => (default=Flexibility(),)
end

JSON2.@format Location begin
    id => (default="",)
    index => (default=-1,)
    latitude => (default=-1.0,)
    longitude => (default=-1.0,)
    opening_time_windows => (default=[Range()],)
    energy_fixed_cost => (default=0.0,)
    energy_unit_cost => (default=0.0,)
    energy_recharging_speeds => (default=Float64[],)
end

JSON2.@format LocationGroup begin
    id => (default="",)
    location_ids => (default=String[],)
end


JSON2.@format ProductCompatibilityClass begin
    id => (default="",)
    conflict_compatib_class_ids => (default=String[],)
    prohibited_predecessor_compatib_class_ids => (default=String[],)
end

JSON2.@format ProductSharingClass begin
    id => (default="",)
    pickup_availabitilies_at_location_ids => (default=Dict{String,Float64}(),)
    delivery_capacities_at_location_ids => (default=Dict{String,Float64}(),)
end

JSON2.@format ProductSpecificationClass begin
    id => (default="",)
    capacity_consumptions => (default=Dict{String,Tuple{Float64,Float64}}(),)
    property_requirements => (default=Dict{String,Float64}(),)
end

JSON2.@format Request begin
    id => (default="",)
    product_compatibility_class_id => (default="",)
    product_sharing_class_id => (default="",)
    product_specification_class_id => (default="",)
    split_fulfillment => (default=false,)
    request_flexibility => (default=Flexibility(),)
    precedence_status => (default=0,)
    product_quantity_range => (default=Range(),)
    pickup_location_group_id => (default="",)
    delivery_location_group_id => (default="",)
    pickup_service_time => (default=0.0,)
    delivery_service_time => (default=0.0,)
    max_duration => (default=typemax(Int32),)
    duration_unit_cost => (default=0.0,)
    pickup_time_windows => (default=[FlexibleRange()],)
    delivery_time_windows => (default=[FlexibleRange()],)
end

JSON2.@format VehicleCategory begin
    id => (default="",)
    vehicle_capacities => (default=Dict{String,Float64}(),)
    compartment_capacities => (default=Dict{String,Dict{String,Float64}}(),)
    vehicle_properties => (default=Dict{String,Float64}(),)
    compartments_properties => (default=Dict{String,Dict{String,Float64}}(),)
    loading_option => (default=0,)
    energy_interval_lengths => (default=Float64[],)
end

JSON2.@format HomogeneousVehicleSet begin
    id => (default="",)
    vehicle_category_id => (default="",)
    departure_location_group_id => (default="",)
    arrival_location_group_id => (default="",)
    working_time_window => (default=Range(),)
    travel_distance_unit_cost => (default=0.0,)
    travel_time_unit_cost => (default=0.0,)
    service_time_unit_cost => (default=0.0,)
    waiting_time_unit_cost => (default=0.0,)
    initial_energy_charge => (default=typemax(Int32),)
    fixed_cost_per_vehicle => (default=0.0,)
    max_working_time => (default=typemax(Int32),)
    max_travel_distance => (default=typemax(Int32),)
    allow_shipment_over_multiple_work_periods => (default=false,)
    nb_of_vehicles_range => (default=FlexibleRange(),)
end

JSON2.@format RvrpInstance begin
    id => (default="",)
    travel_matrix_periods => (default=Range[],)
    period_to_matrix_id => (default=Dict{Range,String}(),)
    travel_time_matrices => (default=Dict{String,Array{Float64,2}}(),)
    travel_distance_matrices => (default=Dict{String,Array{Float64,2}}(),)
    energy_consumption_matrices => (default=Dict{String,Array{Float64,2}}(),)
    work_periods => (default=Range[],)
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

function parse_from_json_string(s::String)
    data = JSON2.read(s, RvrpInstance)
    set_indices(data)
    return data
end

function parse_from_json(file_path::String)
    io = open(file_path, "r")
    s = read(io, String)
    close(io)
    return parse_from_json_string(s)
end

