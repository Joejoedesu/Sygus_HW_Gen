; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)) (Const (_ FloatingPoint 8 24)) (CaseBool Bool))
((Start (_ FloatingPoint 8 24)
   (
             x
             (fp.add RNE Start Const)
             (ite CaseBool Start Start)))
   (Const (_ FloatingPoint 8 24)
   (
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
            ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
            (fp.mul RNE Const Const)
            (fp.div RNE Const Const)
            (fp.add RNE Const Const)
            (ite CaseBool Const Const)))
   (CaseBool Bool 
   (        ( fp.lt Start Start)
    			(= Start Start)
            (and CaseBool CaseBool)
            (or CaseBool CaseBool)
            (not CaseBool)
             ))))

; constraint: directly expressing the function
(declare-var r Real)
(declare-var x (_ FloatingPoint 8 24))

; (constraint (=> (and (= x ((_ to_fp 8 24) RNE r)) (<= r 2.0) (>= r -2.0))
;                 (fp.lt (fp.abs (fp.sub RNE (f x)
;                  ((_ to_fp 8 24) RNE (+ r 1.0)))) ((_ to_fp 8 24) RNE 0.05))))
(constraint (=> (and (= x ((_ to_fp 8 24) RNE r)) (<= r 2.0) (>= r -2.0))
                (fp.lt (fp.abs (fp.sub RNE (f x)
                 ((_ to_fp 8 24) RNE (+ r 6.5)))) ((_ to_fp 8 24) RNE 0.05))))

(check-synth)