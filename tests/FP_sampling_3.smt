; simple testing for FP synthesis approximating the multi-segment
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)) (Const (_ FloatingPoint 8 24)) (CaseBool Bool))
((Start (_ FloatingPoint 8 24)
   (
             x
             (fp.add RNE Start Const)
             (fp.mul RNE Start Const)
             (ite CaseBool Start Start)
             ))
   (Const (_ FloatingPoint 8 24)
   (
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
            (fp.mul RNE Const Const)
            (fp.div RNE Const Const)
            (fp.add RNE Const Const)
            ; (ite CaseBool Const Const)
            ))
   (CaseBool Bool 
   (        (fp.leq Start Const)
            ; (fp.leq Const Start)
    			; (= Start Start)
            ; (and CaseBool CaseBool)
            ; (or CaseBool CaseBool)
            ; (not CaseBool)
             ))))

; constraint: directly expressing the function
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE -10.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE -10.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE -10.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE -10.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -0.5)) ((_ to_fp 8 24) RNE -1.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -0.5)) ((_ to_fp 8 24) RNE -1.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.5)) ((_ to_fp 8 24) RNE 1.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.5)) ((_ to_fp 8 24) RNE 1.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.0)) ((_ to_fp 8 24) RNE 2.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.0)) ((_ to_fp 8 24) RNE 2.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 3.0)) ((_ to_fp 8 24) RNE 4.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 3.0)) ((_ to_fp 8 24) RNE 4.0)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0)) ((_ to_fp 8 24) RNE 6.0))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0)) ((_ to_fp 8 24) RNE 6.0)) ((_ to_fp 8 24) RNE 0.2))))

; (define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (ite (fp.leq x ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) (fp.mul roundNearestTiesToEven x (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven x ((_ to_fp 8 24) roundNearestTiesToEven 1.0))))

(check-synth)