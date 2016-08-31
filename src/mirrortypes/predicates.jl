# module Ecto.MirrorTypes

import Base: isless, !, ==, string

isless(n::Int, field::MirrorField) = MirrorPredicate(vcat(n, " < ", field))
isless(field::MirrorField, n::Int) = MirrorPredicate(vcat(field, " < ", n))
!(pred::MirrorPredicate) = MirrorPredicate(vcat("!(", pred.body, ")"))
==(field::MirrorField, n::Int) = MirrorPredicate(vcat(field, "==", n))
==(n::Int, field::MirrorField) = ==(field, n)

string(field::MirrorField) = string(field.typ, '.', field.name)

function construct(pred::MirrorPredicate, alias::Dict{Type,Symbol})
    join(map(x-> isa(x, MirrorField) ? construct(x, alias) : x, pred.body))
end

function construct(fld::MirrorField, alias::Dict{Type,Symbol})
    string(alias[fld.typ], '.', fld.name)
end

function build_alias(vec::Vector{Type})::Dict{Type,Symbol}
    vecdict = Dict{Char,Vector{Type}}()
    for t in vec
        ch = lowercase(string(t.name.name))[1]
        if !haskey(vecdict,ch)
            vecdict[ch] = Vector{Type}()
        end
        push!(vecdict[ch], t)
    end
    typedict = Dict{Type,Symbol}()
    for (k,v) in vecdict
        if 1 == length(v)
            typedict[first(v)] = Symbol(k)
        else
            for (idx,t) in enumerate(v)
                typedict[t] = Symbol(k,idx)
            end
        end
    end
    typedict
end

# Ref: julia/base/strings/io.jl join
function join_with(vec::Vector, delim)
    i = start(vec)
    is_done = done(vec,i)
    result = Vector()
    while !is_done
        el, i = next(vec,i)
        is_done = done(vec,i)
        result = vcat(result, el)
        if !is_done
            push!(result, delim)
        end
    end
    result
end
