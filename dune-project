(lang dune 1.11)

(name genhash)
(license MIT)
(authors "Jack Feser <feser@csail.mit.edu>")
(maintainers "Jack Feser <feser@csail.mit.edu>")
(source (github jfeser/genhash))
(documentation https://jfeser.github.io/genhash)

(package
 (name genhash)
 (synopsis "Generate hash functions")
 (depends
  (dune (and :build (>= 1.11)))
  (core (>= v0.12))
  (integers (>= 0.3))
  (ppx_sexp_conv (>= v0.12))
  (ppx_compare (>= v0.12))
  (ppx_expect (>= v0.12))
))

(generate_opam_files true)
