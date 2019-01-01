function parser_json_unit_tests()
    parse_from_json_tests()
end

function parse_from_json_tests()
    data = RVRP.parse_from_json_string("{\"id\":\"wololo\"}\n")
    @test typeof(data) == RVRP.RvrpInstance
    @test data.travel_matrix_periods == RVRP.Range[]
    @test data.period_to_matrix_id == Dict{RVRP.Range,String}()
    @test data.travel_distance_matrices == Dict{String,Array{Float64,2}}()
    @test data.travel_time_matrices == Dict{String,Array{Float64,2}}()
    @test data.energy_consumption_matrices == Dict{String,Array{Float64,2}}()
    @test data.locations == RVRP.Location[]
    @test data.location_groups == RVRP.LocationGroup[]
    @test data.product_compatibility_classes == RVRP.ProductCompatibilityClass[]
    @test data.product_sharing_classes == RVRP.ProductSharingClass[]
    @test data.product_specification_classes == RVRP.ProductSpecificationClass[]
    @test data.requests == RVRP.Request[]
    @test data.vehicle_categories == RVRP.VehicleCategory[]
    @test data.vehicle_sets == RVRP.HomogeneousVehicleSet[]

    # data = RVRP.parse_cvrplib(dirname(@__FILE__)* "/../../data/cvrplib/P/P\\P-n16-k8.vrp")
    # @test isfile(dirname(@__FILE__)*"/../../dump/dummy.json") == false
    # RVRP.parse_to_json(data, dirname(@__FILE__)*"/../../dump/dummy.json")
    # @test isfile(dirname(@__FILE__)*"/../../dump/dummy.json") == true
    # data2 = RVRP.parse_from_json(dirname(@__FILE__)*"/../../dump/dummy.json")
    # @test data == data2
    # rm(dirname(@__FILE__)*"/../../dump/dummy.json")
    # @test isfile(dirname(@__FILE__)*"/../../dump/dummy.json") == false
end
