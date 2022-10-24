using Test
using PlotRNA: R2R
using BioStockholm: MSA
using PlotRNA.R2R: R2Rplot

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

@testset "R2R.r2r" begin
    Tres = Tuple{Int, String, String, String}
    for msa in R2R_MSA
        @test R2R.r2r(msa) isa Tres
    end
end

@testset "R2R.plot" begin
    Tres = R2Rplot
    for msa in R2R_MSA
        @test R2R.plot(msa) isa Tres
    end
end
