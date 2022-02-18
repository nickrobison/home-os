open! Lwt.Infix
open Capnp_rpc_lwt

let src = Logs.Src.create "pinger" ~doc:"Simple ping service"

module Log = (val Logs.src_log src : Logs.LOG)
module Api = Conductor_protocols.Services.MakeRPC (Capnp_rpc_lwt)

let local =
  let module Ping = Api.Service.Ping in
  Ping.local
  @@ object
       inherit Ping.service

       method ping_impl _ release_param_caps =
         let open Ping.Ping in
         Log.info (fun m -> m "Received ping request, replying");
         release_param_caps ();
         let response, results = Service.Response.create Results.init_pointer in
         Results.response_set results "Pong";
         Service.return response

       method reply_impl params release_param_caps =
         let open Ping.Reply in
         let msg = Params.msg_get params in
         release_param_caps ();
         Log.info (fun m -> m "Received message %s, replying" msg);
         let response, results = Service.Response.create Results.init_pointer in
         Results.response_set results msg;
         Service.return response
     end
