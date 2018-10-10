function parsers_unit_tests()
    parse_to_json_tests()
    parse_json_matrix_tests()
    parse_from_jason_tests()
end

function parse_to_json_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end

function parse_json_matrix_tests()
    mat1 = [1 2 3; 4 5 6; 7 8 9]
    vec::Vector{Any} = [1, 4, 7, 2, 5, 8, 3, 6, 9]
    mat2 = RVRP.parse_json_matrix(vec)
    @test mat2 == mat1
end

function parse_from_jason_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    data2 = RVRP.parse_from_jason("../dump/dummy.json")
    @test data == data2
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end
