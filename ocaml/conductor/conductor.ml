open Lwt.Syntax
module Db_memory = Db_memory
module Models = Models

module Make
    (Store : Irmin.KV with type contents = Irmin.Contents.Json_value.t)
    (I : Db.Info) =
struct
  module DB = Db_memory
  module Registrar = Registrar.Make (DB)

  type config = { bootstrap_key : string option; db_config : DB.config }
  type t = { db : DB.t; config : config }

  let make config =
    (*Should not be hard coded here*)
    let+ db = DB.create config.db_config in
    { db; config }

  let registrar t = Registrar.local t.config.bootstrap_key t.db
end
