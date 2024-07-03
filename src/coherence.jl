using MultivariateStats

function indicatorcorrelation(coin::Coin;
    datakey=:d_original,indicators= names(coin.data[datakey]),resultkey=:cor_current, cor_function = cor,write2coin = false)

    o = cor_function(Matrix(coin.data[datakey][:,indicators]))
    o = DataFrame(o, :auto)
    rename!(o,indicators)

    if write2coin
    ceji.results[resultkey] = o
    end
    return o
end

function indicatorpca(coin::Coin;
    datakey=:d_original,indicators= names(coin.data[datakey]),resultkey=:pca_model, maxoutdim = 2,write2coin = false)

    d = coin.data[datakey][:,indicators]
    #generate PCA model. Matrix transpose occurs to reduce indicator dimensions instead of unit dimensions
    m = fit(PCA,Matrix(d)',maxoutdim = maxoutdim)

    if write2coin
        ceji.results[resultkey] = m
        end
    return m
end

