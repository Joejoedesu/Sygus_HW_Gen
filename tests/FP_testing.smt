; simple testing for FP synthesis -> squaring function
(set-logic ALL)

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

             ((_ to_fp  8 8) RNE 1.0); must add this for the + 1 term

             x
             (ite CaseBool Start Start)))
    (CaseBool Bool (( fp.lt Start Start)
    			( fp.gt Start Start)
    			(= Start Start)
             ))))

; constraint: construct by examples
(constraint (= (f (_ +zero 8 8)) ((_ to_fp  8 8) RNE 1.0)))
(constraint (= (f ((_ to_fp 8 8) RNE 2.0)) ((_ to_fp  8 8) RNE 5.0)))
(constraint (= (f ((_ to_fp 8 8) RNE -3.0)) ((_ to_fp  8 8) RNE 10.0)))

(check-synth)

