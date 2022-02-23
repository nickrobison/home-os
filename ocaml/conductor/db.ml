(** Simple abstraction layer over the `info` command for Irmin, not sure why there isn't one already, but this works with 2.x*)
module type Info = sig
  val info :
    ?author:string -> ('a, Format.formatter, unit, Irmin.Info.f) format4 -> 'a
end

module type S = sig
  type config
  type t
  type error

  type read_error = [ Models.error | `Not_found of string ]
  [@@deriving show, eq, ord]

  val create_registration :
    t -> app:Models.application_record -> (unit, error) result Lwt.t

  val get_registration :
    t -> id:string -> (Models.application_record, [> read_error ]) result Lwt.t

  val set_registration_status :
    t ->
    user:User.t ->
    Models.registration_status ->
    id:string ->
    (unit, [> read_error ]) result Lwt.t

  val create : config -> t Lwt.t
end
