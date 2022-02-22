let () = Lwt_main.run @@ Alcotest_lwt.run "conductor" Db_irmin.test_cases
