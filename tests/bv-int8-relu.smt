; EXPECT: feasible
; COMMAND-LINE: --lang=sygus2 --sygus-out=status
(set-logic BV) ; set-logic ALL for now

(synth-fun f ((x (_ BitVec 8))) (_ BitVec 8)
((Start (_ BitVec 8)) (CaseBool Bool))
((Start (_ BitVec 8)
   (
             (bvadd Start Start)
             (bvand Start Start)
             (bvor Start Start)
             (bvneg Start)
             (bvshl Start Start)
             (bvlshr Start Start)

             #x01
             #x00
             #x02 x
             (ite CaseBool Start Start)
             ))
    (CaseBool Bool (( bvslt Start Start)
    			(bvsgt Start Start)
    			(= Start Start)
             ))))
; (declare-var x (_ BitVec 8) )

; property
; the condition that if x < 0 then f(x) = 0 else f(x) = x
; case 1, giving explicit expression for f(x)
;(constraint (= (f x) (ite (bvslt x #x00) #x00 x)))
; case 2, program by examples
(constraint (= (f #b10000000) #b00000000))
(constraint (= (f #b11111010) #b00000000))
(constraint (= (f #b11111100) #b00000001))
(constraint (= (f #b11111101) #b00000010))
(constraint (= (f #b11111110) #b00000110))
(constraint (= (f #b11111111) #b00001111))
(constraint (= (f #b00000001) #b00011011))
(constraint (= (f #b00000010) #b00100011))
(constraint (= (f #b00000011) #b00100111))
(constraint (= (f #b00000101) #b00101000))
(constraint (= (f #b01111111) #b00101000))
; they actually give the same constraint

(check-synth)
