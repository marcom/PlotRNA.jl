import Aqua
using PlotRNA

@testset "Aqua.test_all" begin
    showtestset()
    Aqua.test_all(PlotRNA)
end
