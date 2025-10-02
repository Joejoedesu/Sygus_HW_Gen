; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 8))) (_ FloatingPoint 8 8)
((Start (_ FloatingPoint 8 8)) (CaseBool Bool))
((Start (_ FloatingPoint 8 8)
   (
             (fp.add RNE Start Start)
             (fp.sub RNE Start Start)
             (fp.mul RNE Start Start)
             (fp.div RNE Start Start)
             (fp.neg Start)

             (fp.abs Start)
             (fp.sqrt RNE Start)

             (_ +zero 8 8)
             (_ -zero 8 8)
             (_ +oo 8 8)
             (_ -oo 8 8)
             (_ NaN 8 8)

             ((_ to_fp 8 8) RNE 1.0); must add this for the + c term

             x
             (ite CaseBool Start Start)))
    (CaseBool Bool (( fp.lt Start Start)
    			( fp.gt Start Start)
    			(= Start Start)
             ))))

; constraint: directly expressing the function
(declare-var r Real)
(declare-var x (_ FloatingPoint 8 8))
(assume (= x ((_ to_fp 8 8) RNE r)))
; (constraint (= r (fp.to_real x)))
; assume perfect approximation
; (constraint (= (f x) ((_ to_fp 8 8) RNE r)))
(constraint (= (f x) ((_ to_fp 8 8) RNE (+ r 1.0))))
; (constraint (= (f x) ((_ to_fp 8 8) RNE (+ r 2.0))))
; assume unreoverable approximation, takes much much longer
; (constraint (fp.lt (fp.abs (fp.sub RNE (f x) ((_ to_fp 8 8) RNE r))) ((_ to_fp 8 8) RNE 1.0)))
; (constraint (= (f x) ((_ to_fp 8 8) RNE (+ (+ (* r r) r) 2.0))))
; (constraint (= (f x) ((_ to_fp 8 8) RNE (* r r))))
; restrict the range of r
(assume (<= r 1.0))
(assume (>= r 0.0))

; (constraint (= x (f x)))

(check-synth)