using Test
import UnicodePlots

@testset "uniplot" begin
    showtestset()
    @test PlotRNA.uniplot("(((...)))") isa UnicodePlots.Plot
end
