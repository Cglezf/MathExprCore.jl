using MathExprCore
using Documenter

DocMeta.setdocmeta!(MathExprCore, :DocTestSetup, :(using MathExprCore); recursive=true)

makedocs(;
    modules=[MathExprCore],
    authors="Sglez",
    sitename="MathExprCore.jl",
    format=Documenter.HTML(;
        canonical="https://Cglezf.github.io/MathExprCore.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Cglezf/MathExprCore.jl",
    devbranch="main",
)
