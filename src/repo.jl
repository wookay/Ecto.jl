# module Ecto

module Repo

# Repo.Schema.t
# Ecto.Schema.t
import ....Ecto

# Query.t
import ..Query

# Changeset.t
import ..Changeset

adapter = nothing

type t
    repo::Base.Random.UUID
    get::Function
    get_by::Function
    insert!::Function
    update!::Function
    insert_or_update!::Function
    delete!::Function
    update_all::Function
    delete_all::Function
    insert::Function
    update::Function
    insert_or_update::Function
    delete::Function
    function t()
        repo = Base.Random.uuid1()
        f(repo, g) = (args...; kw...) -> g(repo, args...; kw...)
        new(repo,
            f(repo, Repo.get),
            f(repo, Repo.get_by),
            f(repo, Repo.insert!),
            f(repo, Repo.update!),
            f(repo, Repo.insert_or_update!),
            f(repo, Repo.delete!),
            f(repo, Repo.update_all),
            f(repo, Repo.delete_all),
            f(repo, Repo.insert),
            f(repo, Repo.update),
            f(repo, Repo.insert_or_update),
            f(repo, Repo.delete)
        )
    end
end

include("repo/schema.jl")
include("repo/queryable.jl")

## Repo.Queryable
function get(repo::Base.Random.UUID, modul::Any, id::Any)#::Ecto.Schema.t
    opts = Dict()
    Repo.Queryable.get(repo, adapter, modul, id, opts)
end

function get_by(repo::Base.Random.UUID, modul::Any; kw...)#::Ecto.Schema.t
    opts = Dict(kw)
    get_by(repo, modul, opts)
end

function get_by(repo::Base.Random.UUID, modul::Any, opts::Dict)#::Ecto.Schema.t
    clause = nothing
    Repo.Queryable.get_by(repo, adapter, modul, clause, opts)
end


## Repo.Schema
function insert!(repo::Base.Random.UUID, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}; kw...)::Ecto.Schema.t
    Repo.Schema.insert!(repo, adapter, struct_or_changeset, Dict(kw))
end

function update!(repo::Base.Random.UUID, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}; kw...)::Ecto.Schema.t
    Repo.Schema.update!(repo, adapter, struct_or_changeset, Dict(kw))
end

function insert_or_update!(repo::Base.Random.UUID, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}; kw...)::Ecto.Schema.t
    Repo.Schema.insert_or_update!(repo, adapter, struct_or_changeset, Dict(kw))
end

function delete!(repo::Base.Random.UUID, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}; kw...)::Ecto.Schema.t
    Repo.Schema.delete!(repo, adapter, struct_or_changeset, Dict(kw))
end


## update_all
function update_all(repo::Base.Random.UUID, modul::Module; kw...)
# set=
end

function update_all(repo::Base.Random.UUID, modul::Module, updates::Array; kw...)
    opts = Dict(kw)
    if haskey(opts, :returning)
        isempty(opts[:returning]) && throw(ArgumentError("returning expects at least one field to be given"))
    end
end

function update_all{Q<:Query.Queryable}(repo::Base.Random.UUID, queryable::Q, updates::Array)
end

function update_all{Q<:Query.Queryable}(repo::Base.Random.UUID, queryable::Q; kw...)
    throw(Ecto.QueryError(""))
end

function update_all(repo::Base.Random.UUID, updates::Array)::Query.Applicable
    Query.Applicable()
end

function update_all(repo::Base.Random.UUID; kw...)::Query.Applicable
    Query.Applicable()
# set=
end


## delete_all
function delete_all(repo::Base.Random.UUID, modul::Module; kw...)
    opts = Dict(kw)
    if haskey(opts, :returning)
        isempty(opts[:returning]) && throw(ArgumentError("returning expects at least one field to be given"))
    end
end

function delete_all{Q<:Query.Queryable}(repo::Base.Random.UUID, queryable::Q)
    if !isempty(queryable, :select) || !isempty(queryable, :order_bys)
        throw(Ecto.QueryError(""))
    end
end

function insert(repo::Base.Random.UUID, changeset::Changeset.t)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    opts = Dict()
    Repo.Schema.insert(repo, adapter, changeset, opts)
end

function update(repo::Base.Random.UUID, changeset::Changeset.t)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    opts = Dict()
    Repo.Schema.update(repo, adapter, changeset, opts)
end

function insert_or_update(repo::Base.Random.UUID, changeset::Changeset.t)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    opts = Dict()
    Repo.Schema.insert_or_update(repo, adapter, changeset, opts)
end

function delete(repo::Base.Random.UUID, changeset::Changeset.t)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    opts = Dict()
    Repo.Schema.delete(repo, adapter, changeset, opts)
end

end # module Ecto.Repo
