; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)) (Const (_ FloatingPoint 8 24)) (CaseBool Bool))
((Start (_ FloatingPoint 8 24)
   (
             x
             (fp.add RNE Start Const)
             (fp.add RNE Start Start)
             (fp.mul RNE Start Const)
             (ite CaseBool Start Start)
             ))
   (Const (_ FloatingPoint 8 24)
   (
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
            (fp.mul RNE Const Const)
            ; (fp.div RNE Const Const)
            (fp.add RNE Const Const)
            (ite CaseBool Const Const)
            ))
   (CaseBool Bool 
   (        ( fp.lt Start Start)
    			(= Start Start)
            ; (and CaseBool CaseBool)
            ; (or CaseBool CaseBool)
            ; (not CaseBool)
             ))))

; constraint: directly expressing the function
; 2 * r + 5
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE -3.945)) ((_ to_fp 8 24) RNE -2.881))) ((_ to_fp 8 24) RNE 1.0)))
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.435)) ((_ to_fp 8 24) RNE 15.799))) ((_ to_fp 8 24) RNE 1.0)))
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE -0.960)) ((_ to_fp 8 24) RNE 3.176))) ((_ to_fp 8 24) RNE 1.0)))
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.668)) ((_ to_fp 8 24) RNE 16.258))) ((_ to_fp 8 24) RNE 1.0)))
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE 2.708)) ((_ to_fp 8 24) RNE 10.329))) ((_ to_fp 8 24) RNE 1.0)))
(constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.381)) ((_ to_fp 8 24) RNE 5.695))) ((_ to_fp 8 24) RNE 1.0)))
; (constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.473)) ((_ to_fp 8 24) RNE -5.927))) ((_ to_fp 8 24) RNE 1.0)))
; (constraint (fp.lt (fp.abs (fp.sub RNE (f ((_ to_fp 8 24) RNE 8.558)) ((_ to_fp 8 24) RNE 22.189))) ((_ to_fp 8 24) RNE 1.0)))

; add the explicit formula to see what happens

; (define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (fp.add roundNearestTiesToEven (fp.mul roundNearestTiesToEven 
; (fp.add roundNearestTiesToEven x (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)))

(check-synth)