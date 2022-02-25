open Capnp_rpc_lwt

let src = Logs.Src.create "service_resolver" ~doc:"Service Resolver"

module Make (DB : Db.S) = struct
  module Log = (val Logs.src_log src : Logs.LOG)
  module Api = Homeos_protocols.Services.MakeRPC (Capnp_rpc_lwt)
  module SP = Homeos_protocols.Services.Make (Capnp.BytesMessage)

  let make service_id =
    let module Resolver = Api.Service.ServiceResolver in
    Resolver.local
    @@ object
         inherit Resolver.service

         method resolve_impl _ release_caps =
           let open Resolver.Resolve in
           Log.info (fun m ->
               m "Resolving services for: %a" Uuidm.pp service_id);
           (* Create the required services, for now, we'll just pass a Pinger to see if things actually work*)
           release_caps ();
           let pinger = Pinger.local in
           let response, results =
             Service.Response.create Results.init_pointer
           in
           let module SB = Api.Builder.Service in
           let svcs = Results.services_init results 1 in
           let svc = Capnp.Array.get svcs 0 in
           SB.name_set svc "pinger";
           SB.ping_set svc (Some pinger);
           Service.return response
       end
end
