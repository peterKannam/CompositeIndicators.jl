using DataFrames,CSV

"""
    Coin <: DataType

`DataType` that stores a set of named dictionaries.

The dictionaries are used to contruct and analyse a composite indicator model.

#Fields
-`input::Dict{Symbol,Any}`:

-`data::Dict{Symbol,Any}`:

-`weights::Dict{Symbol,Any}`:

-`log::DataFrame`:

-`results::Dict{Symbol,Any}`:

-`figures::Dict{Symbol,Any}`:
"""
mutable struct Coin
    input::Dict{Symbol ,Any}
    data::Dict{Symbol,Any}
    weights::Dict{Symbol,Any}
    log::DataFrame
    results::Dict{Symbol,Any}
    figures::Dict{Symbol,Any}
end

"""
    new_coin(indData,indMeta)

Return a new `Coin` object to represent a composite indicator model. 

Indicator data is defined by `indData`. Model structure and weighting scheme is defined by 
`indMeta`.
"""
function new_coin(indData::DataFrame,indMeta::DataFrame)
    coin_out = Coin(
        #input
        Dict(:indMeta => indMeta,:indData => indData),
        #data
        Dict(:d_original=>indData[:,indMeta[indMeta.Type .== "Indicator",:iCode]]),
        #weights
        Dict(:w_original =>indMeta[indMeta.Type .== "Indicator" .|| indMeta.Type .== "Aggregate",
            ["iCode","Level","Weight","Parent"]]), 
        #log
        DataFrame(:location=>[],:fieldkeytup=>[],:type=>[],:function=>[],:arguments =>[],:readout=>[]), 
        
        #results
        Dict(),
        #figures
        Dict())

        write2log(coin_out,:input,:indData,"new_coin", 
        argumentlist = ["indData"])

        write2log(coin_out,:input,:indMeta,"new_coin", 
        argumentlist = ["indMeta"])

        write2log(coin_out,:data,:d_original,"new_coin", 
        argumentlist = ["indData"])

        write2log(coin_out,:weights,:w_original,"new_coin", 
        argumentlist = ["indMeta"])
    return coin_out
end

function check_indMeta(indMeta::DataFrame)
    
end

function check_indData(indData::DataFrame)

end

"""
    get_meta(coin)

Return a `DataFrame` of a the metadata used to contruct the `Coin`.

"""
function get_meta(coin::Coin)
    return coin.input[:indMeta]
end

"""
    get_meta(coin,colval_tup;column_out = names(coin.input[:indMeta]))

Return a `DataFrame` of a subset of the metadata. 

Subset specified by a tuple of column name and a value, 
`colval_tup::Tuple{Union{String,Symbol},Any}`, and can 
be further defined using the `column_out` keyword. 
"""
function get_meta(coin::Coin,colval_tup::Tuple{Union{String,Symbol},Any};
    column_out = names(coin.input[:indMeta]))
    
    o= subset(coin.input[:indMeta],colval_tup[1]=> x->x .== colval_tup[2])[:,column_out]
    return o
end

#return specific meta data, no keyword
function get_meta(coin::Coin,colval_tup::Tuple{Union{String,Symbol},Any},column_out)
    
    o= subset(coin.input[:indMeta],colval_tup[1]=> x->x .== colval_tup[2])[:,column_out]
    return o
end

"""
    levelnormalizedweights!(coin::Coin,weightkey::Symbol = :w_original)

Add a column of weights that sum to `1` for each `Level` to the `coin.weights[weightkey]`
`DataFrame`.
Resulting weights for each indicator are proportional to the number of indicators it shares
 a `Parent` indicator with and the `Parent` indicator weight. 

# Examples
```jldoctest
julia> using DataFrames

julia> w = DataFrame(:iCode=>["L1A","L1B","L1C","L1D","L2A","L2B","L3A"],
           :Level=>[1,1,1,1,2,2,3],
           :Parent=>["L2A","L2A","L2B","L2B","L3A","L3A","NA"],
               :Weight=>[1,1,1,1,1,1,1])
7×4 DataFrame
 Row │ iCode   Level  Parent  Weight 
     │ String  Int64  String  Int64  
─────┼───────────────────────────────
   1 │ L1A         1  L2A          1
   2 │ L1B         1  L2A          1
   3 │ L1C         1  L2B          1
   4 │ L1D         1  L2B          1
   5 │ L2A         2  L3A          1
   6 │ L2B         2  L3A          1
   7 │ L3A         3  NA           1

julia> levelnormalizeweights!(w)
7×5 DataFrame
 Row │ iCode   Level  Parent  Weight  WeightNorm 
     │ String  Int64  String  Int64   Float64    
─────┼───────────────────────────────────────────
   1 │ L1A         1  L2A          1        0.25
   2 │ L1B         1  L2A          1        0.25
   3 │ L1C         1  L2B          1        0.25
   4 │ L1D         1  L2B          1        0.25
   5 │ L2A         2  L3A          1        0.5
   6 │ L2B         2  L3A          1        0.5
   7 │ L3A         3  NA           1        1.0

julia> w2 = copy(w);w2[5,:Weight] = 4;levelnormalizeweights!(w2)
7×5 DataFrame
 Row │ iCode   Level  Parent  Weight  WeightNorm 
     │ String  Int64  String  Int64   Float64    
─────┼───────────────────────────────────────────
   1 │ L1A         1  L2A          1         0.4
   2 │ L1B         1  L2A          1         0.4
   3 │ L1C         1  L2B          1         0.1
   4 │ L1D         1  L2B          1         0.1
   5 │ L2A         2  L3A          4         0.8
   6 │ L2B         2  L3A          1         0.2
   7 │ L3A         3  NA           1         1.0
```
"""
function levelnormalizeweights!(coin::Coin,weightkey::Symbol = :w_original;
    write2coin = true)
    w = copy(coin.weights[weightkey])
    if "WeightNorm" in names(w)
        w.WeightNorm .= zeros(size(w,1))
    else
        insertcols!(w,:WeightNorm => zeros(size(w,1)))
    end
    w.WeightNorm[end] = 1
    for i = maximum(w.Level):-1:2
        
        for ind in w[w.Level .== i,:iCode]

            w[w.Parent .== ind,:WeightNorm] .= w[w.iCode .== ind,:WeightNorm] .* 
                (w[w.Parent .== ind,:Weight] ./ sum(w[w.Parent .== ind,:Weight]))  
        end
    end
    if write2coin
        coin.weights[weightkey] = w
    end
    return w
end

function levelnormalizeweights!(weight_df::DataFrame)
    w = copy(weight_df)
    if "WeightNorm" in names(w)
        w.WeightNorm .= zeros(size(w,1))
    else
        insertcols!(w,:WeightNorm => zeros(size(w,1)))
    end
    w.WeightNorm[end] = 1
    for i = maximum(w.Level):-1:2
        
        for ind in w[w.Level .== i,:iCode]

            w[w.Parent .== ind,:WeightNorm] .= w[w.iCode .== ind,:WeightNorm] .* 
                (w[w.Parent .== ind,:Weight] ./ sum(w[w.Parent .== ind,:Weight]))  
        end
    end
    
    return w
end

function write2log(coin::Coin,field::Symbol,key::Symbol,createdby::String
    ;argumentlist = [],
    readout = "")
   
    if readout !== ""
        println(readout)
    end

    pushfirst!(coin.log,("coin."*String(field)*"[:$key]",(field,key),
        String(Symbol(typeof(getfield(coin,field)[key]))),
        createdby, argumentlist, readout),
        promote = false)
    
end

function Base.display(coin::Coin)
    println("coin object with:")
    println("        Inputs: ",collect(keys(coin.input)))
    println("      Datasets: ",sort(collect(keys(coin.data))))
    println("       Weights: ",collect(keys(coin.weights)))
    println("       Results: ",collect(keys(coin.results)))
    println("       Figures: ",collect(keys(coin.figures)))

end

