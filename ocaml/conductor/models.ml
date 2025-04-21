module R = Homeos_protocols.Registration.Make (Capnp.BytesMessage)

type registered_service = { typ : string } [@@deriving eq, show]

type registration_status = Pending | Approved | Rejected
[@@deriving eq, ord, show]

type capnp_error = [%import: Capnp.Codecs.FramingError.t]
[@@deriving show, eq, ord]

type error = [ `Parse_error of string | `Deserialization_error of capnp_error ]
[@@deriving show, eq, ord]

type application_record = {
  id : Uuidm.t;
  name : string;
  status : registration_status;
  hash : string;
  details : R.Reader.RegistrationRequest.t; [@opaque] [@equal fun _a _b -> true]
      (* We're disabling this equality check because we rely on the [hash] value to determine equality. It's not great, but it should work*)
}
[@@deriving eq, show]

module RegistrationStatus = struct
  type t = registration_status
end

module ApplicationRecord : sig
  type t = application_record

  val make : R.Reader.RegistrationRequest.t -> t
end = struct
  type t = application_record

  let hash ~name =
    let module H = Digestif.BLAKE2B in
    let ctx = H.init () in
    let ctx = H.feed_string ctx name in
    H.to_hex (H.get ctx)

  let make request =
    let name = R.Reader.RegistrationRequest.name_get request in
    let id = Uuidm.v4_gen (Random.State.make_self_init ()) () in
    let hashed = hash ~name in
    { id; name; status = Pending; hash = hashed; details = request }
end
