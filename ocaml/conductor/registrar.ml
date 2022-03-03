open Lwt.Infix
open Capnp_rpc_lwt

let src = Logs.Src.create "registrar" ~doc:"Service Registrar"

module Make (DB : Db.S) = struct
  module Log = (val Logs.src_log src : Logs.LOG)
  module Api = Homeos_protocols.Registrar.MakeRPC (Capnp_rpc_lwt)
  module RegistrationApi = Homeos_protocols.Registration.MakeRPC (Capnp_rpc_lwt)
  module Resolver = Service_resolver.Make (DB)

  module Callback = struct
    let succeed t ~resolver =
      let open RegistrationApi.Client.RegistrationCallback.Success in
      let request, params = Capability.Request.create Params.init_pointer in
      Params.resolver_set params (Some resolver);
      Log.info (fun m -> m "Calling, let's see if this works");
      Capability.call_for_unit_exn t method_id request

    let fail t msg =
      let open RegistrationApi.Client.RegistrationCallback.Failure in
      let request, params = Capability.Request.create Params.init_pointer in
      Params.err_set params msg;
      Capability.call_for_unit_exn t method_id request
  end

  let rpc_fail msg = `Capnp (`Exception (Capnp_rpc.Exception.v msg))

  let approve_service db id () =
    let module R = RegistrationApi.Reader.RegistrationRequest in
    DB.get_registration db ~id >>= function
    | Error e ->
        Log.err (fun m -> m "Unable to get registration: %a" DB.pp_read_error e);
        Lwt.return_unit
    | Ok registration -> (
        match R.callback_get registration.details with
        | None -> Lwt.return_unit
        | Some callback ->
            Log.info (fun m -> m "I have a callback, replying");
            let resolver = Resolver.make id in
            Callback.succeed callback ~resolver)

  let wakeup : unit Lwt.t option ref = ref None

  (** Register application for later approval*)
  let handle_registration ~db ~request ~name () =
    (* Submit the new request to the database*)
    DB.create_registration db ~app:request >>= function
    | Error _e -> Lwt.return_error (rpc_fail "Cannot persist in DB")
    | Ok id ->
        Log.info (fun m ->
            m "Successfully registered service: `%s` with id: %a" name Uuidm.pp
              id);
        (* This is hacky, but we'll just wait for 3 seconds and then approve async like*)
        Log.warn (fun m -> m "Waiting 3 seconds and then auto approving");
        wakeup := Some (Lwt.bind (Lwt_unix.sleep 3.) (approve_service db id));
        Lwt.return_ok (Service.Response.create_empty ())

  (** Register and immediately approve*)
  let handle_boostrap ~db ~request ~name callback () =
    DB.create_registration db ~app:request >>= function
    | Error _e -> Lwt.return_error (rpc_fail "Cannot persist in DB")
    | Ok id -> (
        DB.set_registration_status db ~user:User.system_user ~id Approved
        >>= function
        | Error _e -> Lwt.return_error (rpc_fail "Unable to approve service")
        | Ok () ->
            Log.info (fun m ->
                m "Successfully bootstrapped service: `%s` with id: %a" name
                  Uuidm.pp id);
            let resolver = Resolver.make id in
            Callback.succeed callback ~resolver >>= fun () ->
            Lwt.return_ok (Service.Response.create_empty ()))

  let handle_auth ~bootstrap_key ~bootstrap_fn ~register_fn request_key =
    match (bootstrap_key, request_key) with
    | Some bk, Some rq ->
        (* TODO: This should be a constant time comparison*)
        if String.equal bk rq then bootstrap_fn ()
        else (
          Log.err (fun m -> m "Bootstrap authentication failed");

          Lwt.return_error (rpc_fail "Not authorized to bootstrap"))
    | _, _ -> register_fn ()

  let local key db =
    let module Registrar = Api.Service.Registrar in
    Registrar.local
    @@ object
         inherit Registrar.service

         method register_impl params _release_param_caps =
           let open Registrar.Register in
           let request = Params.request_get params in
           let name =
             RegistrationApi.Reader.RegistrationRequest.name_get request
           in
           let callback =
             RegistrationApi.Reader.RegistrationRequest.callback_get request
           in
           let request_key =
             match
               RegistrationApi.Reader.RegistrationRequest.bootstrap_key_get
                 request
             with
             | "" -> None
             | s -> Some s
           in
           Log.info (fun m -> m "Received registration request for: `%s`" name);
           match callback with
           | None -> Service.fail "No callback"
           | Some callback ->
               Service.return_lwt @@ fun () ->
               handle_auth ~bootstrap_key:key
                 ~bootstrap_fn:(handle_boostrap ~db ~request ~name callback)
                 ~register_fn:(handle_registration ~db ~request ~name)
                 request_key
       end
end
