type registered_service = { typ : string } [@@deriving eq, show]

type registration_status = Pending | Approved | Rejected
[@@deriving eq, ord, show]

type error = [ `Parse_error of string ] [@@deriving show, eq, ord]

type application_record = {
  id : string;
  name : string;
  status : registration_status;
  hash : string;
}
[@@deriving eq, show]

module RegistrationStatus = struct
  type t = registration_status

  let t_to_irmin = function
    | Pending -> "pending"
    | Approved -> "approved"
    | Rejected -> "rejected"

  let t_of_irmin = function
    | "pending" -> Ok Pending
    | "approved" -> Ok Approved
    | "rejected" -> Ok Rejected
    | str -> Error (`Parse_error (Format.sprintf "Unknown status: %s" str))
end

module ApplicationRecord : sig
  type t = application_record

  val t_to_irmin : t -> Irmin.Contents.Json_value.t

  val t_of_irmin :
    id:string -> Irmin.Contents.Json_value.t -> (t, [> error ]) result
end = struct
  type t = application_record

  let t_to_irmin t =
    `O
      [
        ("name", `String t.name);
        ("status", `String (RegistrationStatus.t_to_irmin t.status));
        ("hash", `String t.hash);
      ]

  let ( let* ) = Result.bind

  let member f key json =
    try Ok (f (Ezjsonm.find json key)) with
    | Ezjsonm.Parse_error (_, msg) -> Error (`Parse_error msg)
    | Not_found -> Error (`Parse_error "Cannot find key")

  let t_of_irmin ~id json =
    let open Ezjsonm in
    let* name = member get_string [ "name" ] json in
    let* status_str = member get_string [ "status" ] json in
    let* status = RegistrationStatus.t_of_irmin status_str in
    Ok { id; name; hash = ""; status }
end
