open Lwt.Syntax

module Info = struct
  let info = Irmin_unix.info
end

module Store = Irmin_mem.KV (Irmin.Contents.Json_value)
module DB = Conductor__.Db_irmin.Make (Store) (Info)

let user = Conductor__.User.system_user

let app_test =
  Alcotest.testable Conductor__.Models.pp_application_record
    Conductor__.Models.equal_application_record

let status_test =
  Alcotest.testable Conductor__.Models.pp_registration_status
    Conductor__.Models.equal_registration_status

let config () = DB.create (Irmin_mem.config ())
let ok _ () = Lwt.return (Alcotest.(check string) "hello" "hello" "hello")

let simple_get _ () =
  let app : Conductor__.Models.application_record =
    { id = "test"; name = "hello"; status = Pending; hash = "" }
  in
  let* store = config () in
  let* res = DB.create_registration store ~app in
  match res with
  | Error _ -> Alcotest.fail "bad, bad, bad"
  | Ok () -> (
      let+ v = DB.get_registration store ~id:app.id in
      match v with
      | Ok v -> Alcotest.(check app_test) "Should be equal" app v
      | Error e -> Alcotest.failf "Unexpected error: %a" DB.pp_read_error e)

let update_status _ () =
  let app : Conductor__.Models.application_record =
    { id = "test"; name = "hello"; status = Pending; hash = "" }
  in
  let* store = config () in
  let* res = DB.create_registration store ~app in
  match res with
  | Error _ -> Alcotest.fail "Unable to create record"
  | Ok () -> (
      let* res = DB.set_registration_status store ~user Approved ~id:"test" in
      match res with
      | Error e ->
          Alcotest.failf "Unable to update record: %a" DB.pp_read_error e
      | Ok () -> (
          let+ v = DB.get_registration store ~id:"test" in
          match v with
          | Error e ->
              Alcotest.failf "Unable to get record: %a" DB.pp_read_error e
          | Ok v ->
              Alcotest.(check status_test) "Should be equal" Approved v.status))

let get_unknown _ () =
  let* store = config () in
  let+ res = DB.get_registration store ~id:"missing" in
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
  let+ res = DB.set_registration_status store ~user Approved ~id:"missing" in
  match res with
  | Ok _ -> Alcotest.fail "Should not find record"
  | Error e -> (
      match e with
      | `Not_found msg ->
          Alcotest.(check string)
            "Should have correct error" "nope, not there" msg
      | e -> Alcotest.failf "Unexpected error: %a" DB.pp_read_error e)

let test_cases =
  [
    ( "db_irmin",
      [
        Alcotest_lwt.test_case "Success" `Quick ok;
        Alcotest_lwt.test_case "Simple get/set" `Quick simple_get;
        Alcotest_lwt.test_case "Update status" `Quick update_status;
        Alcotest_lwt.test_case "Get unknown id" `Quick get_unknown;
        Alcotest_lwt.test_case "Update unknown record" `Quick update_unknown;
      ] );
  ]
