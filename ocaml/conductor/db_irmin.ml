open Lwt.Infix

module Make (Store : Irmin.KV) :
  Db.S
    with type t = Store.t
     and type config = Irmin.config
     and type contents = Store.contents = struct
  type t = Store.t
  type config = Irmin.config
  type error = Store.write_error
  type contents = Store.contents

  (* This should NOT be Unix focused, but I can't seem to figure out the appropriate type*)
  let create_registration t application =
    let info fmt = Irmin_unix.info fmt in
    Store.set t [ "hello" ] application ~info:(info "First commit")

  let create config = Store.Repo.v config >>= fun repo -> Store.master repo
end
