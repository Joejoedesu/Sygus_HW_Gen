; simple testing for FP synthesis approximating the non-linear function x^2 + x + 2
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
((Start (_ FloatingPoint 8 24)))
((Start (_ FloatingPoint 8 24)
   (
            ;  (_ +zero 8 24)
            ;  ((_ to_fp 8 24) RNE 1.0); must add this for the + c term
            ((_ to_fp 8 24) roundNearestTiesToEven 1.0)
             x
             (fp.add RNE Start Start)))))
            ;  (fp.mul RNE Start Start)
            ;  (fp.neg Start)))))

            ;  (ite CaseBool Start Start)))))
   ;  (CaseBool Bool (( fp.lt Start Start)
   ;  ; and or operations
   ;  			( fp.gt Start Start); not necessary
   ;  			(= Start Start); not necessary
   ;           ))))

; constraint: directly expressing the function
(declare-var r Real)
(declare-var x (_ FloatingPoint 8 24))

; restrict the range of r
; (assume (<= r 1.0)); range x?, which 
; (assume (>= r 0.0))

; (assume (< (fp.to_real x) 1.0)); range x?, which 
; (assume (> (fp.to_real x) 0.0)); also try the bound in the fp 

; (constraint (=> (and (<= r 1.0) (>= r 0.0))
;                 (= (f x) ((_ to_fp 8 8) RNE r))))
; (assume (= x ((_ to_fp 8 8) RNE r))); try the other way
; (constraint (= (f x) ((_ to_fp 8 8) RNE (+ r 1.0))))
; (constraint (= (fp.to_real (f x)) (+ (fp.to_real x) 1.0)))
; (constraint (=> (and (< (fp.to_real x) 1.0) (> (fp.to_real x) 0.0))
;                 (= (fp.to_real (f x)) (+ (fp.to_real x) 1.0))))
(constraint (=> (and (= x ((_ to_fp 8 24) RNE r)) (<= r 2.0) (>= r -2.0))
                (fp.lt (fp.abs (fp.sub RNE (f x)
                 ((_ to_fp 8 24) RNE (+ r 2.0)))) ((_ to_fp 8 24) RNE 0.05))))


; (constraint (= x (f x)))

(check-synth)