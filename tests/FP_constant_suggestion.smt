; simple testing for FP synthesis approximating the multi-segment
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)) (Const (_ FloatingPoint 8 24)))
(
   (Start (_ FloatingPoint 8 24)
   (
            (fp.add RNE (fp.mul RNE x Const) Const)
            ))
   (Const (_ FloatingPoint 8 24)
   (
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
            ((_ to_fp 8 24) roundNearestTiesToEven 0.0)
            ; add 0?
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
            (fp.add RNE Const Const)
            (fp.mul RNE Const Const)
            (fp.div RNE Const Const)
            ;better ways?
            ; (ite CaseBool Const Const)
            ))
            ))

; constraint: directly expressing the function
; (push 1)
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367)) ((_ to_fp 8 24) RNE 0.5))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875)) ((_ to_fp 8 24) RNE 0.5))))
(check-synth)
; (pop 1)
(push 1)
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469)) ((_ to_fp 8 24) RNE 0.5))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875)) ((_ to_fp 8 24) RNE 0.5))))
(check-synth)
