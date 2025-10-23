; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic NRAT)

(synth-fun f ((x Real)) Real
((Start Real) (Const Real) (CaseBool Bool))
((Start Real
   (
            ;  (_ +zero 8 24)
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
             x
            ;  (+ Const Start)
            ;  (* Start Start)
            ;  (* Const Start)
            (+ Const (* Const Start))
            (ite CaseBool Start Start)
   ))
   (Const Real
   (
            ; 1.0
            ; (+ Const Const)
            ; (/ Const Const)
            ; (* Const Const)
            1.0
            (+ Const Const)
            (* 2.0 Const)
            (* 0.5 Const)
   ))
   (CaseBool Bool 
   (        (<= Start Start)
            (and CaseBool CaseBool)
            (or CaseBool CaseBool)
   ))))

; constraint: directly expressing the function
(declare-var x Real)

; (constraint (=> (and (<= x 1.0) (>= x -1.0))
;                 (< (abs (- (f x) (+ (* 2 x) 5.0))) 0.1)))
(constraint (=> (and (<= x 1.0) (>= x -1.0))
                (< (abs (- (f x) (* 2.5 (* x x)))) 0.5)))

(check-synth)