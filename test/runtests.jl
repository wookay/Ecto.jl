using Base.Test

@testset "reflection.jl" begin
    include("reflection.jl")
end

@testset "mirrortypes/predicates.jl" begin
    include("mirrortypes/predicates.jl")
end

@testset "mirrortypes/types.jl" begin
    include("mirrortypes/types.jl")
end

@testset "assoc.jl" begin
    include("assoc.jl")
end

@testset "changeset.jl" begin
    include("changeset.jl")
end

@testset "query.jl" begin
    include("query.jl")
end

@testset "repo.jl" begin
    include("repo.jl")
end

@testset "english.jl" begin
    include("english.jl")
end
