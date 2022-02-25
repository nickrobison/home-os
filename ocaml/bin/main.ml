open Lwt.Infix

let src = Logs.Src.create "Conductor(Main)" ~doc:"HomeOS Conductor (Main)"

module Info = struct
  let info = Irmin_unix.info
end

module Log = (val Logs.src_log src : Logs.LOG)
module Store = Irmin_unix.Git.FS.KV (Irmin.Contents.Json_value)
module Conductor = Conductor.Make (Store) (Info)

let () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs_fmt.reporter ())

let secret_key = `Ephemeral
let listen_address = `TCP ("127.0.0.1", 7000)

let start_server =
  Lwt_main.run
    (print_endline "Running";
     let config =
       Capnp_rpc_unix.Vat_config.create ~serve_tls:false ~secret_key
         listen_address
     in
     let service_id = Capnp_rpc_net.Restorer.Id.public "" in
     Conductor.make () >>= fun conductor ->
     let restore =
       Capnp_rpc_net.Restorer.single service_id (Conductor.registrar conductor)
     in
     Capnp_rpc_unix.serve config ~restore >>= fun vat ->
     let uri = Capnp_rpc_unix.Vat.sturdy_uri vat service_id in
     Log.info (fun m -> m "Services running on: %a@." Uri.pp_hum uri);
     fst @@ Lwt.wait ())

open Cmdliner

let serve_cmd =
  ( Term.(const start_server),
    let doc = "run server" in
    Term.info "serve" ~doc )

let () = Term.eval serve_cmd |> Term.exit
