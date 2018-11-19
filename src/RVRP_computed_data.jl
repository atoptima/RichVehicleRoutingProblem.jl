mutable struct RvrpComputedData
    # instance_id::String
    # pickup_ids::Vector{String}
    # delivery_ids::Vector{String}
    # depot_ids::Vector{String}
    # recharging_ids::Vector{String}
    location_id_2_index::Dict{String, Int}
    # product_category_id2Index::Dict{String, Int}
    # product_id2Index::Dict{String, Int}
    # request_id2Index::Dict{String, Int}
    vehicle_category_id_2_index::Dict{String, Int}
    # vehicle_set_id2Index::Dict{String, Int}
end

