include("..\\src\\CompositeIndicators.jl")

using .CompositeIndicators
using CSV, DataFrames, StatsBase, CairoMakie

#CEJI is a composite indicator with 28 raw indicators and 4 Levels.
ceji_data = DataFrame(CSV.File("examples\\CEJI_indData.csv"))
ceji_struct = DataFrame(CSV.File("examples\\CEJI_indStruct.csv"))
ceji = new_coin(ceji_data,ceji_struct)

#CEJI normalizes data using a percentile calculation where ties values are assigned identical results.
normalize!(ceji,norm_function = norm_competepercentile,datakey = :d_original)
#Calculate the CEJI using a minmax normalization scheme
normalize!(ceji,norm_function = norm_minmax,datakey = :d_original)

#CEJI aggregates indicators by arithmetic mean for Levels 1 and 2, but by product for Level 3
aggregate!(ceji,:norm_competepercentile,:w_original,resultkey = :r_v1,
    ag_function = ag_mean, ag_function_override = (3,ag_product))
#Calculate the CEJI using the minmax normalization scheme
aggregate!(ceji,:norm_minmax,:w_original,resultkey = :r_minmax,
    ag_function = ag_mean, ag_function_override = (3,ag_product))
#Calculate the CEJI using arithmetic mean on every level
aggregate!(ceji,:norm_minmax,:w_original,resultkey = :r_noproduct,
ag_function = ag_mean,)

#Calculate the CEJI excluding the OZONE indicator, matching the methods used for :r_v1
reaggregate_excludeindicator!(ceji,:r_v1,indicators2exclude = ["OZONE"])
#Calculate the CEJI excluding the POC indicator, matching the methods used for :r_v1
reaggregate_excludeindicator!(ceji,:r_v1,indicators2exclude = ["POC"])

#Analyze relationships between indicators :r_v1
collect_lineages!(ceji)

for i = 1:length(get_meta(ceji,(:Level,2),:iCode))
    lvl2_ind = get_meta(ceji,(:Level,2),:iCode)[i]
    lin_cor = indicatorcorrelation!(ceji;
        datakey=:r_v1,indicators= ceji.meta[:lineages][i],
        resultkey=Symbol(:cor_lin,lvl2_ind), cor_function = cor,write2coin = true)
    #Heatmap of indicator correlations
    f_heatmap = Figure()
    ax_heatmap = Axis(f_heatmap[1,1], title = "Correlation between $lvl2_ind Indicators",
        xticks = (1:size(lin_cor,1),names(lin_cor)),
        xticklabelrotation = 45,
        yticks = (1:size(lin_cor,1),names(lin_cor)))
    heatmap!(Matrix(lin_cor))
    Colorbar(f_heatmap[1, 2], limits = (-1, 1))
    display(f_heatmap)

    #Biplot of indicator PCA analayis
    lin_pca = indicatorpca!(ceji;
    datakey=:r_v1,indicators= find_children(lvl2_ind,get_meta(ceji)),
    resultkey=Symbol("pca_",lvl2_ind), maxoutdim = 2,write2coin = true)
end

#Compare the unit rankings of different results to :r_v1
compareresults!(ceji,:r_v1,[:r_minmax,:r_noproduct,:r_v1_ex_OZONE,:r_v1_ex_POC])

#Collect keys of results of comparisons to :r_v1
keys_comparisons = sort(collect(keys(ceji.results))[occursin.("comp2r_v1",string.(keys(ceji.results)))])
#Establish figure for plotting comparisons
f_excludeindicators = Figure()
ax_excludeindicators = Axis(f_excludeindicators[1,1],title = "comparison to r_v1 result dataset",
    ylabel = "rank change", xlabel = "result dataset",
    xticks = (1:length(keys_comparisons),chop.(string.(keys_comparisons),head=10,tail = 0)))
#Plot boxplot of comparisons to :r_v1
for i in 1:length(keys_comparisons)
    boxplot!(ax_excludeindicators,
        ones(length(ceji.results[keys_comparisons[i]].Index)).*i,
        abs.(ceji.results[keys_comparisons[i]].Index))
end
ceji.figures[:f_excludeindicators] = f_excludeindicators

# save CEJI result and process log
# write("examples\\CEJI_result.csv",ceji.results[:r_v1])
# write("examples\\CEJI_log.csv",ceji.log)
