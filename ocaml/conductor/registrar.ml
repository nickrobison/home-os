open Lwt.Infix
open Capnp_rpc_lwt

let src = Logs.Src.create "registrar" ~doc:"Service Registrar"

module Log = (val Logs.src_log src : Logs.LOG)
module Api = Conductor_protocols.Registrar.MakeRPC (Capnp_rpc_lwt)
module RP = Conductor_protocols.Registration.Make (Capnp.BytesMessage)

module Callback = struct
  let callback t _resp =
    let open Api.Client.RegistrationCallback.Callback in
    let request, params = Capability.Request.create Params.init_pointer in
    let builder = Params.response_init params in
    RP.Builder.RegistrationResponse.failure_set builder "So close";
    Capability.call_for_unit_exn t method_id request
end

let notify callback ~resp =
  Callback.callback callback resp >|= fun () ->
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
             let resp = RP.Builder.RegistrationResponse.init_root () in
             RP.Builder.RegistrationResponse.failure_set resp "So close";
             Capability.with_ref callback (notify ~resp)
     end
