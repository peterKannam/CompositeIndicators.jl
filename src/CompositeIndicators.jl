module CompositeIndicators

include("coin_struct.jl")
export Coin, 
    new_coin, 
    get_meta, 
    levelnormalizeweights!,
    find_parent,
    find_children,
    collect_lineages

include("normalize.jl")
export normalize!,
    norm_competepercentile,
    norm_skipzeropercentile,
    norm_minmax

include("aggregate.jl")
export aggregate!,
    reaggregate_excludeindicator!,
    ag_geomean,
    ag_mean,
    ag_prod

end