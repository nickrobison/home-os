type registered_service = { typ : string } [@@deriving irmin]

type registered_application = {
  id : string;
  name : string;
  consumes : registered_service list;
  produces : registered_service list;
  hash : string;
}
[@@deriving irmin]

module RegisteredApplication : sig
  type t = registered_application [@@deriving irmin]

  val merge : t option Irmin.Merge.t
end = struct
  type t = registered_application [@@deriving irmin]

  let merge = Irmin.Merge.(option (idempotent t))
end
