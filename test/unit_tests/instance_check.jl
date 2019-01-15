function instance_check_unit_tests()

    check_if_supports_tests()
    check_positive_range_tests()

end

function check_if_supports_tests()

    supported_vec = [BitSet([1, 4, 10, 20, 30, 100]), BitSet([1, 2, 3, 4, 10, 20, 30, 100])]
    features = BitSet([1, 2, 10, 20])
    @test RVRP.check_if_supports(supported_vec, features) == true

    features = BitSet([1, 2, 23])
    @test RVRP.check_if_supports(supported_vec, features) == false

end

function check_positive_range_tests()
    range = RVRP.Range()
    @test RVRP.check_positive_range(range, "") == nothing

    range = RVRP.Range(-1.0, 10.0)
    @test_throws ErrorException RVRP.check_positive_range(range, "")

    range = RVRP.Range(1.0, -10.0)
    @test_throws ErrorException RVRP.check_positive_range(range, "")

    range = RVRP.Range(100.0, 10.0)
    @test_throws ErrorException RVRP.check_positive_range(range, "")
end
