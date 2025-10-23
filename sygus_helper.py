import sexpdata
import numpy as np
import matplotlib.pyplot as plt
import type_convert as tc

def sygus_eq(l, r):
    return f"(= {l} {r})"

def sygus_leq(l, r, thoery='BV'):
    if thoery == 'BV':
        return f"(bvsle {l} {r})"
    elif thoery == 'FP':
        return f"(fp.leq {l} {r})"
    elif thoery == 'NRA':
        return f"(<= {l} {r})"
    else:
        raise ValueError(f"Unsupported theory: {thoery}")
    
def sygus_lt(l, r, thoery='BV'):
    if thoery == 'BV':
        return f"(bvslt {l} {r})"
    elif thoery == 'FP':
        return f"(fp.lt {l} {r})"
    elif thoery == 'NRA':
        return f"(< {l} {r})"
    else:
        raise ValueError(f"Unsupported theory: {thoery}")

def sygus_constraint_wrap(expr: str):
    return f"(constraint {expr})"

def sygus_example_constraint_wrap_bounded(input, target, bound, rev=False): # currently only support fp
    if rev:
        return f"(fp.lt (fp.sub RNE (f ((_ to_fp 8 24) RNE {input})) ((_ to_fp 8 24) RNE {target})) ((_ to_fp 8 24) RNE {bound}))"
    else:
        return f"(fp.lt (fp.neg ((_ to_fp 8 24) RNE {bound})) (fp.sub RNE (f ((_ to_fp 8 24) RNE {input})) ((_ to_fp 8 24) RNE {target})))"

def sygus_binary_str(seq: str):
    return f"#b{seq}"

def sygus_hex_str(seq: str):
    return f"#x{seq}"

def sygus_format_expr(expr: str, lines: list, level: int =0):
    if isinstance(expr, sexpdata.Symbol):
        if "#" in expr.value():
            l = '  ' * level + expr.value() + '   ' + tc.binary2int(expr.value()[2:], signed=True).__str__()
            print(l)
            lines.append(l)
        else:
            l = '  ' * level + expr.value()
            print(l)
            lines.append(l)
    elif isinstance(expr, (int, float)):
        l = '  ' * level + str(expr)
        print(l)
        lines.append(l)
    elif isinstance(expr, list):
        op = expr[0]
        composed_op = isinstance(op, list) and isinstance(op[0], sexpdata.Symbol) and op[0].value() == '_'
        if isinstance(op, sexpdata.Symbol) or composed_op:
            if composed_op:
                op_value = ' '.join([o.value() if isinstance(o, sexpdata.Symbol) else str(o) for o in op[1:]])
            else:
                op_value = op.value()
            if op_value == 'let':
                let_val = expr[1][0]
                let_name = let_val[0].value()
                let_expr = let_val[1]
                l = '  ' * level + f"let {let_name} = "
                print(l)
                lines.append(l)
                sygus_format_expr(let_expr, lines, level)
                sygus_format_expr(expr[2], lines, level)
            elif op_value == 'ite':
                l = '  ' * level + "if "
                print(l)
                lines.append(l)
                sygus_format_expr(expr[1], lines, level + 1)
                l = '  ' * level + "then "
                print(l)
                lines.append(l)
                sygus_format_expr(expr[2], lines, level + 1)
                l = '  ' * level + "else "
                print(l)
                lines.append(l)
                sygus_format_expr(expr[3], lines, level + 1)
            else:
                l = '  ' * level + f"{op_value}"
                print(l)
                lines.append(l)
                for sub_expr in expr[1:]:
                    sygus_format_expr(sub_expr, lines, level + 1)
        else:
            raise ValueError(f"Invalid operation: {op}")
    else:
        raise ValueError(f"Invalid expression type: {expr}")

def sygus_eval_expr(expr, env_l: dict): # it operates in the space of string
    if isinstance(expr, sexpdata.Symbol):
        v = expr.value()
        if v.startswith('#b'):
            return v[2:]
        elif v.startswith('#x'):
            int_value = int(v[2:], 16)
            total_bits = len(v[2:]) * 4
            return tc.int2binary(total_bits, int_value)
        elif v in env_l:
            return env_l[v]
        else:
            raise ValueError(f"Unknown symbol: {v}")
    elif isinstance(expr, (int, float)):
        return expr
    elif isinstance(expr, list):
        op = expr[0]
        if isinstance(op, sexpdata.Symbol):
            op_value = op.value()
            if op_value == 'let':
                let_val = expr[1][0]
                assert len(expr[1]) == 1
                let_name = let_val[0].value()
                assert let_name not in env_l
                let_expr = let_val[1]
                let_evaluated = sygus_eval_expr(let_expr, env_l)
                env_l[let_name] = let_evaluated
                # print(f"Let binding: {let_name} = {let_evaluated}")
                return sygus_eval_expr(expr[2], env_l)
            # BV operations
            elif op_value == 'bvadd':
                return tc.bvadd(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvshl':
                return tc.bvshl(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvlshr':
                return tc.bvlshr(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvslt':
                return tc.bvslt(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvand':
                return tc.bvand(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvor':
                return tc.bvor(sygus_eval_expr(expr[1], env_l), sygus_eval_expr(expr[2], env_l))
            elif op_value == 'bvneg':
                return tc.bvneg(sygus_eval_expr(expr[1], env_l))
            # FP operations
            elif op_value == 'fp.add':
                return sygus_eval_expr(expr[2], env_l) + sygus_eval_expr(expr[3], env_l)
            elif op_value == 'fp.sub':
                return sygus_eval_expr(expr[2], env_l) - sygus_eval_expr(expr[3], env_l)
            elif op_value == 'fp.abs':
                return abs(sygus_eval_expr(expr[1], env_l))
            elif op_value == 'fp.mul':
                return sygus_eval_expr(expr[2], env_l) * sygus_eval_expr(expr[3], env_l)
            elif op_value == 'fp.leq':
                return sygus_eval_expr(expr[1], env_l) <= sygus_eval_expr(expr[2], env_l)
            elif op_value == 'fp.div':
                return sygus_eval_expr(expr[2], env_l) / sygus_eval_expr(expr[3], env_l)
            elif op_value == 'ite':
                return tc.ite(sygus_eval_expr(expr[1], env_l),
                              sygus_eval_expr(expr[2], env_l),
                              sygus_eval_expr(expr[3], env_l))
            elif op_value == '=':
                return sygus_eval_expr(expr[1], env_l) == sygus_eval_expr(expr[2], env_l)
            else:
                raise ValueError(f"Unsupported operation: {op_value}")
        elif isinstance(op, list):
            assert isinstance(op[0], sexpdata.Symbol) and op[0].value() == '_'
            t_op = op[1].value()
            if t_op == 'to_fp':
                return sygus_eval_expr(expr[-1], env_l)
        else:
            raise ValueError(f"Invalid operation: {op}")

def sygus_func_extraction(sygus_output: str):
    # generate an executable function from sygus output
    # sygus output example:
    parsed = sexpdata.loads(sygus_output)
    inputs = parsed[2]
    output_type = parsed[3]
    func_gen = parsed[4]
    # print(inputs)
    # print(output_type)
    # print(func_gen)
    def f(x: str) -> str:
        env = {'x': x}
        result = sygus_eval_expr(func_gen, env)
        return result
    return f

def sygus_func_plot(sygus_output: str, bv=True):
    f = sygus_func_extraction(sygus_output)
    # plot the range of -20, 20 with step 0.1
    v = []
    for i in np.arange(-20, 20, 0.1):
        if bv:
            bin_input = tc.int2binary(8, int(i))
            out_bin = f(bin_input)
            out = tc.binary2int(out_bin, signed=True)
        else:
            out = f(i)

        # print(f"Input: {i}, Output: {out}")
        v.append(out)
    plt.plot(np.arange(-20, 20, 0.1), v)
    plt.xlabel('Input')
    plt.ylabel('Output')
    plt.title('Sygus Function Plot')
    plt.grid()
    plt.show()


def __main__():
    # s = "(define-fun f ((x (_ BitVec 8))) (_ BitVec 8) (ite (bvslt #b00000001 x) (ite (bvslt x (bvshl #b00000001 #b00000010)) (bvshl (bvadd x (bvshl #b00000010 x)) #b00000001) (bvshl (bvadd #b00000010 (bvshl #b00000010 #b00000010)) #b00000010)) (bvlshr #b00000001 (bvadd #b00000010 (bvadd #b00000010 x)))))"
    # sygus_func_extraction(s)

    # s = "(define-fun f ((x (_ BitVec 8))) (_ BitVec 8) (let ((_let_1 (bvshl x x))) (let ((_let_2 (bvshl #b00000001 #b00000010))) (let ((_let_3 (bvadd #b00000001 #b00000010))) (let ((_let_4 (bvadd #b00000010 x))) (let ((_let_5 (bvadd #b00000001 x))) (ite (bvslt #b00000001 (bvadd #b00000010 _let_1)) (ite (bvslt #b00000001 (ite (bvslt #b00000010 x) (bvlshr x #b00000001) #b00000010)) (ite (bvslt #b00000001 (ite (= #b00000010 x) #b00000001 #b00000010)) (ite (= #b00000000 (bvlshr #b00000010 x)) (ite (= #b00000000 (bvlshr #b00000001 _let_5)) (ite (= #b00000000 (bvlshr #b00000001 _let_4)) (ite (bvslt x _let_5) (bvshl #b00000001 (bvadd #b00000010 _let_4)) (bvshl (bvadd #b00000010 (bvshl #b00000010 #b00000010)) #b00000010)) (bvand x (bvadd #b00000010 _let_2))) (bvlshr x (bvshl _let_4 #b00000010))) (bvadd #b00000001 (bvadd #b00000010 (bvshl _let_3 _let_3)))) (bvadd #b00000001 (bvor #b00000010 (bvadd x (bvshl #b00000010 _let_2))))) (bvadd (bvshl #b00000001 x) (bvlshr (bvneg #b00000001) x))) (bvlshr _let_1 #b00000010))))))))"
    # s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (let ((_let_1 ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven _let_1 (fp.add roundNearestTiesToEven _let_1 x))))"
    # s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (fp.add roundNearestTiesToEven (fp.mul roundNearestTiesToEven (fp.add roundNearestTiesToEven x (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)))"
    # s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (ite (fp.leq x ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) (fp.mul roundNearestTiesToEven x (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven x ((_ to_fp 8 24) roundNearestTiesToEven 1.0))))"
    # 0.5 error
    # s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (fp.mul roundNearestTiesToEven (fp.add roundNearestTiesToEven (fp.mul roundNearestTiesToEven x (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))))) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)))))"
    # 0.2 error
    s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (fp.mul roundNearestTiesToEven (fp.add roundNearestTiesToEven (fp.mul roundNearestTiesToEven x (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))))) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)))))"
    # 0.2 slower
    # s = "(define-fun f ((x (_ FloatingPoint 8 24))) (_ FloatingPoint 8 24) (fp.add roundNearestTiesToEven (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.mul roundNearestTiesToEven x (fp.div roundNearestTiesToEven (fp.div roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) (fp.add roundNearestTiesToEven (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))) (fp.add roundNearestTiesToEven (fp.add roundNearestTiesToEven ((_ to_fp 8 24) roundNearestTiesToEven 1.0) ((_ to_fp 8 24) roundNearestTiesToEven 1.0)) ((_ to_fp 8 24) roundNearestTiesToEven 1.0))))))"

    sygus_func_plot(s, bv=False)
    parsed = sexpdata.loads(s)
    inputs = parsed[2]
    output_type = parsed[3]
    func_gen = parsed[4]
    lines = []
    sygus_format_expr(func_gen, lines)
    with open("sygus_formatted.txt", "w") as f:
        for line in lines:
            f.write(line + "\n")

if __name__ == "__main__":
    __main__()