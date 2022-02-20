open Lwt.Infix
open Capnp_rpc_lwt

let src = Logs.Src.create "registrar" ~doc:"Service Registrar"

module Log = (val Logs.src_log src : Logs.LOG)
module Api = Homeos_protocols.Registrar.MakeRPC (Capnp_rpc_lwt)
module RP = Homeos_protocols.Registration.Make (Capnp.BytesMessage)

module Callback = struct
  let succeed t resolver =
    let open Api.Client.RegistrationCallback.Success in
    let request, params = Capability.Request.create Params.init_pointer in
    Params.resolver_set params (Some resolver);
    Capability.call_for_unit_exn t method_id request

  let fail t msg =
    let open Api.Client.RegistrationCallback.Failure in
    let request, params = Capability.Request.create Params.init_pointer in
    Params.err_set params msg;
    Capability.call_for_unit_exn t method_id request
end

let handle_registration callback ~name =
  Log.info (fun m -> m "Successfully registered %s" name);
  (* Create a new service resolver and return it*)
  let resolver = Service_resolver.make name in
  Callback.succeed callback resolver >|= fun () ->
  Ok (Service.Response.create_empty ())

let local =
  let module Registrar = Api.Service.Registrar in
  Registrar.local
  @@ object
       inherit Registrar.service

       method register_impl params release_param_caps =
         let open Registrar.Register in
         let request = Params.request_get params in
         let name = RP.Reader.RegistrationRequest.name_get request in
         let callback = Params.callback_get params in
         Log.info (fun m -> m "Received registration request for: `%s`" name);
         release_param_caps ();
         match callback with
         | None -> Service.fail "No callback"
         | Some callback ->
             Service.return_lwt @@ fun () ->
             Capability.with_ref callback (handle_registration ~name)
     end
