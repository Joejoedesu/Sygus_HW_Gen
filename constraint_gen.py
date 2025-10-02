import numpy as np
import type_convert as tc
import sygus_helper as sh

function_dict = {
    'sin': np.sin,
    'cos': np.cos,
    'relu': lambda x: np.maximum(0, x),
    'exp': np.exp,
    'n_exp': lambda x: np.exp(-x),
    'sigmoid': lambda x: 40 / (1 + np.exp(-x))
}

def binary_search(func, target, low, high, tol=1e-5, max_iter=100):
    for _ in range(max_iter):
        mid = (low + high) / 2
        value = func(mid)
        if abs(value - target) < tol:
            return mid
        elif value < target:
            low = mid
        else:
            high = mid
    return (low + high) / 2

def uniform_linear(func, exam_range, num_seg):
    start_p = exam_range[0]
    end_p = exam_range[1]
    coef = []
    step_size = (end_p - start_p) / num_seg
    for i in range(num_seg):
        s = start_p + i * step_size
        e = start_p + (i + 1) * step_size
        c = func(e) - func(s)
        m = c / (e - s)
        b = func(s) - m * s 
        coef.append((m, b))
    return coef

def compute_second_derivative(func, x, h=1e-5):
    return (func(x + h) - 2 * func(x) + func(x - h)) / (h * h)

def derivative_based_sample(func, exam_range, num_sample, input_type, output_type):
    # sample a set of points, and use the second order derivative to determine the points
    start_p = exam_range[0]
    end_p = exam_range[1]
    coef = []
    expanded_num_seg = num_sample * 20
    step_size = (end_p - start_p) / expanded_num_seg
    examine_points = []
    for i in range(expanded_num_seg):
        p = start_p + i * step_size
        der = compute_second_derivative(func, p)
        examine_points.append([p, abs(der), func(p)])
    # sort by derivative value
    examine_points = sorted(examine_points, key=lambda x: x[1], reverse=True)
    # select the top num_sample points
    selected_points = sorted([[p[0], p[2]] for p in examine_points[:num_sample-1]])
    # add the two endpoints
    selected_points = [[start_p, func(start_p)]] + selected_points + [[end_p, func(end_p)]]
    samples_encoded = []
    for p in selected_points:
        print(f"Selected Input: {p[0]}, Output: {p[1]}")
        in_bin, _, _ = input_type.encode_value(p[0])
        out_bin, _, _ = output_type.encode_value(p[1])
        samples_encoded.append([in_bin, out_bin])
    return samples_encoded

def uniform_sample(func, exam_range, num_sample, input_type, output_type):
    samples = np.linspace(exam_range[0], exam_range[1], num_sample)
    # use the encoded value as input to get output
    input_encoded = []
    for s in samples:
        in_bin, in_val, _ = input_type.encode_value(s)
        input_encoded.append([in_bin, in_val])
    values = [func(s[1]) for s in input_encoded]
    samples_encoded = []
    assert len(values) == len(samples)
    for i in range(len(samples)):
        print(f"Input: {input_encoded[i][1]}, Output: {values[i]}")
        out_bin, _, _ = output_type.encode_value(values[i])
        samples_encoded.append([input_encoded[i][0], out_bin])
    return samples_encoded

def search_valid_input_range(func, input_type, output_type):
    input_range = input_type.value_range
    output_range = output_type.value_range
    # binary search, to see if the min output_range can be achieved
    # TODO: maybe return binary encoding for bf16
    # always assume monotonic increasing function, or bounded function
    min_input = binary_search(func, output_range[0], input_range[0], input_range[1])
    min_input_enc = input_type.encode_value(min_input, mode='ceil')[1]
    max_input = binary_search(func, output_range[1], input_range[0], input_range[1])
    max_input_enc = input_type.encode_value(max_input, mode='floor')[1]
    return (max(input_range[0], min_input_enc), min(input_range[1], max_input_enc))
    
def constraint_gen(func_name, input_type, output_type, gen_strategy):
    func = function_dict[func_name]
    valid_input_range = search_valid_input_range(func, input_type, output_type)
    print(f"Valid input range for {func_name}: {valid_input_range}")
    print(f"Encoded samples for {func_name}:")

    if gen_strategy == 'uniform_linear':
        samples_encoded = uniform_sample(func, valid_input_range, 40, input_type, output_type)
        for sample in samples_encoded:
            t = sh.sygus_eq(f"(f {sh.sygus_binary_str(sample[0])})", sh.sygus_binary_str(sample[1]))
            print(sh.sygus_constraint_wrap(t))
    elif gen_strategy == 'derivative_based':
        samples_encoded = derivative_based_sample(func, valid_input_range, 10, input_type, output_type)
        for sample in samples_encoded:
            t = sh.sygus_eq(f"(f {sh.sygus_binary_str(sample[0])})", sh.sygus_binary_str(sample[1]))
            print(sh.sygus_constraint_wrap(t))

def __main__():
    input_type = tc.Q_Types(signed=True, mantissa_bits=7, exponent_bits=0)
    output_type = tc.Q_Types(signed=True, mantissa_bits=7, exponent_bits=0)
    # constraint_gen('sin', input_type, output_type, 'uniform_linear')
    # constraint_gen('relu', input_type, output_type, 'uniform_linear')
    # constraint_gen('exp', input_type, output_type, 'uniform_linear')
    # constraint_gen('sigmoid', input_type, output_type, 'uniform_linear')
    constraint_gen('sigmoid', input_type, output_type, 'derivative_based')

if __name__ == "__main__":
    __main__()