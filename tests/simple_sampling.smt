(set-logic ALL)
(set-option :produce-models true)

(assert (fp.lt (fp.abs (fp.sub RNE (fp.add RNE ((_ to_fp 8 24) RNE 5.0) (fp.mul RNE ((_ to_fp 8 24) RNE 2.0) 
        ((_ to_fp 8 24) RNE -0.960))) ((_ to_fp 8 24) RNE 3.176))) ((_ to_fp 8 24) RNE 1.0)))

; (assert (fp.lt (fp.abs (fp.sub RNE (fp.add RNE (((_ to_fp 8 24) RNE 5.0) (fp.mul RNE ((_ to_fp 8 24) RNE 2.0) ((_ to_fp 8 24) RNE -3.945)))) ((_ to_fp 8 24) RNE -2.881))) ((_ to_fp 8 24) RNE 1)))

(check-sat)
(get-model)