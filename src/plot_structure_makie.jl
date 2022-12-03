# Note: we have to use the dot before CairoMakie as we are using
# Requires.jl to only compile this code if CairoMakie is available
using .CairoMakie: Makie, Axis, Colorbar, ColorTypes, DataAspect, Figure,
    hidedecorations!, hidespines!, lines!, scatter!, text!,
    xlims!, ylims!

function plot_structure_makie(
    structure::AbstractString;
    sequence::AbstractString=" "^length(structure),
    savepath::String = "",
    layout_type::Symbol=:simple,
    colorscheme::Symbol=:lightrainbow,
    linestyles::Bool=true,
)

    fc = FoldCompound(sequence)
    partfn(fc)
    pt = Pairtable(structure)
    x_coords, y_coords = plot_coords(structure; plot_type=layout_type)

    markersize = 100 / sqrt(length(structure))
    positions = [(a, b) for (a, b) in zip(x_coords, y_coords)]
    pairs = basepairs(pt)
    f = Figure()
    ax = Axis(f[1, 1])
    xlims!(
        round(Int, minimum(x_coords)) - 20,
        round(Int, maximum(x_coords)) + 20)
    ylims!(
        round(Int, minimum(y_coords)) - 20,
        round(Int, maximum(y_coords)) + 20)
    hidedecorations!(ax)
    hidespines!(ax)

    for (i, j) in pairs
        if linestyles == false
            linestyle = :solid
        elseif (sequence[i], sequence[j]) in (('C','G'), ('G','C'))
            linestyle = :solid
        elseif (sequence[i], sequence[j]) in (('A','T'), ('T','A'), ('A','U'), ('U','A'))
            linestyle = :dash
        else
            linestyle = :dot
        end
        lines!(
            [x_coords[i], x_coords[j]],
            [y_coords[i], y_coords[j]],
            color = (:black, 0.5),
            linestyle = linestyle,
            linewidth = 0.8,
        )
    end
    lines!(ax, x_coords, y_coords;
           linewidth = 3)
    scatter!(ax, x_coords, y_coords;
             markersize = markersize,
             color = prob_of_basepairs(fc, pt),
             colormap = colorscheme,
             colorrange = (0, 1), # probabilities [0, 1]
             )

    text!(string.(collect(sequence)),
        position = positions,
        align = (:center, :center),
        fontsize = markersize / 2,
    )
    Colorbar(
        f[2, 1],
        vertical = false,
        colormap = colorscheme,
        width = 500,
        height = 12,
    )
    ax.aspect = DataAspect()
    if ! isempty(savepath)
        save(savepath, f)
    end
    return f
end
