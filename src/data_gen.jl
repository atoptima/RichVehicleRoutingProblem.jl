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
    services = Service[]
    shipments = Shipment[]
    picked_shipments = Shipment[]
    return RvrpProblem(problem_id, problem_type, vehicles,
        vehicle_types, distance_matrix, travel_times_matrix,
        services, shipments, picked_shipments)
end
