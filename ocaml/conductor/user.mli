module Id : sig
  type t [@@deriving show, eq]

  val t_of_string : string -> (t, string) result
  val t_to_string : t -> string
end

type t = { id : Id.t; username : string; email : string } [@@deriving show, eq]
