import Ecto.English: pluralize, singularize
using Base.Test

@test "users" == pluralize("User")
@test "user" == singularize("users")
