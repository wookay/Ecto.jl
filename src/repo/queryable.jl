# module Ecto.Repo

module Queryable

import ....Ecto

## get
function get(repo::Base.Random.UUID, adapter, modul::Module, id::Any, opts::Dict)
end

get(repo::Base.Random.UUID, adapter, modul::Module, id::Void,   opts::Dict) = throw(ArgumentError(""))
get(repo::Base.Random.UUID, adapter, modul::Module, id::Symbol, opts::Dict) = throw(Ecto.Query.CastError(""))
get(repo::Base.Random.UUID, adapter, modul::Any,    id::Symbol, opts::Dict) = throw(Ecto.QueryError(""))


## get_by
function get_by(repo::Base.Random.UUID, adapter, modul::Module, clause, opts::Dict)
end

get_by(repo::Base.Random.UUID, adapter, modul::Module, clause, opts::Dict{Symbol,Void})   = throw(ArgumentError(""))
get_by(repo::Base.Random.UUID, adapter, modul::Module, clause, opts::Dict{Symbol,Symbol}) = throw(Ecto.Query.CastError(""))
get_by(repo::Base.Random.UUID, adapter, modul::Any,    clause, opts::Dict{Symbol,Symbol}) = throw(Ecto.QueryError(""))

end # module Ecto.Repo.Queryable
