open! Core

type t = { a : int; b : int; log_bins : int } [@@deriving compare, sexp]

let hash { a; b; log_bins } v = ((a * v) + b) lsr (63 - log_bins)

let gen_multiply_shift ?(max_time = Time.Span.millisecond) ?(seed = 0) keys =
  let rand = Random.State.make [| seed |] in
  let log_bins = Int.ceil_log2 (List.length keys) in
  let nbins = Int.(2 ** log_bins) in
  let max_b = Int.(2 ** (63 - log_bins)) in
  let collider = Array.create ~len:nbins 0 in
  let start_time = Time.now () in
  let rec loop () =
    if Time.diff (Time.now ()) start_time > max_time then None
    else
      let a = Random.State.int rand Int.max_value in
      let a = if a mod 2 = 0 then a + 1 else a in
      let b = Random.State.int rand max_b in
      let h = { a; b; log_bins } in
      let rec any_collide = function
        | [] -> false
        | k :: ks ->
            let v = hash h k in
            if v < 0 || v >= nbins then
              failwith
                (sprintf "Bad hash value: a=%d, b=%d, m=%d, k=%d, v=%d" a b
                   log_bins k v);
            if collider.(v) > 0 then true
            else (
              collider.(v) <- 1;
              any_collide ks )
      in
      if any_collide keys then (
        Array.fill collider ~pos:0 ~len:nbins 0;
        loop () )
      else Some h
  in
  loop ()

let%expect_test "" =
  gen_multiply_shift [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]
  |> [%sexp_of: t option] |> print_s;
  [%expect
    {| (((a 2497643567980153265) (b 541917767041968936) (log_bins 4))) |}]

let%expect_test "" =
  gen_multiply_shift (List.init 100 ~f:Fun.id)
  |> [%sexp_of: t option] |> print_s;
  [%expect {| (((a 3849860515398355207) (b 69325505536368030) (log_bins 7))) |}]
