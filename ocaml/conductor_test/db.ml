open Lwt.Syntax

module Info = struct
  let info = Irmin_git_unix.info
end

module Store = Irmin_mem.KV.Make (Irmin.Contents.Json_value)
module DB = Conductor.Db_memory
module Reg = Homeos_protocols.Registration.Make (Capnp.BytesMessage)

let user = Conductor__.User.system_user

let app_test =
  Alcotest.testable Conductor__.Models.pp_application_record
    Conductor.Models.equal_application_record

let status_test =
  Alcotest.testable Conductor.Models.pp_registration_status
    Conductor.Models.equal_registration_status

let config () = DB.create ()

let details =
  let open Reg.Builder.RegistrationRequest in
  let d = init_root () in
  name_set d "Test request";
  description_set d "Test Description";
  to_reader d

let uuid_gen_exn str =
  match Uuidm.of_string str with Some v -> v | None -> failwith "Invalid uuid"
(*Should never happen*)

let test_id = uuid_gen_exn "35acc634-6f7b-4c1e-95f6-e55b19cc189a"
let missing_id = uuid_gen_exn "11acc634-6f7b-4c1e-95f6-e55b19cc189a"

let app : Conductor.Models.application_record =
  {
    id = test_id;
    name = "Test request";
    status = Pending;
    details;
    hash =
      "551f1d99d289f1b9ce06812902f8f3e42d373c25c292ee4b3ccf7091a77796b763aa246706a2ea5fe41b24009337b9329534d4b4021d351c67d7bc71812caa02";
  }

let simple_get _ () =
  let* store = config () in
  let* res = DB.create_registration store ~app:details in
  match res with
  | Error _ -> Alcotest.fail "bad, bad, bad"
  | Ok id -> (
      let+ v = DB.get_registration store ~id in
      match v with
      | Ok v -> Alcotest.(check app_test) "Should be equal" { app with id } v
      | Error e -> Alcotest.failf "Unexpected error: %a" DB.pp_read_error e)

let update_status _ () =
  let* store = config () in
  let* res = DB.create_registration store ~app:details in
  match res with
  | Error _ -> Alcotest.fail "Unable to create record"
  | Ok id -> (
      let* res = DB.set_registration_status store ~user Approved ~id in
      match res with
      | Error e ->
          Alcotest.failf "Unable to update record: %a" DB.pp_read_error e
      | Ok () -> (
          let+ v = DB.get_registration store ~id in
          match v with
          | Error e ->
              Alcotest.failf "Unable to get record: %a" DB.pp_read_error e
          | Ok v ->
              Alcotest.(check status_test) "Should be equal" Approved v.status;
              let description =
                Reg.Reader.RegistrationRequest.description_get v.details
              in
              Alcotest.(check string)
                "Should have correct description" "Test Description" description
          ))

let get_unknown _ () =
  let* store = config () in
  let+ res = DB.get_registration store ~id:missing_id in
  match res with
  | Ok _ -> Alcotest.fail "Should not find record"
  | Error e -> (
      match e with
      | `Not_found msg ->
          Alcotest.(check string)
            "Should have correct error" "Cannot find key" msg
      | e -> Alcotest.failf "Unexpected error: %a" DB.pp_read_error e)

let update_unknown _ () =
  let* store = config () in
  let+ res = DB.set_registration_status store ~user Approved ~id:missing_id in
  match res with
  | Ok _ -> Alcotest.fail "Should not find record"
  | Error e -> (
      match e with
      | `Not_found msg ->
          Alcotest.(check string)
            "Should have correct error" "Cannot find key" msg
      | e -> Alcotest.failf "Unexpected error: %a" DB.pp_read_error e)

let test_cases =
  [
    ( "db_irmin",
      [
        Alcotest_lwt.test_case "Simple get/set" `Quick simple_get;
        Alcotest_lwt.test_case "Update status" `Quick update_status;
        Alcotest_lwt.test_case "Get unknown id" `Quick get_unknown;
        Alcotest_lwt.test_case "Update unknown record" `Quick update_unknown;
      ] );
  ]
