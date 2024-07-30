using DataFrames, StatsBase

"""
    norm_competepercentile(x::Vector)

Return the percentile of each element of `x` where tied values are 
assigned identical results. 

Uses the `competerank` to rank values. `missing` values are assigned a result of `missing`.

# Examples
```jldoctest
julia> norm_competepercentile([0,0,1,2,2,3])
6-element Vector{Float64}:
 0.0
 0.0
 0.4
 0.6
 0.6
 1.0
```
```
 julia> norm_competepercentile([0,0,1,2,missing,3])
6-element Vector{Union{Missing, Float64}}:
 0.0
 0.0
 0.5
 0.75
  missing
 1.0
```
"""
norm_competepercentile(x::Vector) = round.((competerank(x) .-1) ./ 
    (maximum(skipmissing((competerank(x))))-1),digits = 4)

"""
    norm_skipzeropercentile(x::Vector)

Return the percentile of each nonzero element of `x` where tied values are 
assigned identical results.

Uses the `competerank` to rank nonzero values. '0' values are assigned a result of `0`.
`missing` values are assigned a result of `missing`.

#Examples
```jldoctest
julia> norm_skipzeropercentile([0,0,1,2,2,3])
6-element Vector{Float64}:
 0.0
 0.0
 0.0
 0.3333
 0.3333
 1.0
 ```
 ```jldoctest
julia> norm_skipzeropercentile([0,0,1,2,missing,3])
6-element Vector{Union{Missing, Float64}}:
 0.0
 0.0
 0.0
 0.5
  missing
 1.0
"""
function norm_skipzeropercentile(x::Vector) 
    idx_zeros = isequal.(x,0)
    out = Vector{Union{Float64,Missing}}(undef,length(x))
    out[idx_zeros] .= 0
    out[.!(idx_zeros)] = round.((competerank(x[.!(idx_zeros)]) .-1) ./ 
        (maximum(skipmissing((competerank(x[.!(idx_zeros)]))))-1),digits = 4)
    return out
end 

#min-max normalizaiton. works with missing data, same as compete_percentile with missing -> 0
"""
    norm_minmax(x::Vector)

Return min-max normalization of `x`. 
"""
norm_minmax(x::Vector) = (x .- minimum(skipmissing(x))) ./ 
    (maximum(skipmissing(x)) .- minimum(skipmissing(x))) 


"""
    normalize!(coin;norm_function::Function,datakey::String,normalizedkey::String)

Add a `DataFrame` of `coin.data[datakey]` normalized by 
`norm_function` to `coin.data[norm_*normalizedkey]`. 

Normalize by applying `norm_function` to each column of the `DataFrame`.
`norm_function` must take and return a `Vector`.
If `datakey` is unspecified, apply `norm_function` to `coin.data["original"]`.
If `normalizedkey` is unspecified, add result with key `norm_*String(Symbol(norm_function))`.
"""
function normalize!(coin::Coin;norm_function::Function,
    datakey::Symbol = :d_original,
    normalizedkey::Symbol = :none,
    write2coin = true)

    if normalizedkey == :none
        normkey = Symbol(norm_function)
    end

    if String(normkey)[1:5] !== "norm_"
        error("Key Error: `normalizedkey` argument must start with `norm_`. $normkey")
    end

    if in(normkey,collect(keys(coin.data)))
        error("OVERWRITING ERROR: dataset titled `$normkey` is already present in the coin. 
        Choose a different name by specifiying the `normalizedkey` arugment.")
    end

    if write2coin
        coin.data[normkey] = mapcols(x->norm_function(x),coin.data[datakey])
        log_readout = "Normalized dataset `$normkey` was created by applying the `" *String(Symbol(norm_function))* "` function to the `$datakey` dataset"
        write2log(coin,:data,normkey,"normalize!", 
        argumentlist = [String(Symbol(norm_function)),datakey,normalizedkey],readout = log_readout)
        
    end
        return coin;
end
 