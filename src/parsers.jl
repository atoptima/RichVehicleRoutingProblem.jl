################################# JSON Parsers #################################
function parse_to_json(data::RvrpProblem, file_path::String)
    json2_string = JSON2.write(data)
    io = open(file_path, "w")
    write(io, json2_string)
    write(io, "\n")
    close(io)
end

function parse_from_jason(file_path::String)
    io = open(file_path, "r")
    s = read(io, String)
    return JSON2.read(s, RvrpProblem)
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
