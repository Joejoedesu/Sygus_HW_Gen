import numpy as np

def int2binary(total_bits: int, value: int) -> str:
    """Convert signed int to binary string (two's complement)."""
    mask = (1 << total_bits) - 1
    return format(value & mask, f'0{total_bits}b')

def binary2int(bin_str: str, signed: bool) -> int:
    """Convert binary string (two's complement if signed) to signed int."""
    total_bits = len(bin_str)
    value = int(bin_str, 2)
    if signed and bin_str[0] == '1':  # negative number in two's complement
        value -= (1 << total_bits)
    return value

def float2binary(mantissa_bits: int, exponent_bits: int, value: float) -> str:
    """Convert float to binary string representation."""
    if value == 0.0:
        return '0' * (1 + mantissa_bits + exponent_bits)
    
    sign_bit = '0' if value >= 0 else '1'
    value = abs(value)
    
    exponent = 0
    while value >= 2.0:
        value /= 2.0
        exponent += 1
    while value < 1.0:
        value *= 2.0
        exponent -= 1
    
    bias = (1 << (exponent_bits - 1)) - 1
    exponent += bias
    if exponent <= 0 or exponent >= (1 << exponent_bits):
        raise ValueError("Exponent out of range for given exponent bits.")
    
    mantissa = ''
    value -= 1.0  # remove leading 1
    for _ in range(mantissa_bits):
        value *= 2.0
        if value >= 1.0:
            mantissa += '1'
            value -= 1.0
        else:
            mantissa += '0'
    
    exponent_bin = format(exponent, f'0{exponent_bits}b')
    return sign_bit + exponent_bin + mantissa

def binary2float(bin_str: str, mantissa_bits: int, exponent_bits: int) -> float:
    """Convert binary string representation to float."""
    total_bits = 1 + mantissa_bits + exponent_bits
    if len(bin_str) != total_bits:
        raise ValueError("Binary string length does not match specified mantissa and exponent bits.")
    
    sign_bit = bin_str[0]
    exponent_bin = bin_str[1:1 + exponent_bits]
    mantissa_bin = bin_str[1 + exponent_bits:]
    
    sign = -1.0 if sign_bit == '1' else 1.0
    exponent = int(exponent_bin, 2)
    bias = (1 << (exponent_bits - 1)) - 1
    exponent -= bias
    
    mantissa = 1.0  # implicit leading 1
    for i, bit in enumerate(mantissa_bin):
        if bit == '1':
            mantissa += 2 ** (-(i + 1))
    
    return sign * mantissa * (2 ** exponent)

def binary2hex(bin_str: str) -> str:
    """Convert binary string to hexadecimal string."""
    hex_length = (len(bin_str) + 3) // 4  # Each hex digit represents 4 bits
    hex_value = hex(int(bin_str, 2))[2:]  # Convert binary to int, then to hex and strip '0x'
    return hex_value.zfill(hex_length)  # Pad with zeros to ensure correct length

def hex2binary(hex_str: str, total_bits: int) -> str:
    """Convert hexadecimal string to binary string."""
    bin_length = total_bits
    bin_value = format(int(hex_str, 16), f'0{bin_length}b')  # Convert hex to int, then to binary
    return bin_value[-total_bits:]  # Ensure the binary string is of the correct length

# SMT op instantiation
def bv(val, size):
    MASK = (1 << size) - 1
    return int2binary(size, val & MASK)

def bvadd(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    return bv(l + r, size)

def bvshl(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    return bv(l << r, size)

def bvlshr(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    return bv(l >> r, size)

def bvslt(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    if l >= (1 << (size - 1)):
        l -= (1 << size)
    if r >= (1 << (size - 1)):
        r -= (1 << size)
    return l < r

def bvand(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    return bv(l & r, size)

def bvor(l, r):
    size = len(l)
    assert len(l) == len(r)
    l = binary2int(l, signed=False)
    r = binary2int(r, signed=False)
    return bv(l | r, size)

def bvneg(l):
    size = len(l)
    l = binary2int(l, signed=False)
    return bv(-l, size)

def ite(cond, true_val, false_val):
    return true_val if cond else false_val

class Q_Types:
    def __init__(self, signed: bool, mantissa_bits: int, exponent_bits: int, value=None):
        self.signed = signed
        self.mantissa_bits = mantissa_bits
        self.exponent_bits = exponent_bits
        self.total_bits = 1 + mantissa_bits + exponent_bits if signed else mantissa_bits + exponent_bits
        self.value_range = self._compute_value_range()
        
    def _compute_value_range(self):
        if self.exponent_bits > 0:
            # Floating point range computation
            bias = (1 << (self.exponent_bits - 1)) - 1
            max_exponent = (1 << self.exponent_bits) - 2 - bias
            min_exponent = 1 - bias
            # with implicit leading 1 and sign bit
            max_mantissa = 2 - (1 / (1 << self.mantissa_bits))
            min_mantissa = 1.0
            max_val = max_mantissa * (2 ** max_exponent)
            min_val = min_mantissa * (2 ** min_exponent)
            if self.signed:
                return (-max_val, max_val)
            else:
                return (0.0, max_val)
        else:
            if self.signed:
                min_val = - (1 << (self.total_bits - 1))
                max_val = (1 << (self.total_bits - 1)) - 1
            else:
                min_val = 0
                max_val = (1 << self.total_bits) - 1
            return (min_val, max_val)

    # want to return the binary string representation and the error
    def encode_value(self, value, mode='nearest'):
        if type(value) is not float:
            value = float(value)
        
        if value < self.value_range[0] or value > self.value_range[1]:
            raise ValueError("Value out of range for this Q_Type configuration.")
        
        if self.exponent_bits > 0:
            # Floating point encoding
            if mode == 'nearest':
                # round to nearest representable float
                binary_str = float2binary(self.mantissa_bits, self.exponent_bits, value)
                stored_value = binary2float(binary_str, self.mantissa_bits, self.exponent_bits)
                error = value - stored_value
                return binary_str, stored_value, error
            elif mode == 'floor':
                # find the largest representable float <= value
                step = 2 ** (-(self.mantissa_bits))
                floored_value = np.floor(value / step) * step
                binary_str = float2binary(self.mantissa_bits, self.exponent_bits, floored_value)
                stored_value = binary2float(binary_str, self.mantissa_bits, self.exponent_bits)
                error = value - stored_value
                return binary_str, stored_value, error
            elif mode == 'ceil':
                # find the smallest representable float >= value
                step = 2 ** (-(self.mantissa_bits))
                ceiled_value = np.ceil(value / step) * step
                binary_str = float2binary(self.mantissa_bits, self.exponent_bits, ceiled_value)
                stored_value = binary2float(binary_str, self.mantissa_bits, self.exponent_bits)
                error = value - stored_value
                return binary_str, stored_value, error

        else:
            if mode == 'nearest':
                val = int(round(value))
            elif mode == 'floor':
                val = int(np.floor(value))
            elif mode == 'ceil':
                val = int(np.ceil(value))
            binary_str = int2binary(self.total_bits, val)
            error = value - val
            return binary_str, val, error
        
    def decode_value(self, binary_str: str):
        if len(binary_str) != self.total_bits:
            raise ValueError("Binary string length does not match Q_Type configuration.")
        
        if self.exponent_bits > 0:
            # Floating point decoding
            value = binary2float(binary_str, self.mantissa_bits, self.exponent_bits)
            return value
        else:
            # Integer decoding
            value = binary2int(binary_str, self.signed)
            return value
        
class Q_inst:
    def __init__(self, q_type: Q_Types, value):
        self.q_type = q_type
        self.binary_str, self.stored_value, self.error = q_type.encode_value(value)