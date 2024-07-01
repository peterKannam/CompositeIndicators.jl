using Documenter, .CompositeIndicators

DocMeta.setdocmeta!(CompositeIndicators, :DocTestSetup, :(using CompositeIndicators); recursive=true)

makedocs(;
    modules=[CompositeIndicators],
    checkdocs=:exports,
    authors="Peter Kannam",
    repo="https://github.com/peterkannam/CompositeIndicators.jl/blob/{commit}{path}#{line}",
    sitename="CompositeIndicators.jl",
    #format=Documenter.HTML(;
        # prettyurls=get(ENV, "CI", "false") == "true",
        # canonical="https://github.com/peterkannam/CompositeIndicators.jl",
        # assets=String[],
    # ),
    pages=[
        "Home" => "index.md",
        "Coin Object" => "coin.md",
        "Normalize" => "normalize.md",
        "Aggregate" => "aggregate.md"
    ],
)

deploydocs(;
    repo="https://github.com/peterkannam/CompositeIndicators.jl",
    devbranch = "main",
)