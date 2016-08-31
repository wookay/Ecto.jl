module Ecto

__precompile__(true)

include("exports.jl")
include("type.jl")
include("mirrortypes.jl")
include("schema.jl")
include("changeset.jl")
include("query.jl")
include("repo.jl")
include("english.jl")

end # module Ecto
