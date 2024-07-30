function compareresults!(coin::Coin,primaryresult::Symbol,secondaryresults::Vector{Symbol};
    comparefunction::Function = competerank,
    cols2compare = coin.meta[:indStruct].Type .== "Aggregate",
    write2coin = true)

    if typeof(cols2compare) == BitVector
        cols2compare = coin.meta[:indStruct].iCode[cols2compare]
    end

    dict_compareresult = Dict{Symbol,DataFrame}()
    for secondaryresult in secondaryresults
        df_compare = mapcols(col->comparefunction(col),coin.results[primaryresult][:,cols2compare]) .- mapcols(col->comparefunction(col),coin.results[secondaryresult][:,cols2compare])
        dict_compareresult[secondaryresult] = df_compare

        if write2coin
            coin.results[Symbol("comp2",primaryresult,"_",secondaryresult)] = df_compare
            CompositeIndicators.write2log(coin,:results,Symbol("comp2",primaryresult,"_",secondaryresult),"compareresults!",
                argumentlist = [primaryresult,secondaryresults,comparefunction,cols2compare])
        end
    end

    return dict_compareresult
end

