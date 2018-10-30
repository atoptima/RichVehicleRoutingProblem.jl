function utils_unit_tests()
    gather_all_locations_tests()
    set_indices_tests()
end

function gather_all_locations_tests()
    l1 = RVRP.Location("", 20, RVRP.Coord(0.0,0.0))
    l2 = RVRP.Location("", 30, RVRP.Coord(0.0,0.0))
    data = RVRP.generate_data_random_tsp(10)
    p = RVRP.Pickup("", 1, l2, 0.0, RVRP.TimeWindow[], 0.0)
    d = RVRP.Delivery("", 1, l1, 0.0, RVRP.TimeWindow[], 0.0)
    ship = RVRP.Shipment("", 1, p, d, 0.0)
    push!(data.pickups, p)
    push!(data.deliveries, d)
    push!(data.shipments, ship)
    @test length(RVRP.gather_all_locations(data)) == 12
end

function set_indices_tests()
    l1 = RVRP.Location("", 20, RVRP.Coord(0.0,0.0))
    l2 = RVRP.Location("", 30, RVRP.Coord(0.0,0.0))
    data = RVRP.generate_data_random_tsp(10)
    p = RVRP.Pickup("", -1, l2, 0.0, RVRP.TimeWindow[], 0.0)
    d = RVRP.Delivery("", 121, l1, 0.0, RVRP.TimeWindow[], 0.0)
    ship = RVRP.Shipment("", -13, p, d, 0.0)
    push!(data.pickups, p)
    push!(data.deliveries, d)
    push!(data.shipments, ship)

    # messing up with indices
    data.depots[1].index = -32
    for i in 1:length(data.pickups)
        data.pickups[i].index = rand(-20:-1)
    end
    # setting the correct indices back
    RVRP.set_indices(data)

    for i in 1:length(data.pickups)
        @test data.pickups[i].index == i
    end
    @test l1.index != 20
    @test l2.index != 30
    @test data.depots[1].index == 1
    @test data.deliveries[1].index == 1
    @test data.shipments[1].index == 1
    @test data.vehicle_sets[1].departure_depot_index == 1
    @test data.vehicle_sets[1].arrival_depot_indices == [1]
end
