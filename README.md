# CompositeIndicators.jl

 CompositeIndicators.jl is a package for the building and analysis of composite indicator models. It was developed as an learing excersise and is heavily influenced by the [COINr](https://bluefoxr.github.io/COINr/) package by William Becker. Users looking to 
 work with composite indicator models are recommended to use COINr instead of CompositeIndicators.jl.

The base functions for this package were used to compute and assess the [Chicago Environmental Justice Index](https://www.chicago.gov/city/en/depts/cdph/supp_info/Environment/cumulative-impact-assessment.html).

## Coin Object

`CompositeIndicators.jl` defines `Coin <: DataType`. A `Coin` is designed to record the structure of the composite indicator (`Coin.input`), original and alternate indicator datasets (`Coin.data`), original and alternate weighting schemes (`Coin.weights`), results of indicator aggregation and analysis (`Coin.results`), figures (`Coin.figures`), and a log of all the functions that were used to construct each entry (`Coin.log`). All feild are of type `Dict{Symbol,Any}` except for `Coin.log` which is a `DataFrame`. 

Functions are designed to access and write to specific fields of a `Coin` to control dataflows. Because 



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