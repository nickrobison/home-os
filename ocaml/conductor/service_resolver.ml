open Capnp_rpc_lwt

let src = Logs.Src.create "service_resolver" ~doc:"Service Resolver"

module Log = (val Logs.src_log src: Logs.LOG)
module Api = Conductor_protocols.Services.MakeRPC(Capnp_rpc_lwt)
module SP = Conductor_protocols.Services.Make (Capnp.BytesMessage)


let make service_name =
  let module Resolver = Api.Service.ServiceResolver in
  Resolver.local
    @@ object
      inherit Resolver.service

      method resolve_impl _ release_caps =
        let open Resolver.Resolve in
        Log.info(fun m -> m"Resolving services for: %s" service_name);
        (* Create the required services, for now, we'll just pass a Pinger to see if things actually work*)
        release_caps ();
        let _pinger = Pinger.local in
        let response, results = Service.Response.create Results.init_pointer in
        let svc = Api.Builder.Service.init_root () in
        Api.Builder.Service.name_set svc "pinger";
        Log.info(fun m -> m"Name set");
        Log.info(fun m -> m"Service set");
        let _ = Results.services_set_list results [svc] in
        Service.return response

      end



