using Test
using PlotRNA: R2R
using BioStockholm: MSA

const R2R_MSA = [
parse(MSA,
"""# STOCKHOLM 1.0
human        ACACGCGAAA.GCGCAA.CAAACGUGCACGG
chimp        GAAUGUGAAAAACACCA.CUCUUGAGGACCU
bigfoot      UUGAG.UUCG..CUCGUUUUCUCGAGUACAC
#=GC SS_cons ...<<<.....>>>....<<....>>.....
//
"""),

MSA{Char}(; seq = Dict("a" => "GAAAC", "b" => "UAAAA"),
          GC = Dict("SS_cons" => "<...>")),
]

@testset "R2R.run_r2r" begin
    showtestset()
    Tres = Tuple{Int, String, String, String}
    for msa in R2R_MSA
        @test R2R.run_r2r(msa) isa Tres
    end
end

@testset "R2R.plot" begin
    showtestset()
    Tres = R2R.Plot
    for msa in R2R_MSA
        @test R2R.plot(msa) isa Tres
    end
end
