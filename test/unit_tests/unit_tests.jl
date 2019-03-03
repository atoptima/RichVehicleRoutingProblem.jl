# include("../utils.jl")
include("RVRP_data.jl")
include("RVRP_solution.jl")
include("utils.jl")
include("parser_cvrplib.jl")
include("instance_check.jl")
include("parser_json.jl")
include("solution_check.jl")

include("mock_solver.jl")
include("vroom.jl")
include("jsprit.jl")

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
    @testset "parser_json.jl" begin
        parser_json_unit_tests()
    end
    @testset "solution_check.jl" begin
        solution_check_unit_tests()
    end

    @testset "vroom_cpp.jl" begin
        vroom_cpp_unit_tests()
    end
    @testset "jsprit_java.jl" begin
        jsprit_java_unit_tests()
    end
    @testset "mock_solver.jl" begin
        mock_solver_unit_tests()
    end
end
