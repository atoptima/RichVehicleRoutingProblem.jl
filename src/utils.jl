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

function set_indices(data::RvrpInstance)
    for loc_idx in 1:length(data.locations)
        data.locations[loc_idx].index = loc_idx
    end
end

function build_computed_data(data::RvrpInstance)
    loc_id_idx = Dict{String,Int}(
        data.locations[i].id => i for i in 1:length(data.locations)
    )
    vc_id_idx = Dict{String,Int}(
        data.vehicle_categories[i].id => i for i in 1:length(data.vehicle_categories)
    )
    return RvrpComputedData(loc_id_idx, vc_id_idx)
end

function create_default_location_groups(locations::Vector{Location})
    return [LocationGroup(
        id = string(l.id, "_loc_group"),
        location_ids = [l.id]
    ) for l in locations]
end
