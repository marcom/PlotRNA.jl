using Test
using PlotRNA: R2R
using BioStockholm: MSA

@testset "R2R._run_r2r" begin
    Tres = Tuple{Int, String, String, String}
    @test R2R._run_r2r(MSA{Char}(; seq=Dict("a" => "GAAAC", "b" => "UAAAA"), GC=Dict("SS_cons" => "<...>"))) isa Tres
end
