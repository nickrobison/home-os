module R = Homeos_protocols.Registration.Make (Capnp.BytesMessage)

type registered_service = { typ : string } [@@deriving eq, show]

type registration_status = Pending | Approved | Rejected
[@@deriving eq, ord, show]

type capnp_error = [%import: Capnp.Codecs.FramingError.t]
[@@deriving show, eq, ord]

type error = [ `Parse_error of string | `Deserialization_error of capnp_error ]
[@@deriving show, eq, ord]

type application_record = {
  id : string;
  name : string;
  status : registration_status;
  hash : string;
  details : R.Builder.RegistrationRequest.t; [@opaque] [@equal fun _a _b -> true]
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

  let capnp_to_str request =
    let msg = R.Builder.RegistrationRequest.to_message request in
    Capnp.Codecs.serialize ~compression:`None msg

  let hash str =
    let module H = Digestif.BLAKE2B in
    let ctx = H.init () in
    let ctx = H.feed_string ctx str in
    H.to_hex (H.get ctx)

  let t_to_irmin t =
    let serialized = capnp_to_str t.details in
    let hashed = hash serialized in
    `O
      [
        ("name", `String t.name);
        ("status", `String (RegistrationStatus.t_to_irmin t.status));
        ("hash", `String hashed);
        ("details", `String serialized);
      ]

  let ( let* ) = Result.bind

  let member f key json =
    try Ok (f (Ezjsonm.find json key)) with
    | Ezjsonm.Parse_error (_, msg) -> Error (`Parse_error msg)
    | Not_found -> Error (`Parse_error "Cannot find key")

  let capnp_of_str str =
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`None str in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Ok msg -> Ok (R.Builder.RegistrationRequest.of_message msg)
    | Error e -> Error (`Deserialization_error e)

  let t_of_irmin ~id json =
    let open Ezjsonm in
    let* name = member get_string [ "name" ] json in
    let* status_str = member get_string [ "status" ] json in
    let* details_str = member get_string [ "details" ] json in
    let* hash = member get_string [ "hash" ] json in
    let* details = capnp_of_str details_str in
    let* status = RegistrationStatus.t_of_irmin status_str in
    Ok { id; name; hash; status; details }
end
