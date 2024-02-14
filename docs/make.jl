using MultiData
using Documenter

DocMeta.setdocmeta!(MultiData, :DocTestSetup, :(using MultiData); recursive=true)






makedocs(;
    modules=[MultiData],
    authors="Lorenzo Balboni, Federico Manzella, Giovanni Pagliarini, Eduard I. Stan",
    repo=Documenter.Remotes.GitHub("aclai-lab", "MultiData.jl"),
    sitename="MultiData.jl",
    format=Documenter.HTML(;
        size_threshold = 4000000,
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aclai-lab.github.io/MultiData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Datasets" => "datasets.md",
        "Manipulation" => "manipulation.md",
        "Description" => "description.md",
        "Utils" => "utils.md",
    ],
    # NOTE: warning
    warnonly = :true,
)

deploydocs(;
    repo = "github.com/aclai-lab/MultiData.jl",
    target = "build",
    branch = "gh-pages",
    versions = ["main" => "main", "stable" => "v^", "v#.#", "dev" => "dev"],
)
