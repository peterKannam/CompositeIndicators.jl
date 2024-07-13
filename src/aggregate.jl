#funtions need to be wrapped to exclusively take (x::Vector,w::AbstractWeights) types
#functions do not need to take missing values, aggregate function will filter missing from rows before applying 
#geometric mean

"""
    ag_geomean(x::Vector,w::AbstractWeights)

Geometric mean of `x` using weights `w` by `sqrt(prod(x .^ Int.(w))`.
"""
ag_geomean(x::Vector,w::AbstractWeights) = sqrt(prod(x .^ Int.(w)))
#arithmetic mean 
"""
    ag_mean(x::Vector,w::AbstractWeights)

Arithmetic mean of `x` using weights `w` by `mean(x,w)`.
"""
ag_mean(x::Vector,w::AbstractWeights) = mean(x,w)
#product
"""
    ag_prod(x::Vector,w::AbstractWeights)
    Product of `x` using ignoring weights `w` by `prod(x)`.

"""
ag_prod(x::Vector,w::AbstractWeights) = prod(x)


"""
    aggregate!(coin::Coin,datakey::Symbol,weightskey::Symbol;...)

Add the `DataFrame` results of composite indicator aggregation of `coin.data[datakey]` by 
`coin.weights[weigtskey]` to `coin.data'[:r_current]` and `coin.results[:r_current]`.

# Arguments
- `resultkey::Symbol = :r_current`:  key that results are saved as in coin.data coin.results.

- `ag_function::Function = ag_mean`: function used to aggregate indicators of the same level. 
Functions must take agruments (x::Vector,w::AbstractWeights).

- `ag_function_override::Tuple{Int64,Function} = (0,ag_mean)`: tuple of level and aggregation.
function that is different than ag_function. Works only for a single level.

- `indicators2exclude::Vector = []`: indicator columns to exclude in aggregation.

- `write2coin::Bool = true`:  if results are saved to coin.
"""
function aggregate!(coin::Coin, datakey::Symbol, weightskey::Symbol;
    resultkey::Union{String,Symbol} = :r_current,
    ag_function::Function = ag_mean, 
    ag_function_override::Tuple{Int64,Function} = (0,ag_mean),
    indicators2exclude::Union{String,Vector,Symbol} = [],
    write2coin::Bool = true)

    if String(resultkey)[1:2] !== "r_"
        error("RESULTKEY ERROR: `resultkey` arguement must start with `r_`. $resultkey")
    end

    #not sure if works
    if Symbol(resultkey) !== :r_current && in(resultkey,collect(keys(coin.data))) && write2coin
        error("OVERWRITING ERROR: dataset titled `:$resultkey` is already present in the coin. 
            Choose a different name or use the default `r_current` option for rewritable datasets.")
    end

    d = select(coin.data[datakey],Not(indicators2exclude))
    w = copy(coin.weights[weightskey])
    if !isempty(indicators2exclude)
        for i = 1:length(indicators2exclude)
            deleteat!(w,w.iCode .== indicators2exclude[i])
        end
    end
    dropmissing!(w,[:Level,:Weight],disallowmissing = true)

    #for each level expect the index level
    for level in 1:maximum(w.Level)-1
        
        #for each parent indicator
        for parent in collect(skipmissing(unique(w[w.Level .== level,:Parent])))
            #index defining the indicators of concern
            idx_wLevelParent = w.Level .== level .&& w.Parent .== parent

            #make matrix out of weight vector that mirrors missing values in the indicator dataset
            wMatrix = allowmissing(transpose(repeat(w[idx_wLevelParent,:Weight],1,size(d)[1])))
            wMatrix[Matrix(ismissing.(d[:,w[idx_wLevelParent,:iCode]]))] .= missing

            #collect non-missing indicator values and weights for each row
            dRow = collect.(skipmissing.(eachrow(d[:,w[idx_wLevelParent,:iCode]])))
            wRow = collect.(skipmissing.(eachrow(wMatrix)))

            if level == ag_function_override[1]
                #println(level," ",ag_function_override[2])
                parentMean = ag_function_override[2].(dRow,weights.(wRow))
            else
                #find weighted mean of non-missing values in each row
                #println(level," ",ag_function)
                parentMean = ag_function.(dRow,weights.(wRow))
            end
                insertcols!(d, parent =>parentMean)
                #println(w[w.Parent .== parent,:iCode])
        end
    end
    
    #add result dataset to .results dicts
    if write2coin 

        coin.results[Symbol(resultkey)] = d
        
        #log_readout = "Result dataset `r_$resultkey` was created by aggregating `$datakey`
        #    accoring to weighting scheme `$weightskey` with aggregation function `"
            # *String(Symbol(ag_function))

        write2log(coin,:results,Symbol(resultkey),"aggregate!", 
        argumentlist = [datakey, weightskey,
        resultkey,ag_function, 
        ag_function_override,
        indicators2exclude,
        write2coin]
        )

    end
        
    return d 
end
"""
    reaggregate_excludeindicator!(coin,logkey;indicators2exclude)

Add the `DataFrame` results of composite indicator aggregation of `coin.data[datakey]` by 
`coin.weights[weigtskey]` to `coin.data'[r_current]` and `coin.results["r_current"]`.

Call the `aggregate` function using the arugments saved in the coin.log entry for `logkey` 
    excluding indicators in `indicators2exclude`. Results are saved as 
    `coin.data'[Symbol("r_ex",join(indicators2exclude))]`
"""
function reaggregate_excludeindicator!(coin::Coin,logkey::Symbol;indicators2exclude::Vector{String})

    resultargs = coin.log[indexin([(:results,logkey)],coin.log.fieldkeytup),:arguments][1]

    r_exclude = aggregate!(coin,resultargs[1],resultargs[2],resultkey = Symbol(logkey,"_ex_"*join(indicators2exclude)), 
    ag_function = resultargs[4],ag_function_override = resultargs[5], 
    indicators2exclude = indicators2exclude,write2coin = true)
    
    return  r_exclude
end


