open! Core

type t = { a : Int64.t; log_bins : int } [@@deriving compare, sexp]

let hash { a; log_bins } v = Int64.((a * v) lsr Int.(64 - log_bins))

let gen_multiply_shift ?(max_time = Time.Span.millisecond) ?(seed = 0) keys =
  let rand = Random.State.make [| seed |] in
  let log_bins = Int.ceil_log2 (List.length keys) in
  let nbins = Int.(2 ** log_bins) in
  let collider = Array.create ~len:nbins 0 in
  let start_time = Time.now () in
  let rec loop () =
    if Time.diff (Time.now ()) start_time > max_time then None
    else
      let a = Random.State.int64 rand Int64.max_value in
      let a = Int64.(if rem a 2L = 0L then a + 1L else a) in
      let h = { a; log_bins } in
      let rec any_collide = function
        | [] -> false
        | k :: ks ->
            let v = hash h k |> Int64.to_int_exn in
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
  gen_multiply_shift [ 1L; 2L; 3L; 4L; 5L; 6L; 7L; 8L; 9L; 10L ]
  |> [%sexp_of: t option] |> print_s;
  [%expect {| (((a 2497643567980153265) (log_bins 4))) |}]
