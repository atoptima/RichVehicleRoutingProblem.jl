mutable struct RvrpComputedData
    # instance_id::String
    # pickup_ids::Vector{String}
    # delivery_ids::Vector{String}
    # depot_ids::Vector{String}
    # recharging_ids::Vector{String}
    location_id_2_index::Dict{String, Int}
    location_group_id_2_index::Dict{String, Int}
    product_specification_class_id_2_index::Dict{String, Int}
    # request_id2Index::Dict{String, Int}
    vehicle_category_id_2_index::Dict{String, Int}
    vehicle_set_id_2_index::Dict{String, Int}
    capacity_id_2_index::Dict{String, Int}
    property_id_2_index::Dict{String, Int}
    travel_specification_id_2_index::Dict{String, Int}
    features::BitSet
    uses_default_vehicle_category::Bool
end
