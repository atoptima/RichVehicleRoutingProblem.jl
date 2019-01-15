# include("../utils.jl")
include("RVRP_data.jl")
include("RVRP_solution.jl")
include("utils.jl")
include("parser_cvrplib.jl")
include("instance_check.jl")
# include("parser_json.jl")

function unit_tests()
    @testset "RVRP_data.jl" begin
        rvrp_data_unit_tests()
    end
    @testset "RVRP_solution.jl" begin
        rvrp_solution_unit_tests()
    end
    @testset "utils.jl" begin
        utils_unit_tests()
    end
    @testset "parser_cvrplib.jl" begin
        parser_cvrplib_unit_tests()
    end
    @testset "instance_check.jl" begin
        instance_check_unit_tests()
    end
    # @testset "parser_json.jl" begin
    #     parser_json_unit_tests()
    # end
end
