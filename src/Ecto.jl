module Ecto

__precompile__(true)

include("exports.jl")
include("reflection.jl")
include("mirrortypes.jl")
include("schema.jl")
include("changeset.jl")
include("query.jl")
include("repo.jl")
include("english.jl")

end # module Ecto
