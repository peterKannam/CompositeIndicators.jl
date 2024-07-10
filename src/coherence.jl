using MultivariateStats

"""
    indicatorcorrelation!(coin::Coin;
        datakey=:d_original,indicators= names(coin.data[datakey]),
        resultkey=:cor_current, cor_function = cor,write2coin = false)

    Apply `cor_function` to `coin.data[datakey][:,indicators]` and save the result
    to `coin.results[resultkey]` if `write2coin = true`.
"""
function indicatorcorrelation!(coin::Coin;
        datakey=:d_original,indicators= names(coin.data[datakey]),
        resultkey=:cor_current, cor_function = cor,write2coin = false)

    o = cor_function(Matrix(coin.data[datakey][:,indicators]))
    o = DataFrame(o, :auto)
    rename!(o,indicators)

    if write2coin
    ceji.results[resultkey] = o

    write2log(coin,:results,resultkey,"indicatorcorrelation!"
    ;argumentlist = [datakey,indicators,resultkey,String(Symbol(cor_function)),write2coin],
    readout = "")
    end
    return o
end

"""
    indicatorpca!(coin::Coin;
        datakey=:d_original,indicators= names(coin.data[datakey]),
        resultkey=:pca_model, maxoutdim = 2,write2coin = false)
    
    Compute PCA model of `coin.data[datakey][:,indicators]` and save the result
    to `coin.results[resultkey]` if `write2coin = true`.
"""
function indicatorpca!(coin::Coin;
        datakey=:d_original,indicators= names(coin.data[datakey]),
        resultkey=:pca_model, maxoutdim = 2,write2coin = false)

    d = coin.data[datakey][:,indicators]
    #generate PCA model. Matrix transpose occurs to reduce indicator dimensions instead of unit dimensions
    m = fit(PCA,Matrix(d)',maxoutdim = maxoutdim)

    if write2coin
        ceji.results[resultkey] = m
        write2log(coin,:results,resultkey ,"indicatorpca!"
    ;argumentlist = [datakey,indicators,resultkey,maxoutdim,write2coin],
    )
        end
    return m
end

function compareresultranks(coin::Coin,resultkeylist;
    write2coin = false)

end

