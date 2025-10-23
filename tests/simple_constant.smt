(set-logic QF_LRA)
(set-option :produce-models true)

; Declare unknowns a and b as real numbers
(declare-const a Real)
(declare-const b Real)

; Define the function f(x) = a*x + b
(define-fun f ((x Real)) Real
  (+ (* a x) b))

; Constraints from the two given points
; (assert (= (f 1.1) 3.2))
; (assert (= (f -1.1) -1.2))
(assert (and (< (- 0.001) (-(f 1.6666666269302368) 2.9836666584014893)) (< (-(f 1.6666666269302368) 2.9836666584014893) 0.001)))
(assert (and (< (- 0.001) (-(f 5.0000000000000000) 3.2169997692108154)) (< (-(f 5.0000000000000000) 3.2169997692108154) 0.001)))

; Ask the solver to find a model
(check-sat)
(get-model)