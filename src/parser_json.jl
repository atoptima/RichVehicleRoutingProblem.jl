################################# JSON Parsers #################################
JSON2.@format Range begin
    hard_min => (default=0.0,)
    soft_min => (default=0.0,)
    soft_max => (default=typemax(Int32),)
    hard_max => (default=typemax(Int32),)
    flat_unit_price => (default=0.0,)
    shortage_extra_unit_price => (default=0.0,)
    excess_extra_unit_price => (default=0.0,)
end

JSON2.@format Location begin
    id => (default="",)
    index => (default=-1,)
    x_coord => (default=-1.0,)
    y_coord => (default=-1.0,)
    opening_time_windows => (default=[Range()],)
    access_time => (default=0.0,)
    energy_fixed_cost => (default=0.0,)
    energy_unit_cost => (default=0.0,)
    energy_recharging_speeds => (default=Float64[],)
end

JSON2.@format LocationGroup begin
    id => (default="",)
    location_ids => (default=String[],)
end

JSON2.@format ProductCategory begin
    id => (default="",)
    conflicting_product_ids => (default=String[],)
    prohibited_predecessor_product_ids => (default=String[],)
end

JSON2.@format SpecificProduct begin
    id => (default="",)
    product_category_id => (default="",)
    pickup_availabitilies_at_location_ids => (default=Dict{String,Float64}(),)
    delivery_capacities_at_location_ids => (default=Dict{String,Float64}(),)
end

JSON2.@format Request begin
    id => (default="",)
    specific_product_id => (default="",)
    split_fulfillment => (default=false,)
    precedence_status => (default=0,)
    semi_mantadory => (default=false,)
    product_quantity_range => (default=Range(),)
    shipment_capacity_consumption => (default=Float64[],)
    shipment_property_requirements => (default=Dict{Int,Float64}(),)
    pickup_location_group_id => (default="",)
    pickup_location_id => (default="",)
    delivery_location_group_id => (default="",)
    delivery_location_id => (default="",)
    pickup_service_time => (default=0.0,)
    delivery_service_time => (default=0.0,)
    max_duration => (default=typemax(Int32),)
    duration_unit_cost => (default=0.0,)
    pickup_time_windows => (default=[Range()],)
    delivery_time_windows => (default=[Range()],)
end

JSON2.@format VehicleCategory begin
    id => (default="",)
    compartment_capacities => (default=Array{Float64,2}(undef, 0, 0),)
    vehicle_properties => (default=Dict{Int,Float64}(),)
    compartments_properties => (default=Dict{Int,Vector{Float64}}(),)
    energy_interval_lengths => (default=Float64[],)
    loading_option => (default=0,)
end

JSON2.@format HomogeneousVehicleSet begin
    id => (default="",)
    vehicle_category_id => (default="",)
    departure_location_group_id => (default="",)
    departure_location_id => (default="",)
    arrival_location_group_id => (default="",)
    arrival_location_id => (default="",)
    working_time_window => (default=Range(),)
    travel_distance_unit_cost => (default=0.0,)
    travel_time_unit_cost => (default=0.0,)
    service_time_unit_cost => (default=0.0,)
    waiting_time_unit_cost => (default=0.0,)
    initial_energy_charge => (default=typemax(Int32),)
    nb_of_vehicles_range => (default=Range(),)
    max_working_time => (default=typemax(Int32),)
    max_travel_distance => (default=typemax(Int32),)
    allow_ongoing => (default=false,)
end

JSON2.@format RvrpInstance begin
    id => (default="",)
    travel_distance_matrix => (default=Array{Float64,2}(undef,0,0),)
    travel_time_matrix => (default=Array{Float64,2}(undef,0,0),)
    energy_consumption_matrix => (default=Array{Float64,2}(undef,0,0),)
    locations => (default=Location[],)
    location_groups => (default=LocationGroup[],)
    product_categories => (default=ProductCategory[],)
    specific_products => (default=SpecificProduct[],)
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

