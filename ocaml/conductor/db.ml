module type S = sig
  type config
  type t
  type error
  type contents

  val create_registration : t -> contents -> (unit, error) result Lwt.t
  val create : config -> t Lwt.t
end
