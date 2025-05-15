open Lwt.Infix

let src = Logs.Src.create "Conductor(Main)" ~doc:"HomeOS Conductor (Main)"

module Info = struct
  let info = Irmin_git_unix.info
end

module Log = (val Logs.src_log src : Logs.LOG)
module Store = Irmin_git_unix.FS.KV (Irmin.Contents.Json_value)
module Conductor = Conductor.Make (Store)

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
     Conductor.make { bootstrap_key = Some "hello"; db_config = () }
     >>= fun conductor ->
     let restore =
       Capnp_rpc_net.Restorer.single service_id (Conductor.registrar conductor)
     in
     Capnp_rpc_unix.serve config ~restore >>= fun vat ->
     let uri = Capnp_rpc_unix.Vat.sturdy_uri vat service_id in
     Log.info (fun m -> m "Services running on: %a@." Uri.pp_hum uri);
     fst @@ Lwt.wait ())

open Cmdliner

let serve_term = Term.const start_server
let sc = Cmd.v (Cmd.info "serve") serve_term
let () = Cmd.eval sc |> exit
