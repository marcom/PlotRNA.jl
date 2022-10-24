using Test
using PlotRNA: R2R
using BioStockholm: MSA
using PlotRNA.R2R: r2r

@testset "R2R.r2r" begin
    Tres = Tuple{Int, String, String, String}
    @test r2r(MSA{Char}(; seq = Dict("a" => "GAAAC", "b" => "UAAAA"),
                        GC = Dict("SS_cons" => "<...>"))) isa Tres
end
