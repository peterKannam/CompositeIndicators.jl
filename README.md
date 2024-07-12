# CompositeIndicators.jl

 `CompositeIndicators.jl` is a package for the building and analysis of composite indicator models. It was developed as a learing excersise and is heavily influenced by the [COINr](https://bluefoxr.github.io/COINr/) package by William Becker. A earlier version of this package was used to compute and assess the [Chicago Environmental Justice Index](https://www.chicago.gov/city/en/depts/cdph/supp_info/Environment/cumulative-impact-assessment.html).

## Introduction

`CompositeIndicators.jl` allows for the calculation and analysis of robust, replicable, and reportable composite indicators by defining a set workflow through the `Coin <: DataType` and a set of `Function`s that operate on it. This workflow mandaCtes quality control in the following ways:
- `Functions` that write to a `Coin` record the arugemnts that used to produce its result.
- `Functions` are not allowed to overwrite previous results in a `Coin`
- `Functions` produce standardized results for comparison, visualization, and further processing. 

The primary functions of `CompositeIndicators.jl` are correspond to the steps in building a composite indicator
1) `new_coin`: collect raw indicator data and design the structure of the composite indicator
2) `normalize!`: normalize raw indicator datasets so they can be combined into a measure of a larger topic
3) `aggregate!`: aggregate the normalized indicators according to the structure

## `Coin :> DataType`

A `Coin` is designed to record the structure of the composite indicator (`Coin.input`), original and alternate indicator datasets (`Coin.data`), original and alternate weighting schemes (`Coin.weights`), results of indicator aggregation and analysis (`Coin.results`), figures (`Coin.figures`), and a log of all the functions that were used to construct each entry (`Coin.log`). All feild are of type `Dict{Symbol,Any}` except for `Coin.log` which is a `DataFrame`. 

Dataflows are kept consistant by `Function`s designed to access and write to specific fields. Additionally, 



### Coin Fields

  - `input::Dict{Symbol,Any}`:

  - `data::Dict{Symbol,Any}`:

  - `weights::Dict{Symbol,Any}`:

  - `results::Dict{Symbol,Any}`:

  - `figures::Dict{Symbol,Any}`:

  - `log::DataFrame`:

### Building a Coin

### 

## Normalization

## Aggregation

## 