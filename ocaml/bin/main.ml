open  Lwt.Infix

let src = Logs.Src.create "Conductor" ~doc: "HomeOS Conductor"

module Log = (val Logs.src_log src: Logs.LOG)

let () =
Logs.set_level (Some Logs.Info);
Logs.set_reporter (Logs_fmt.reporter ())

let secret_key = `Ephemeral
let listen_address = `TCP ("127.0.0.1", 7000)

let start_server =
Lwt_main.run begin
print_endline "Running";
let config = Capnp_rpc_unix.Vat_config.create ~serve_tls:false ~secret_key listen_address in
let service_id = Capnp_rpc_unix.Vat_config.derived_id config "registrar" in
let restore = Capnp_rpc_net.Restorer.single service_id Conductor__.Registrar.local in
Capnp_rpc_unix.serve config ~restore >>= fun vat ->
let uri = Capnp_rpc_unix.Vat.sturdy_uri vat service_id in
Log.info (fun m -> m"Services running on: %a@." Uri.pp_hum uri);
fst @@ Lwt.wait ()
end

open Cmdliner

let serve_cmd =
Term.(const start_server), let doc = "run server" in
Term.info "serve" ~doc

let () = Term.eval serve_cmd |> Term.exit