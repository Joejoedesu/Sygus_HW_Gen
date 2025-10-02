; simple testing for FP synthesis -> squaring function
(set-logic ALL)

(synth-fun f ((x (_ FloatingPoint 8 8))) (_ FloatingPoint 8 8)
((Start (_ FloatingPoint 8 8)) (CaseBool Bool))
((Start (_ FloatingPoint 8 8)
   (
             (fp.add RNE Start Start)
             (fp.sub RNE Start Start)
             (fp.neg Start)
            ;  (fp.mul RNE Start Start)

            ;  (fp.abs Start)

             (_ +zero 8 8)
             (_ -zero 8 8)
             (_ +oo 8 8)
             (_ -oo 8 8)
             (_ NaN 8 8)

             ((_ to_fp  8 8) RNE 1.0); must add this for the + 1 term
             ((_ to_fp  8 8) RNE 2.4); must add this for the + 1 term

             x
             (ite CaseBool Start Start)))
    (CaseBool Bool (( fp.lt Start Start)
    			( fp.gt Start Start)
    			(= Start Start)
             ))))

; constraint: construct by examples
(declare-var x (_ FloatingPoint 8 8) )
(assume (fp.lt x ((_ to_fp 8 8) RNE 3.0)))
(assume (fp.gt x ((_ to_fp 8 8) RNE -3.0)))
; the following takes a long time
(constraint (fp.lt (fp.abs (fp.sub RNE (f x) (fp.mul RNE x ((_ to_fp 8 8) RNE 2.4)))) ((_ to_fp 8 8) RNE 1.0)))
; this one works fine
; (constraint (fp.lt (fp.abs (fp.sub RNE (f x) (fp.abs x))) ((_ to_fp 8 8) RNE 1.0)))
; (constraint (= (f x) (fp.add RNE (fp.mul RNE x x) ((_ to_fp 8 8) RNE 2.4))))

(check-synth)

