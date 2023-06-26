import Aqua
using PlotRNA

@testset "Aqua.test_all" begin
    showtestset()
    if VERSION >= v"1.7"
        Aqua.test_all(PlotRNA)
    else
        # Aqua-0.6.4 on julia-1.6 complains about method ambiguities
        # and Project.toml formatting, julia-1.9 does not
        # Ref for Project.toml formatting: https://github.com/JuliaTesting/Aqua.jl/issues/105
        # Method ambiguities might be due to the compiler in julia-1.6 being a lot older
        Aqua.test_all(PlotRNA; ambiguities=false, project_toml_formatting=false)
    end
end
