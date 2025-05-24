module move_int::i64 {

    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    const MIN_AS_U64: u64 = 1 << 63;
    const MAX_AS_U64: u64 = 0x7fffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I64 has copy, drop, store {
        bits: u64
    }

    // Creates and returns an I64 representing zero
    public fun zero(): I64 {
        I64 { bits: 0 }
    }

    // Creates an I64 from a u64 without any checks
    public fun from_u64(v: u64): I64 {
        I64 { bits: v }
    }

    // Creates an I64 from a u64, asserting that it's not greater than the maximum positive value
    public fun from(v: u64): I64 {
        assert!(v <= MAX_AS_U64, OVERFLOW);
        I64 { bits: v }
    }

    // Creates a negative I64 from a u64, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u64): I64 {
        assert!(v <= MIN_AS_U64, OVERFLOW);
        if (v == 0) {
            I64 { bits: v }
        } else {
            I64 {
                bits: (u64_neg(v) + 1) | (1 << 63)
            }
        }
    }

    // Performs wrapping addition on two I64 numbers
    public fun wrapping_add(num1: I64, num2: I64): I64 {
        I64 { bits: (((num1.bits as u128) + (num2.bits as u128)) & 0xffffffffffffffff as u64) }
    }

    // Performs checked addition on two I64 numbers, asserting on overflow
    public fun add(num1: I64, num2: I64): I64 {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I64 numbers
    public fun wrapping_sub(num1: I64, num2: I64): I64 {
        let sub_num = wrapping_add(I64 { bits: u64_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I64 numbers, asserting on overflow
    public fun sub(num1: I64, num2: I64): I64 {
        let sub_num = wrapping_add(I64 { bits: u64_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    // Performs multiplication on two I64 numbers
    public fun mul(num1: I64, num2: I64): I64 {
        let product = (abs_u64(num1) as u128) * (abs_u64(num2) as u128);
        assert!(product <= (MAX_AS_U64 as u128) + 1, OVERFLOW);
        if (sign(num1) != sign(num2)) {
            return neg_from((product as u64))
        };
        return from((product as u64))
    }

    // Performs division on two I64 numbers
    public fun div(num1: I64, num2: I64): I64 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u64(num1) / abs_u64(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    // Returns the absolute value of an I64 number
    public fun abs(v: I64): I64 {
        if (sign(v) == 0) { v }
        else {
            assert!(v.bits > MIN_AS_U64, OVERFLOW);
            I64 { bits: u64_neg(v.bits - 1) }
        }
    }

    // Returns the absolute value of an I64 number as a u64
    public fun abs_u64(v: I64): u64 {
        if (sign(v) == 0) { v.bits }
        else {
            u64_neg(v.bits - 1)
        }
    }

    // Returns the modulo of two I64 numbers
    // The result has the same sign as the dividend (`a`), following the truncated division convention.
    // Equivalent to: `a - (a / b) * b`, where division truncates toward zero.
    // Aborts if the divisor (`b`) is zero.
    public fun mod(a: I64, b: I64): I64 {
        assert!(!is_zero(b), DIVISION_BY_ZERO);
        let r = abs_u64(a) % abs_u64(b);
        if (r == 0) return zero();
        // Result takes the sign of the dividend (a)
        if (is_neg(a)) neg_from(r) else from(r)
    }

    // Returns the minimum of two I64 numbers
    public fun min(a: I64, b: I64): I64 {
        if (lt(a, b)) { a }
        else { b }
    }

    // Returns the maximum of two I64 numbers
    public fun max(a: I64, b: I64): I64 {
        if (gt(a, b)) { a }
        else { b }
    }

    // Raises an I64 number to a u64 power
    public fun pow(base: I64, exponent: u64): I64 {
        if (exponent == 0) {
            return from(1)
        };
        let result = from(1);
        while (exponent > 0) {
            if (exponent & 1 == 1) {
                result = mul(result, base);
            };
            base = mul(base, base);
            exponent >>= 1;
        };
        result
    }

    // Converts an I64 to u64
    public fun as_u64(v: I64): u64 {
        v.bits
    }

    // Returns the sign of an I64 number (0 for positive, 1 for negative)
    public fun sign(v: I64): u8 {
        ((v.bits >> 63) as u8)
    }

    // Checks if an I64 number is zero
    public fun is_zero(v: I64): bool {
        v.bits == 0
    }

    // Checks if an I64 number is negative
    public fun is_neg(v: I64): bool {
        sign(v) == 1
    }

    // Compares two I64 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I64, num2: I64): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I64 numbers are equal
    public fun eq(num1: I64, num2: I64): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I64 number is greater than the second
    public fun gt(num1: I64, num2: I64): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I64 number is greater than or equal to the second
    public fun gte(num1: I64, num2: I64): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I64 number is less than the second
    public fun lt(num1: I64, num2: I64): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I64 number is less than or equal to the second
    public fun lte(num1: I64, num2: I64): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I64 numbers
    public fun or(num1: I64, num2: I64): I64 {
        I64 { bits: (num1.bits | num2.bits) }
    }

    // Performs bitwise AND on two I64 numbers
    public fun and(num1: I64, num2: I64): I64 {
        I64 { bits: (num1.bits & num2.bits) }
    }

    // Helper function to perform bitwise negation on a u64
    fun u64_neg(v: u64): u64 {
        v ^ 0xffffffffffffffff
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }
}
