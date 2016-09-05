module TestSchema
type Post
    title::String
    author::String
end
end # module TestSchema


import Ecto
import Ecto.Schema: Assoc
using Base.Test

post = %(TestSchema.Post, author= "bar")
@test isa(post, Ecto.Schema.t)
@test Assoc([(:author, "bar")]) == post.struct
