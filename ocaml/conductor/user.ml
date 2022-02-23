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

let system_user =
  let id = Uuidm.of_string "00000000-0000-0000-0000-000000000000" in
  match id with
  | None -> failwith "Cannot parse UUID"
  | Some id -> { id; username = "System User"; email = "homeos@homeoslocal" }
