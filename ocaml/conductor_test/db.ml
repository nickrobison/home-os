open Lwt.Syntax

module Info = struct
  let info = Irmin_unix.info
end

module Store = Irmin_mem.KV (Irmin.Contents.Json_value)
module DB = Conductor__.Db_memory
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
  d

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
    hash =
      "31c658bd0c49e3f790c21beb9f32a9463e9fcbf7473cbc3b8845b4e31c8c240a758864850c7e9093b8c93430b83df8e0fa3a1a6eb80953b3933f94bfa3031739";
    details;
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
                Reg.Builder.RegistrationRequest.description_get v.details
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
