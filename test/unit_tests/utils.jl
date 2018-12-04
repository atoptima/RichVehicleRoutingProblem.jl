function utils_unit_tests()
    generate_symmetric_distance_matrix_tests()
    set_indices_tests()
    build_computed_data_tests()
    create_singleton_location_groups_tests()
    preprocess_instance_unit_tests()
end

function generate_symmetric_distance_matrix_tests()
    xs = [rand(1:20) for i in 1:5]
    ys = [rand(1:20) for i in 1:5]
    matrix = RVRP.generate_symmetric_distance_matrix(xs, ys)
    @test size(matrix) == (5,5)
    for i in 1:5
        @test matrix[i,i] == 0.0
        for j in i+1:5
            @test matrix[i,j] == matrix[j,i]
        end
    end
end

function set_indices_tests()
    data = RVRP.RvrpInstance()
    data.locations = [RVRP.Location(
        id = "", index = rand(-100:-1)
    ) for i in 1:10]
    RVRP.set_indices(data)
    for loc_idx in 1:length(data.locations)
        @test data.locations[loc_idx].index == loc_idx
    end
end

function build_computed_data_tests()
    data = RVRP.RvrpInstance()
    data.locations = [RVRP.Location(
        id = string("loc_", i), index = rand(-100:-1)
    ) for i in 1:9]
    data.vehicle_categories = [RVRP.VehicleCategory(
        id = string("vc_", i)
    ) for i in 1:9]
    data.product_specification_classes = [RVRP.ProductSpecificationClass(
        id = string("psc_", i)
    ) for i in 1:5]
    RVRP.set_indices(data)
    data.location_groups = RVRP.create_singleton_location_groups(data.locations)
    data.vehicle_categories[1].vehicle_capacities = Dict{String,Float64}(
        "weird_name_1" => 10, "wolow_34" => 12, "volume" => 15
    )
    data.vehicle_categories[2].vehicle_capacities = Dict{String,Float64}(
        "weird_name_1" => 10, "wolow_34" => 12, "new_name_1" => 15
    )
    data.product_specification_classes[1].capacity_consumptions = Dict{String,Tuple{Float64,Float64}}(
        "weird_name_1" => (1,10), "new_name_2" => (1,12), "wolow_34" => (1,15)
    )
    computed_data = RVRP.build_computed_data(data)
    for (k,v) in computed_data.location_id_2_index
        @test v >= 1
        @test v <= 9
    end
    for (k,v) in computed_data.location_group_id_2_index
        @test v >= 1
        @test v <= 9
    end
    for (k,v) in computed_data.vehicle_category_id_2_index
        @test v >= 1
        @test v <= 9
    end
    for (k,v) in computed_data.product_specification_class_id_2_index
        @test v >= 1
        @test v <= 5
    end
    for (k,v) in computed_data.capacity_id_2_index
        @test v >= 1
        @test v <= 5
    end
end

function create_singleton_location_groups_tests()
    data = RVRP.RvrpInstance()
    data.locations = [RVRP.Location(
        index = rand(-100:-1)
    ) for i in 1:10]
    def_loc_groups = RVRP.create_singleton_location_groups(data.locations)
    for i in 1:length(data.locations)
        @test string(data.locations[i].id, "_loc_group") == def_loc_groups[i].id
    end
end

function preprocess_instance_unit_tests()
    data = RVRP.RvrpInstance()
    RVRP.preprocess_instance(data)
    @test length(data.locations) == 0
    @test length(data.location_groups) == 0
    @test length(data.product_compatibility_classes) == 1
    @test data.product_compatibility_classes[1].id == "default_id"
    @test length(data.product_sharing_classes) == 1
    @test data.product_sharing_classes[1].id == "default_id"
    @test length(data.product_specification_classes) == 1
    @test data.product_specification_classes[1].id == "default_id"
    @test length(data.requests) == 0
    @test length(data.vehicle_categories) == 1
    @test data.vehicle_categories[1].id == "default_id"
    @test length(data.vehicle_sets) == 0
end
