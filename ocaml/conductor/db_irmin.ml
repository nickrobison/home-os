open Lwt.Syntax

module Make
    (Store : Irmin.KV with type contents = Irmin.Contents.Json_value.t)
    (I : Db.Info) : Db.S with type t = Store.t and type config = Irmin.config =
struct
  type t = Store.t
  type config = Irmin.config
  type error = Store.write_error

  type read_error = [ Models.error | `Not_found of string ]
  [@@deriving show, eq, ord]

  let src = Logs.Src.create "irmin_db" ~doc:"Irmin DB implementation"

  module Log = (val Logs.src_log src : Logs.LOG)
  module Proj = Irmin.Json_tree (Store)
  module Reg = Homeos_protocols.Registration.Make (Capnp.BytesMessage)

  let app_prefix = "application"
  let _service_prefix = "services"

  let info ?(user = User.system_user) fmt =
    let author = Format.sprintf "%s <%s>" user.username user.email in
    I.info ~author fmt

  let create_registration t ~app =
    let value = Models.ApplicationRecord.make app in
    let value' = Models.ApplicationRecord.t_to_irmin value in
    Log.info (fun m ->
        m "Persisting app registration: %a" Models.pp_application_record value);
    let+ () =
      Proj.set t
        [ app_prefix; Uuidm.to_string value.id ]
        value' ~info:(info "First commit")
    in
    Ok value.id

  let safe_get t id =
    Lwt.catch
      (fun () ->
        let+ v = Proj.get t [ app_prefix; id ] in
        Ok v)
      (fun _ -> Lwt.return_error (`Not_found "Cannot find key"))

  let get_registration t ~id =
    let id = Uuidm.to_string id in
    let+ v = safe_get t id in
    match v with
    | Ok v -> Models.ApplicationRecord.t_of_irmin ~id v
    | Error e -> Error e

  let set_registration_status t ~user status ~id =
    let id = Uuidm.to_string id in
    let status_key = [ app_prefix; id; "status" ] in
    let* maybe_value = Store.find t status_key in
    match maybe_value with
    | None -> Lwt.return_error (`Not_found "nope, not there")
    | Some _ ->
        let value = `String (Models.RegistrationStatus.t_to_irmin status) in
        let+ () =
          Store.set_exn t status_key value ~info:(info ~user "Updating status")
        in
        Ok ()

  let create config =
    let* repo = Store.Repo.v config in
    Store.master repo
end
