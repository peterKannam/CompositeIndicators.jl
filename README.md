# CompositeIndicators.jl

 `CompositeIndicators.jl` is a package for the building and analysis of composite indicator models. It was developed as a learing excersise and is heavily influenced by the more complete[COINr](https://bluefoxr.github.io/COINr/) package by William Becker. A earlier version of this package was used to compute and assess the [Chicago Environmental Justice Index](https://www.chicago.gov/city/en/depts/cdph/supp_info/Environment/cumulative-impact-assessment.html).


## Introduction

`CompositeIndicators.jl` allows for the calculation and analysis of robust, replicable, and reportable composite indicators by defining a set workflow through the `Coin <: DataType` and a set of `Function`s that operate on it. This workflow mandates quality control in the following ways:

- `Functions` produce standardized results for comparison, visualization, and further processing. 
- `Functions` are not allowed to overwrite previous results in a `Coin`.
- `Functions` that write to a `Coin` record all information used to produce a result. 

The primary functions of `CompositeIndicators.jl` are correspond to major steps in building a composite indicator.
- `new_coin`: collect raw indicator data and design the structure of the composite indicator
- `normalize!`: normalize raw indicator datasets so they can be combined into a measure of a larger topic
- `aggregate!`: aggregate the normalized indicators according to the structure



## `Coin <: DataType`

The `Coin` (**Co**mposite **In**dicator) `DataType` is a composite type designed to record the structure of the of a composite indicator, all data that is included or produced during its calculation, and a log of all actions taken during its calculation. 

It organizes all the information relevent to the composite indicator it represents is sorted into fields. All fields are of type `Dict{Symbol,Any}` and are further sorted by specificed prefixes to the `Symbol` keys. The fields, their default values, and key naming conventions are listed below. 

### `Coin` Fields
  - `Coin.meta::Dict{Symbol,Any}`: Composite indicator metadata.
    - `Coin.meta[:indData]::DataFrame`: indicator dataset used when creating `Coin`.
    - `Coin.meta[:indData]::DataFrame`: composite indicator structure.

  - `Coin.data::Dict{Symbol,Any}`: all datasets used by or produce by composite indicator models.
    -  `Coin.data[:d_original]::DataFrame`: indicator dataset used when creating `Coin`.
    - `Key` conventions
      - `:d_`: raw indicator dataset
      - `:norm_`: normalized indicator dataset
      - `:r_`: result dataset with normalized raw indicators and aggregate indicators
      -  `:r_ex_`: result dataset aggregated excluding certain raw indicators

  - `Coin.weights::Dict{Symbol,Any}`: weighting schemes used for aggregation
    -  `Coin.weights[:w_original]::DataFrame`: weighting scheme descibed when creating `Coin`, `Coin.meta[:indStruct]`
    - `Key` conventions
      - `:w_`: weighting scheme 

  - `results::Dict{Symbol,Any}`: results of aggregating and analyzing composite indicators
    - `Key` conventions
      -  `:r_`: result dataset of aggregate indicators only
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

Dataflows are kept consistant by `Function`s designed to access and write to specific fields. Additionally, 



### Building a Coin

### 

## Normalization

## Aggregation

## 