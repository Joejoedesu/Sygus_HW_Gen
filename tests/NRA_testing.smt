; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic NRA)

(synth-fun f ((x Real)) Real
((Start Real) (CaseBool Bool))
((Start Real
   (
            ;  (_ +zero 8 24)
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            1.0
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
             x
             (+ Start Start)
             (ite CaseBool Start Start)))
   (CaseBool Bool 
   (        (< Start Start)
            (= Start Start)
            (and CaseBool CaseBool)
            (or CaseBool CaseBool)
            (not CaseBool)
             ))))

; constraint: directly expressing the function
(declare-var x Real)

(constraint (=> (and (<= x 1.0) (>= x -1.0))
                (< (abs (- (f x) (+ x 2.0))) 0.1)))

(check-synth)