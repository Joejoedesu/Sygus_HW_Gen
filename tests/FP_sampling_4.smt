; simple testing for FP synthesis approximating the multi-segment
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)) (Const (_ FloatingPoint 8 24)) (CaseBool Bool))
((Start (_ FloatingPoint 8 24)
   (
             x
             (fp.add RNE Start Const)
             (fp.mul RNE Start Const)
            ; (fp.add RNE Const (fp.mul RNE x Const))
            (ite CaseBool Start Start)
            ))
   (Const (_ FloatingPoint 8 24)
   (
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
            ; add 0?
            ; ((_ to_fp 8 24) roundNearestTiesToEven 0.5)
            (fp.mul RNE Const Const)
            (fp.div RNE Const Const)
            (fp.add RNE Const Const)
            ; (ite CaseBool Const Const)
            ))
   (CaseBool Bool 
   (        (fp.leq Start Const)
            ; add constraint to the size of the interval
            ; (fp.leq Const Start)
    			; (= Start Start)
            ; (and CaseBool CaseBool)
            ; (or CaseBool CaseBool)
            ; (not CaseBool)
             ))))

; constraint: directly expressing the function
(push 1)

(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE 0.00669285049661994))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0)) ((_ to_fp 8 24) RNE 0.00669285049661994)) ((_ to_fp 8 24) RNE 0.5))))
(check-synth)
(pop 1)
(push 1)
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.3333332538604736)) ((_ to_fp 8 24) RNE 0.20860852301120758))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.3333332538604736)) ((_ to_fp 8 24) RNE 0.20860852301120758)) ((_ to_fp 8 24) RNE 0.5))))

(check-synth)

; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.25)) ((_ to_fp 8 24) RNE 0.22270013391971588))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.25)) ((_ to_fp 8 24) RNE 0.22270013391971588)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.25)) ((_ to_fp 8 24) RNE 0.7772998213768005))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.25)) ((_ to_fp 8 24) RNE 0.7772998213768005)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.3333332538604736)) ((_ to_fp 8 24) RNE 0.7913914322853088))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.3333332538604736)) ((_ to_fp 8 24) RNE 0.7913914322853088)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.4166666269302368)) ((_ to_fp 8 24) RNE 0.8048152923583984))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.4166666269302368)) ((_ to_fp 8 24) RNE 0.8048152923583984)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0)) ((_ to_fp 8 24) RNE 0.9933071136474609))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0)) ((_ to_fp 8 24) RNE 0.9933071136474609)) ((_ to_fp 8 24) RNE 0.5))))

