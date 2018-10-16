function generate_symmetric_distance_matrix(n::Int)
    max_value = 20
    matrix = Matrix{Float64}(undef, n, n)
    points = rand(1:max_value, n, 2)
    for j in 1:n
        matrix[j,j] = 0.0
        for i in j+1:n
            matrix[j,i] = sqrt((points[j,1]-points[i,1])^2
                               + (points[j,2]-points[i,2])^2)
            matrix[i,j] = matrix[j,i]
        end
    end
    return matrix
end

function generate_data_random_tsp(n::Int)
    # Generate the points
    distance_matrix = generate_symmetric_distance_matrix(n)
    problem_id = string("tsp_random_", rand(1:1000))
    problem_type = ProblemType("FINITE", "HOMOGENEOUS")
    vehicles = Vehicle[]
    vehicle_types = VehicleType[]
    travel_times_matrix = Array{Float64,2}(undef, 0, 0)
    pickups = Pickup[]
    deliveries = Delivery[]
    operations = Operation[]
    shipments = Shipment[]
    picked_shipments = Shipment[]
    return RvrpProblem(problem_id, problem_type, vehicles,
        vehicle_types, distance_matrix, travel_times_matrix,
        pickups, deliveries, operations, shipments, picked_shipments)
end

function generate_random_costs()
    return Costs(rand(1:100, 5)...)
end

function generate_random_vehicle_type(n::Int)
    vehicle_types = VehicleType[]
    costs = generate_random_costs()
    for i in 1:n
        v_type = VehicleType(string("type_", i), rand(1:10), costs)
        push!(vehicle_types, v_type)
    end
    return vehicle_types
end

function generate_random_depot()
    coord = Coord(rand(1:20), rand(1:20))
    return Depot(Location("depot", coord, 1),
                 [TimeWindow(rand(1:20), rand(1:20))])
end

function generate_random_vehicles(n::Int, types::Vector{VehicleType}, depots::Vector{Depot})
    vs = Vehicle[]
    for i in 1:n
        tw = TimeWindow(rand(1:20), rand(20:25))
        v = Vehicle(string("v_", i), depots[rand(1:length(depots))],
                    types[rand(1:length(types))], tw, rand(Bool),
                    rand(Bool), rand(1:2), Shipment[])
        push!(vs, v)
    end
    return vs
end

function generate_random_pickups(n::Int)
    pickups = Pickup[]
    for i in 1:n
        coord = Coord(rand(1:20), rand(1:20))
        loc = Location(string("loc_", i+1), coord, i+1)
        tw = TimeWindow(rand(1:20), rand(1:20))
        p = Pickup(loc, rand(1:5), [tw], rand(1:5), string("req_", i))
        push!(pickups, p)
    end
    return pickups
end

function generate_full_data_random(n::Int)
    problem_id = string("full_random_", rand(1:1000))
    problem_type = ProblemType("FINITE", "HETEROGENEOUS")
    vehicle_types = generate_random_vehicle_type(2)
    v_types = generate_random_vehicle_type(2)
    depots = [generate_random_depot() for i in 1:2]
    vehicles = generate_random_vehicles(3, v_types, depots)
    distance_matrix = Array{Float64,2}(undef, 0, 0)
    travel_times_matrix = Array{Float64,2}(undef, 0, 0)
    ps = generate_random_pickups(n)
    pickups = [PickupRequest(string("p_",i), ps[i]) for i in 1:n]
    deliveries = DeliveryRequest[]
    operations = OperationRequest[]
    shipments = Shipment[]
    picked_shipments = Shipment[]
    return RvrpProblem(problem_id, problem_type, vehicles,
        vehicle_types, distance_matrix, travel_times_matrix,
        pickups, deliveries, operations, shipments, picked_shipments)
end
