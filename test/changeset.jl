module TestChangeset
type Post
    title::String
    author::String
end
end # module TestChangeset


import Ecto
import Ecto: Changeset
import Ecto.Changeset: change
import Ecto.Schema: Assoc
using Base.Test

post = %(TestChangeset.Post, author= "bar")
@test isa(post, Ecto.Schema.t)
changeset = change(post, title= "title")
@test Assoc([(:title, "title")]) == changeset.changes

changeset = change(%(TestChangeset.Post, title= "title"), title= "title")
@test Assoc([]) == changeset.changes
