; simple testing for FP synthesis approximating the identity using BV
(set-logic FPBV)
(declare-datatype BV_BF16
    ((cons (sign_b (_ BitVec 1))
     (exp_b (_ BitVec 8))
     (sig_b (_ BitVec 7)))))

(synth-fun f ((x BV_BF16)) BV_BF16
((Full_BV BV_BF16) (CaseBool Bool) (SIGN (_ BitVec 1))
 (EXP (_ BitVec 8)) (SIG (_ BitVec 7)))
((Full_BV BV_BF16
   (
    (cons SIGN EXP SIG)
    x
   ))
(CaseBool Bool ((= (fp SIGN EXP SIG) (fp SIGN EXP SIG))
                (fp.lt (fp SIGN EXP SIG) (fp SIGN EXP SIG))))
(SIGN (_ BitVec 1) ((_ bv0 1)
                    (_ bv1 1)
                    (sign_b Full_BV)
                    (bvand SIGN SIGN)
                    (bvor SIGN SIGN)
                    (bvnot SIGN)))
(EXP (_ BitVec 8) ((_ bv0 8)
                   (_ bv1 8)
                   (exp_b Full_BV)
                   (bvand EXP EXP)
                   (bvor EXP EXP)
                   (bvnot EXP)
                   (bvshl EXP EXP)
                   (bvlshr EXP EXP)
                   (bvadd EXP EXP)))
(SIG (_ BitVec 7) ((_ bv0 7)
                    (_ bv1 7)
                    (sig_b Full_BV)
                    (bvand SIG SIG)
                    (bvor SIG SIG)
                    (bvnot SIG)
                    (bvshl SIG SIG)
                    (bvlshr SIG SIG)
                    (bvadd SIG SIG)))))

(declare-var x BV_BF16)
(declare-var bf (_ FloatingPoint 8 8))
(assume (fp.lt bf ((_ to_fp 8 8) RNE 1.0)))
(assume (fp.gt bf ((_ to_fp 8 8) RNE 0.0)))
(assume (= (fp (sign_b x) (exp_b x) (sig_b x)) bf))

(constraint (= ((_ to_fp 8 8) (concat (concat (sign_b (f x)) (exp_b (f x))) (sig_b (f x)))) bf))
; (constraint (= ((_ to_fp 8 8) (concat (concat (sign_b (f x)) (exp_b (f x))) (sig_b (f x)))) (fp.add RNE bf ((_ to_fp 8 8) RNE 1.0))))
(check-synth)
   