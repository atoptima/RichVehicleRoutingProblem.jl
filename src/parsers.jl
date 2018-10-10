################################# JSON Parsers #################################
function parse_to_json(data::RvrpProblem, file_path::String)
    json2_string = JSON2.write(data)
    io = open(file_path, "w")
    write(io, json2_string)
    write(io, "\n")
    close(io)
end

function parse_json_matrix(vec::Vector{Any})
    dim = Int(sqrt(length(vec)))
    matrix = Array{Float64,2}(undef, dim, dim)
    for j in 1:dim
        for i in 1:dim
            println
            matrix[i,j] = vec[(j-1)*dim + i]
        end
    end
    return matrix
end

function parse_from_jason(file_path::String)
    io = open(file_path)
    str = read(io, String)
    json_dict = JSON.parse(str)

    problem_id = json_dict["problem_id"]
    problem_type = ProblemType(json_dict["problem_type"]["fleet_size"],
                               json_dict["problem_type"]["fleet_composition"])
    j_vehicles = json_dict["vehicles"]
    j_vehicle_types = json_dict["vehicle_types"]
    j_distance_matrix = json_dict["distance_matrix"]
    j_travel_times_matrix = json_dict["travel_times_matrix"]
    j_services = json_dict["services"]
    j_shipments = json_dict["shipments"]
    j_picked_shipments = json_dict["picked_shipments"]

    vehicles = Vehicle[]
    vehicle_types = VehicleType[]
    distance_matrix = parse_json_matrix(j_distance_matrix)
    travel_times_matrix = parse_json_matrix(j_travel_times_matrix)
    services = Service[]
    shipments = Shipment[]
    picked_shipments = Shipment[]

    data =  RvrpProblem(problem_id, problem_type, vehicles,
                        vehicle_types, distance_matrix, travel_times_matrix,
                        services, shipments, picked_shipments)
    return data
end
