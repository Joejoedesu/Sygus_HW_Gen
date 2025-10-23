(set-logic ALL)
(set-option :produce-models true)

(declare-fun x () (_ FloatingPoint 8 24))
(declare-fun r () Real)

(assert (not (=> (and (= x ((_ to_fp 8 24) RNE r)) (<= r 1.0) (>= r -1.0))
                (fp.lt (fp.abs (fp.sub RNE (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) x))
                 ((_ to_fp 8 24) RNE (+ r 2.0)))) ((_ to_fp 8 24) RNE 0.001)))))

(check-sat)
(get-model)