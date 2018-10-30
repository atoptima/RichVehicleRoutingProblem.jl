include("../utils.jl")
include("utils.jl")
include("RVRP_data.jl")
include("RVRP_solution.jl")
include("parsers.jl")
include("data_gen.jl")

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
    @testset "data_gen.jl" begin
        data_gen_unit_tests()
    end
    @testset "parsers.jl" begin
        parsers_unit_tests()
    end
end
