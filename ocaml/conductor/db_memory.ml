open Lwt.Syntax

type t = { tbl : (Uuidm.t, Models.application_record) Hashtbl.t }
type config = unit
type error = string

type read_error = [ Models.error | `Not_found of string ]
[@@deriving show, eq, ord]

let src = Logs.Src.create "memory_db" ~doc:"In-memory DB implementation"

module Log = (val Logs.src_log src : Logs.LOG)

let create () = Lwt.return { tbl = Hashtbl.create 50 }

let create_registration t ~app =
  let value = Models.ApplicationRecord.make app in
  Log.info (fun m ->
      m "Persisting app registration: %a" Models.pp_application_record value);
  Hashtbl.add t.tbl value.id value;
  Lwt.return_ok value.id

let get_registration t ~id =
  match Hashtbl.find_opt t.tbl id with
  | None -> Lwt.return_error (`Not_found "Cannot find key")
  | Some v -> Lwt.return_ok v

let set_registration_status t ~user status ~id =
  let* maybe_entry = get_registration t ~id in
  match maybe_entry with
  | Error e -> Lwt.return_error e
  | Ok v ->
      Log.info (fun m ->
          m "User: %a Setting status: `%a` for `%a`" User.pp user
            Models.pp_registration_status status Uuidm.pp id);
      let updated = { v with status } in
      Hashtbl.replace t.tbl id updated;
      Lwt.return_ok ()
