# module Ecto.Schema

type Assoc
    vector::Vector{Tuple{Symbol,Any}}
    Assoc() = new(Vector{Tuple{Symbol,Any}}())
    Assoc(vector) = new(vector)
end

function Base.getindex(assoc::Assoc, key::Symbol)
    for (k,v) in assoc.vector
        k==key && return v
    end
    throw(KeyError("key $key not found"))
end

Base.push!(assoc::Assoc, tup::Tuple{Symbol,Any}) = push!(assoc.vector, tup)

Base.keys(assoc::Assoc) = map(first, assoc.vector)
Base.values(assoc::Assoc) = map(last, assoc.vector)
Base.haskey(assoc::Assoc, key::Symbol) = key in keys(assoc)

Base.start(assoc::Assoc) = start(assoc.vector)
Base.next(assoc::Assoc, i::Int) = next(assoc.vector, i)
Base.done(assoc::Assoc, i::Int) = done(assoc.vector, i)
