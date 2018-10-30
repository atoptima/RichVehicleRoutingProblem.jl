function parsers_unit_tests()
    parse_to_json_tests()
    parse_from_json_tests()
end

function parse_to_json_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end

function parse_from_json_tests()
    data = RVRP.generate_data_random_tsp(5)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    data2 = RVRP.parse_from_json("../dump/dummy.json")
    @test data == data2
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false

    data = RVRP.generate_full_data_random(3)
    @test isfile("../dump/dummy.json") == false
    RVRP.parse_to_json(data, "../dump/dummy.json")
    @test isfile("../dump/dummy.json") == true
    data2 = RVRP.parse_from_json("../dump/dummy.json")
    @test data == data2
    rm("../dump/dummy.json")
    @test isfile("../dump/dummy.json") == false
end
