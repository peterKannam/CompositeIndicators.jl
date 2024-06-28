using Documenter, .CompositeIndicators

DocMeta.setdocmeta!(StatGeochem, :DocTestSetup, :(using StatGeochem); recursive=true)

makedocs(;
    modules=[CompositeIndicators],
    authors="Peter Kannam",
    repo="https://github.com/brenhinkeller/StatGeochem.jl/blob/{commit}{path}#{line}",
    sitename="CompositeIndicators.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://brenhinkeller.github.io/StatGeochem.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/brenhinkeller/StatGeochem.jl",
    devbranch = "main",
)