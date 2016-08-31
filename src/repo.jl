# module Ecto

module Repo

import ..Ecto

adapter = nothing

type t
    get::Function
    get_by::Function
    insert!::Function
    update!::Function
    delete!::Function
    update_all::Function
    t() = new(
        Repo.get,
        Repo.get_by,
        Repo.insert!,
        Repo.update!,
        Repo.delete!,
        Repo.update_all
    )
end

include("repo/schema.jl")

function get(modul::Any, id::Any)
    Ecto.Repo.Schema.get(adapter, modul, id)
end

function get_by(modul::Any; kw...)
    get_by(modul, Dict(kw))
end

function get_by(modul::Any, opts::Dict)
    Ecto.Repo.Schema.get_by(adapter, modul, opts)
end

function insert!(schema::Ecto.Schema.t; kw...)
    Ecto.Repo.Schema.insert!(adapter, schema, Dict(kw))
end

function update!(changeset::Ecto.Changeset.t; kw...)
    Ecto.Repo.Schema.update!(adapter, changeset, Dict(kw))
end

function delete!(schema::Ecto.Schema.t; kw...)
    Ecto.Repo.Schema.delete!(adapter, schema, Dict(kw))
end

function update_all(modul::Module, args::Array)
end

end # module Ecto.Repo
