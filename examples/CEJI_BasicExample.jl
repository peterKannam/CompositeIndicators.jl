include("..\\src\\CompositeIndicators.jl")

using .CompositeIndicators
using CSV, DataFrames, StatsBase

# CEJI is a composite indicator with 28 raw indicators and 4 Levels.
ceji_data = DataFrame(CSV.File("examples\\CEJI_indData.csv"))
ceji_struct = DataFrame(CSV.File("examples\\CEJI_indStruct.csv"))
ceji = new_coin(ceji_data,ceji_struct)

#CEJI normalizes data using a percentile calculation where ties values are assigned identical results.
normalize!(ceji,norm_function = norm_competepercentile,datakey = :d_original)

#CEJI aggregates indicators by arithmetic mean for Levels 1 and 2, but by product for Level 3
aggregate!(ceji,:norm_competepercentile,:w_original,resultkey = :r_v1,
    ag_function = ag_mean, ag_function_override = (3,ag_product))

#save CEJI result and process log
# write("examples\\CEJI_result.csv",ceji.results[:r_v1])
# write("examples\\CEJI_log.csv",ceji.log)