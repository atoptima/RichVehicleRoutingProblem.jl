function generate_symmetric_distance_matrix(xs::Vector{T},
                                            ys::Vector{T}) where T <: Real
    @assert length(xs) == length(ys)
    n = length(xs)
    matrix = Matrix{Float64}(undef, n, n)
    for j in 1:n
        matrix[j,j] = 0.0
        for i in j+1:n
            matrix[i,j] = matrix[j,i] = sqrt((xs[j]-xs[i])^2 + (ys[j]-ys[i])^2)
        end
    end
    return matrix
end

function is_symetric(mat::Array{Float64,2})
    @assert size(mat, 1) == size(mat, 2)
    for j in 1:size(mat, 1)
        for i in j+1:size(mat, 1)
            if mat[i,j] != mat[j,i]
                return false
            end
        end
    end
    return true
end

function set_indices(data::RvrpInstance)
    for loc_idx in 1:length(data.locations)
        data.locations[loc_idx].index = loc_idx
    end
end

function build_computed_data(data::RvrpInstance)
    location_id_2_index = Dict{String,Int}(
        data.locations[i].id => i for i in 1:length(data.locations)
    )
    location_group_id_2_index = Dict{String,Int}(
        data.location_groups[i].id => i for i in 1:length(data.location_groups)
    )
    product_specification_class_id_2_index = Dict{String,Int}(
        data.product_specification_classes[i].id => i for i in 1:length(data.product_specification_classes)
    )
    vehicle_category_id_2_index = Dict{String,Int}(
        data.vehicle_categories[i].id => i for i in 1:length(data.vehicle_categories)
    )
    return RvrpComputedData(
        location_id_2_index, location_group_id_2_index,
        product_specification_class_id_2_index, vehicle_category_id_2_index
    )
end

function create_singleton_location_groups(locations::Vector{Location})
    return [LocationGroup(
        id = string(l.id, "_loc_group"),
        location_ids = [l.id]
    ) for l in locations]
end

function get_capacity_consumptions(req::Request, product_specification_classes::Vector{ProductSpecificationClass}, computed_data::RvrpComputedData)
    quantity = req.product_quantity_range.ub
    product_specification_class_id = req.product_specification_class_id
    product_specification_class = product_specification_classes[computed_data.product_specification_class_id_2_index[product_specification_class_id]]
    c = [
        ceil(quantity/v[2]) * v[1]
        for (k,v) in product_specification_class.capacity_consumptions
    ]
    return c
end

function preprocess_instance(data::RvrpInstance)
    # push!(data.locations, Location(id = "default_id"))
    # push!(data.location_groups, LocationGroup(id = "default_id"))
    push!(data.product_compatibility_classes,
          ProductCompatibilityClass(id = "default_id"))
    push!(data.product_sharing_classes,
          ProductSharingClass(id = "default_id"))
    push!(data.product_specification_classes,
          ProductSpecificationClass(id = "default_id"))
    # push!(data.requests, Request(id = "default_id"))
    push!(data.vehicle_categories, VehicleCategory(id = "default_id"))
    # push!(data.vehicle_sets, HomogeneousVehicleSet(id = "default_id"))
end
