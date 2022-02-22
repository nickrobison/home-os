module type S = sig
  type config
  type t
  type error

  type read_error = [ Models.error | `Not_found of string ]
  [@@deriving show, eq, ord]

  val create_registration :
    t -> app:Models.registered_application -> (unit, error) result Lwt.t

  val get_registration :
    t ->
    id:string ->
    (Models.registered_application, [> read_error ]) result Lwt.t

  val create : config -> t Lwt.t
end
