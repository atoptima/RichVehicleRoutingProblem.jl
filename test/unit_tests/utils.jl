function utils_unit_tests()
    gather_all_locations_tests()
    set_indices_tests()
end

function gather_all_locations_tests()
    l1 = RVRP.Location("", 20, RVRP.Coord(0.0,0.0))
    l2 = RVRP.Location("", 30, RVRP.Coord(0.0,0.0))
    data = RVRP.generate_data_random_tsp(10)
    p = RVRP.PickupPoint("", 1, l2, RVRP.TimeWindow[], 0.0)
    d = RVRP.DeliveryPoint("", 1, l1, RVRP.TimeWindow[], 0.0)
    push!(data.pickup_points, p)
    push!(data.delivery_points, d)
    @test length(RVRP.gather_all_locations(data)) == 12
end

function set_indices_tests()
    l1 = RVRP.Location("", 20, RVRP.Coord(0.0,0.0))
    l2 = RVRP.Location("", 30, RVRP.Coord(0.0,0.0))
    data = RVRP.generate_data_random_tsp(10)
    p = RVRP.PickupPoint("", -1, l2, RVRP.TimeWindow[], 0.0)
    d = RVRP.DeliveryPoint("", 121, l1, RVRP.TimeWindow[], 0.0)
    req = RVRP.ShipmentRequest("", -13, 1, "", false, 0.0, 0.0, 0.0, false, 0,
                               String[], String[], 0.0, 0.0, typemax(Int32))
    push!(data.pickup_points, p)
    push!(data.delivery_points, d)
    push!(data.requests, req)

    # messing up with indices
    data.depots[1].index = -32
    for i in 1:length(data.pickup_points)
        data.pickup_points[i].index = rand(-20:-1)
    end
    data.product_categories[1] = RVRP.ProductCategory("", -12, String[]
                                                      , String[])
    data.products[1] = RVRP.SpecificProduct(
        "", -8192, "", Dict{String,Int}(), Dict{String,Int}()
    )
    # setting the correct indices back
    RVRP.set_indices(data)

    @test data.product_categories[1].index == 1
    @test data.products[1].index == 1
    for i in 1:length(data.pickup_points)
        @test data.pickup_points[i].index == i
    end
    @test l1.index != 20
    @test l2.index != 30
    @test data.depots[1].index == 1
    @test data.delivery_points[1].index == 1
    @test data.requests[1].index == 1
    @test data.vehicle_sets[1].departure_depot_index == 1
    @test data.vehicle_sets[1].arrival_depot_indices == [1]
end
