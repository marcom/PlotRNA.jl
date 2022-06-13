# DrawRNA.jl
Draw nucleic acid secondary structures with Julia

## Installation

As DrawRNA is not yet registered you have to add it from github:
```julia
] add https://github.com/marcom/DrawRNA.jl
```

## Usage

```julia
using DrawRNA
```

```julia
# plot_structure, draws an image of a secondary structure
dbn = "(((...)))"
seq = "GGGAAACCC"
plot_structure(dbn)
plot_structure(dbn; sequence=seq, base_colors=prob_of_basepairs(seq, dbn))
```

There is also an experimental `DrawRNA.plot_structure_makie` which
looks a bit nicer but currently has a rather large time to first plot
(half a minute). Subsequent plots are very fast.