; simple testing for FP synthesis approximating the multi-segment
(set-logic FPNRA)

(synth-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24)
(  (Start (_ FloatingPoint 8 24))
   (sign_b (_ BitVec 1))
   (exp_b (_ BitVec 8))
   (b2_construct (_ BitVec 2))
   (b4_construct (_ BitVec 4))
   (b6_construct (_ BitVec 6))
   (sig_b (_ BitVec 23))
   (Const (_ FloatingPoint 8 24)))
(
   (Start (_ FloatingPoint 8 24)
   (
            (fp.add RNE (fp.mul RNE x Const) Const)
            ))
   (sign_b (_ BitVec 1)
   (
            (_ bv0 1)
            (_ bv1 1)
            ))
   (exp_b (_ BitVec 8)
   (
            ; biased exponent for 8-bit exponent
            ; (bvadd #b01111111 (_ bv0 8)) ; exp = 0
            #b01111111 ; exp = 0
            (bvadd #b01111111 (_ bv1 8)) ; exp = 1
            (bvadd #b01111111 (_ bv2 8)) ; exp = 2
            (bvadd #b01111111 (_ bv3 8)) ; exp = 3
            (bvadd #b01111111 (_ bv4 8)) ; exp = 4
            (bvadd #b01111111 (_ bv5 8)) ; exp = 5
            ; (bvadd #b01111111 (_ bv6 8)) ; exp = 6
            ; (bvadd #b01111111 (_ bv7 8)) ; exp = 7
            ; (bvadd #b01111111 (_ bv8 8)) ; exp = 8
            ; (bvadd #b01111111 (_ bv9 8)) ; exp = 9
            ; (bvadd #b01111111 (_ bv10 8)); exp = 10
            ; #b00000000
            ; -1 to -8
            (bvadd #b01111111 (_ bv-1 8))
            ; (bvadd #b01111111 (_ bv-2 8))
            (bvadd #b01111111 (_ bv-3 8))
            ; (bvadd #b01111111 (_ bv-4 8))
            (bvadd #b01111111 (_ bv-5 8))
            ; (bvadd #b01111111 (_ bv-6 8))
            (bvadd #b01111111 (_ bv-7 8))
            ; (bvadd exp_b (_ bv1 8))
            ; (bvadd #b01111111 (_ bv-8 8))

            ))
   (b2_construct (_ BitVec 2)
   (
            ; #b00
            #b01
            #b10
            #b11
            ))
   (b4_construct (_ BitVec 4)
   (
            #b0000
            #b0001
            #b0010
            #b0011
            #b0100
            #b0101
            #b0110
            #b0111
            #b1000
            #b1001
            #b1010
            #b1011
            #b1100
            #b1101
            #b1110
            #b1111
            ))
   (b6_construct (_ BitVec 6)
   (
            ; (concat b2_construct #b0000)
            ; (concat b4_construct #b00)
            (concat b4_construct b2_construct)
            ))
   (sig_b (_ BitVec 23)
   (
            ; construct the 23-bit
            ; (concat sig_b_construct #b0000000000000000000)
            ; (concat (concat sig_b_construct sig_b_construct) #b000000000000000)
            ; significand for 1.xxxx
            #b00000000000000000000000 
            ; (concat b2_construct #b000000000000000000000)
            ; (concat b4_construct #b0000000000000000000)
            ; (concat (concat b4_construct b2_construct) #b00000000000000000)
            #b00010000000000000000000
            #b00100000000000000000000
            #b00110000000000000000000
            #b01000000000000000000000
            #b01010000000000000000000
            #b01100000000000000000000
            #b01110000000000000000000
            #b10000000000000000000000
            #b10100000000000000000000
            #b10110000000000000000000
            #b11000000000000000000000
            #b11010000000000000000000
            #b11100000000000000000000
            #b11110000000000000000000
            (concat b6_construct #b00000000000000000)

            ; #b00110100000000000000000
            ))
   (Const (_ FloatingPoint 8 24)
   (
            ((_ to_fp 8 24) (concat (concat sign_b exp_b) sig_b))
            ))
            ))

; constraint: directly expressing the function
; (push 1)
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469)) ((_ to_fp 8 24) RNE 0.5))))
; ; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875)) ((_ to_fp 8 24) RNE 0.5))))
; ; (check-synth)
; ; (pop 1)
; ; (push 1)
; ; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -9.2999992370605469)) ((_ to_fp 8 24) RNE 0.5))))
; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 0.0000000000000000)) ((_ to_fp 8 24) RNE 11.6999998092651367)) ((_ to_fp 8 24) RNE 0.5))))
; ; (constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.5)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 32.6999969482421875)) ((_ to_fp 8 24) RNE 0.5))))

(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -1.9999998807907104))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -5.0000000000000000)) ((_ to_fp 8 24) RNE -1.9999998807907104)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.6666666269302368)) ((_ to_fp 8 24) RNE 12.2333326339721680))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE -1.6666666269302368)) ((_ to_fp 8 24) RNE 12.2333326339721680)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.6666666269302368)) ((_ to_fp 8 24) RNE 26.4666652679443359))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 1.6666666269302368)) ((_ to_fp 8 24) RNE 26.4666652679443359)) ((_ to_fp 8 24) RNE 0.2))))
(constraint (and (fp.lt (fp.neg ((_ to_fp 8 24) RNE 0.2)) (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 40.6999969482421875))) (fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE 5.0000000000000000)) ((_ to_fp 8 24) RNE 40.6999969482421875)) ((_ to_fp 8 24) RNE 0.2))))
(check-synth)
