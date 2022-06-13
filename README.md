# PlotRNA.jl

Plot nucleic acid secondary structures with Julia. Currently only the
most basic structure visualisation is implemented.

## Installation

As PlotRNA is not yet registered you have to add it like this:
```julia
] add https://github.com/marcom/PlotRNA.jl
```

## Usage

```julia
using PlotRNA, ViennaRNA
```

```julia
# plot_structure: draw an image of a secondary structure
dbn = "(((...)))"
seq = "GGGAAACCC"
plot_structure(dbn)
plot_structure(dbn; sequence=seq, base_colors=prob_of_basepairs(seq, dbn))
```

There is also an experimental `PlotRNA.plot_structure_makie` which
looks a bit nicer but currently has a rather large time to first plot
(40 seconds). Subsequent plots are very fast though.

## Other Julia packages for RNA secondary structure prediction

- [ViennaRNA.jl](https://github.com/marcom/ViennaRNA.jl)
- [LinearFold](https://github.com/marcom/LinearFold.jl)
