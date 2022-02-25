open Lwt.Syntax
module Db_irmin = Db_irmin
module Models = Models

module Make
    (Store : Irmin.KV with type contents = Irmin.Contents.Json_value.t)
    (I : Db.Info) =
struct
  module DB = Db_irmin.Make (Store) (I)
  module Registrar = Registrar.Make (DB)

  type db = DB.t
  type t = { db : DB.t }

  let make () =
    (*Should not be hard coded here*)
    let+ db = DB.create (Irmin_git.config ~bare:true "/tmp/conductor-test") in
    { db }

  let registrar t = Registrar.local t.db
end
