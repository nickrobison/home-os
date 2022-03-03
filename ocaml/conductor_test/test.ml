let () = Lwt_main.run @@ Alcotest_lwt.run "conductor" Db.test_cases
