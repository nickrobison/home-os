open! Lwt.Infix
open Capnp_rpc_lwt

let src = Logs.Src.create "registrar" ~doc:"Service Registrar"

module Log = (val Logs.src_log src : Logs.LOG)
module Api = Conductor_protocols.Registrar.MakeRPC (Capnp_rpc_lwt)
module RP = Conductor_protocols.Registration.Make (Capnp.BytesMessage)

let local =
  let module Registrar = Api.Service.Registrar in
  Registrar.local
  @@ object
       inherit Registrar.service

       method register_impl params release_param_caps =
         let open Registrar.Register in
         let request = Params.request_get params in
         let name = RP.Reader.RegistrationRequest.name_get request in
         Log.info (fun m -> m "Received registration request for: `%s`" name);
         release_param_caps ();
         Service.return_empty ()
     end
