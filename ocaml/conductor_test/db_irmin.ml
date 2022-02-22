open Lwt.Syntax
module Store = Irmin_mem.KV (Irmin.Contents.Json_value)
module DB = Conductor__.Db_irmin.Make (Store)

let app_test =
  Alcotest.testable Conductor__.Models.pp_registered_application (fun l r ->
      Conductor__.Models.equal_registered_application l r)

let config () = DB.create (Irmin_mem.config ())
let ok _ () = Lwt.return (Alcotest.(check string) "hello" "hello" "hello")

let simple_get _ () =
  let app : Conductor__.Models.registered_application =
    {
      id = "test";
      name = "hello";
      status = Pending;
      consumes = [];
      produces = [];
      hash = "";
    }
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

let test_cases =
  [
    ( "db_irmin",
      [
        Alcotest_lwt.test_case "Success" `Quick ok;
        Alcotest_lwt.test_case "Simple get/set" `Quick simple_get;
      ] );
  ]
