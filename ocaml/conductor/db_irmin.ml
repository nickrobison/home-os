open Lwt.Syntax

module Make (Store : Irmin.KV with type contents = Irmin.Contents.Json_value.t) :
  Db.S with type t = Store.t and type config = Irmin.config = struct
  type t = Store.t
  type config = Irmin.config
  type error = Store.write_error

  type read_error = [ Models.error | `Not_found of string ]
  [@@deriving show, eq, ord]

  let src = Logs.Src.create "irmin_db" ~doc:"Irmin DB implementation"

  module Log = (val Logs.src_log src : Logs.LOG)

  let app_prefix = "application"
  let _service_prefix = "services"

  (* This should NOT be Unix focused, but I can't seem to figure out the appropriate type*)
  let create_registration t ~app =
    let info fmt =
      Irmin_unix.info ~author:"System <homeos@nickrobison.com>" fmt
    in
    let value = Models.RegisteredApplication.t_to_irmin app in
    Log.info (fun m ->
        m "Persisting app registration: %a" Models.pp_registered_application app);
    Store.set t [ app_prefix; app.id ] value ~info:(info "First commit")

  let safe_get t id =
    Lwt.catch
      (fun () ->
        let+ v = Store.get t [ app_prefix; id ] in
        Ok v)
      (fun _ -> Lwt.return_error (`Not_found "Cannot find key"))

  let get_registration t ~id =
    let+ v = safe_get t id in
    match v with
    | Ok v -> Models.RegisteredApplication.t_of_irmin v
    | Error e -> Error e

  let set_registration_status t ~user:_ status ~id =
    let info fmt =
      Irmin_unix.info ~author:"System <homeos@nickrobison.com>" fmt
    in
    let* maybe_val = Store.find t [ app_prefix; id ] in
    match maybe_val with
    | None -> Lwt.return_error (`Not_found "nope, not there")
    | Some v -> (
        (*Gross, gross, gross*)
        let v = Models.RegisteredApplication.t_of_irmin v in
        match v with
        | Error e -> Lwt.return_error e
        | Ok v ->
            let+ () =
              Store.set_exn t [ app_prefix; id ]
                (Models.RegisteredApplication.t_to_irmin { v with status })
                ~info:(info "Updating")
            in
            Ok ())

  let create config =
    let* repo = Store.Repo.v config in
    Store.master repo
end
