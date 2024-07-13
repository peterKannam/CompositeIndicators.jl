# CompositeIndicators.jl

 `CompositeIndicators.jl` is a package for the building and analysis of composite indicator models. It was developed as a learing excersise and is heavily influenced by the more complete [COINr](https://bluefoxr.github.io/COINr/) package by William Becker. A earlier version of this package was used to compute and assess the [Chicago Environmental Justice Index](https://www.chicago.gov/city/en/depts/cdph/supp_info/Environment/cumulative-impact-assessment.html).


## Introduction

`CompositeIndicators.jl` allows for the calculation and analysis of robust, replicable, and reportable composite indicators by defining a set workflow through the `Coin <: DataType` and a set of `Function`s that operate on it. This workflow mandates quality control in the following ways:

- `Functions` produce standardized results for comparison, visualization, and further processing. 
- `Functions` are not allowed to overwrite previous results in a `Coin`.
- `Functions` that write to a `Coin` record all information used to produce a result. 

The primary functions of `CompositeIndicators.jl` are correspond to major steps in building a composite indicator.
- `new_coin`: collect raw indicator data and design the structure of the composite indicator
- `normalize!`: normalize raw indicator datasets so they can be combined into a measure of a larger topic
- `aggregate!`: aggregate the normalized indicators according to the structure

## Basic Example: Chicago Environmental Justice Index 

```julia
include("src\\CompositeIndicators.jl")

using .CompositeIndicators
using CSV, DataFrames, StatsBase

# CEJI is a composite indicator with 28 raw indicators and 4 Levels.
ceji_data = DataFrame(CSV.File("examples\\CEJI_indData.csv",missingstring = ["NA",""]))
ceji_struct = DataFrame(CSV.File("examples\\CEJI_Struct.csv"))
ceji = new_coin(ceji_data,ceji_meta)

#CEJI replaces missing values with 0. 
ceji.data[:d_zeros] = coalesce.(copy(ceji.data[:d_original]),0)

#CEJI normalizes data using a percentile calculation where ties values are assigned identical results.
normalize!(ceji,norm_function = norm_competepercentile,datakey = :d_zeros)

#CEJI aggregates indicators by arithmetic mean for Levels 1 and 2, but by product for Level 3
aggregate!(ceji,:norm_competepercentile,:w_original,resultkey = :r_v1,
    ag_function = ag_mean, ag_function_override = (3,ag_prod))

#save result
write("examples\\CEJI_result.csv",ceji.results[:r_v1])
```

## `Coin <: DataType`

The `Coin` (**Co**mposite **In**dicator) `DataType` is a composite type designed to record the structure of the of a composite indicator, all data that is included or produced during its calculation, and a log of all actions taken during its calculation. 

A `Coin` organizes all the information relevent to the composite indicator it represents is sorted into fields. All fields are of type `Dict{Symbol,Any}` and are further sorted by specificed prefixes to the `Symbol` keys. The fields, their default values, and key naming conventions are listed below. 

### `Coin` Fields
  - `Coin.meta::Dict{Symbol,Any}`: Composite indicator metadata.
    - `Coin.meta[:indData]::DataFrame`: indicator dataset used when creating `Coin`.
    - `Coin.meta[:indData]::DataFrame`: composite indicator structure.

  - `Coin.data::Dict{Symbol,Any}`: all datasets used by or produce by composite indicator models.
    -  `Coin.data[:d_original]::DataFrame`: indicator dataset used when creating `Coin`.
    - `Key` conventions
      - `:d_`: raw indicator dataset
      - `:norm_`: normalized indicator dataset

  - `Coin.weights::Dict{Symbol,Any}`: weighting schemes used for aggregation
    -  `Coin.weights[:w_original]::DataFrame`: weighting scheme descibed when creating `Coin`, `Coin.meta[:indStruct]`
    - `Key` conventions
      - `:w_`: weighting scheme 

  - `results::Dict{Symbol,Any}`: results of aggregating and analyzing composite indicators
    - `Key` conventions
      -  `:r_`: result dataset of normalized raw indicators and aggregate indicators
      -  `:r_ex_`: result dataset aggregated excluding certain raw indicators
  
  - `figures::Dict{Symbol,Any}`: figures associated with the composite indicator

  - `log::DataFrame`: log of results produced by `CompositeIndicators.jl`.

## `new_coin <: Function`

```julia 
new_coin(indData::DataFrame,indStruct::DataFrame)
```
Return a new `Coin` object to represent a composite indicator model.

Indicator data is defined by `indData`. Model structure and weighting scheme is defined by `indStruct`.


## `normalize! <: Function`
```julia
normalize!(coin;norm_function::Function,datakey::String,normalizedkey::String)
```

Add a `DataFrame` of `coin.data[datakey]` normalized by `norm_function` to `coin.data[norm_*normalizedkey]`.

  Normalize by applying `norm_function` to each column of the `DataFrame`. `norm_function` must take and return a `Vector`. If `datakey` is
  unspecified, apply `norm_function` to `coin.data[:d_original]`. If `normalizedkey` is unspecified, add result with `key`
  `norm_*String(Symbol(norm_function))`.

## `aggregate! <: Function`
```julia
aggregate!(coin::Coin,datakey::Symbol,weightskey::Symbol;...)
```

  Add the `DataFrame` results of composite indicator aggregation of `coin.data[datakey]` by `coin.weights[weigtskey]` to `coin.data'[:r_current]` 
  and `coin.results[:r_current]`.

### Arguments

- `resultkey::String = :r_current`: key that results are saved as in coin.data coin.results.
- `ag_function::Function = ag_mean`: function used to aggregate indicators of the same level. Functions must take agruments
  `(x::Vector,w::AbstractWeights)`.
- `ag_function_override::Tuple{Int64,Function} = (0,ag_mean)`: tuple of level and aggregation. function that is different than
  `ag_function`. Works only for a single level.
- `indicators2exclude::Vector = []`: indicator columns to exclude in aggregation.
- `write2coin::Bool = true`: if results are saved to coin.
