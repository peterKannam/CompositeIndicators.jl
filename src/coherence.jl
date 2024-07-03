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


