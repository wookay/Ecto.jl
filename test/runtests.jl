using Base.Test

@testset "type.jl" begin
    include("type.jl")
end

@testset "mirrortypes.jl" begin
    include("mirrortypes.jl")
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
