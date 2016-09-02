# module Ecto

module Typ

## dump
dump(typ::Type{Val{:id}}, value::Int) = (:ok, value)
dump(typ::Type{Val{:string}}, value::Void) = (:ok, value)
dump(typ::Type{Val{:string}}, value::String) = (:ok, value)
dump(typ::Type{Val{:binary}}, value::String) = (:ok, value)
dump(typ::Type{Val{(:array, :integer)}}, value::Vector{Int}) = (:ok, value)
dump(typ::Type{Val{(:array, :binary)}}, value::Vector{String}) = (:ok, value)
dump(typ::Type{Val{:integer}}, value::Int) = (:ok, value)
dump{T<:Val}(typ::Type{T}, value::Any) = (:error, value)

function adapter_dump(adapter, typ, value)
    dump(Val{typ}, value)
end

## julia_type
julia_type(typ::Type{Val{:id}}) = Int
julia_type(typ::Type{Val{:integer}}) = Int
julia_type(typ::Type{Val{:string}}) = String
julia_type(typ::Type{Val{:binary}}) = String
julia_type(typ::Type{Val{(:array, :integer)}}) = Vector{Int}
julia_type(typ::Type{Val{(:array, :binary)}}) = Vector{String}

## elixir_type
elixir_type(typ::Type{Int}) = :integer
elixir_type(typ::Type{String}) = :string
elixir_type(typ::Type{Vector{Int}}) = (:array, :integer)
elixir_type(typ::Type{Vector{String}}) = (:array, :binary)

end # Ecto.Typ
