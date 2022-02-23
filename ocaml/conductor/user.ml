module Id = struct
  type t = Uuidm.t

  let t_of_string str =
    match Uuidm.of_string str with
    | Some u -> Ok u
    | None -> Error "Cannot parse to UUID"

  let t_to_string = Uuidm.to_string ~upper:false
  let pp = Uuidm.pp
  let equal = Uuidm.equal
  let show = t_to_string
end

type t = { id : Id.t; username : string; email : string } [@@deriving show, eq]
