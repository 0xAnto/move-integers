module move_int::i32 {

    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;


    const MIN_AS_U32: u32 = 1 << 31;
    const MAX_AS_U32: u32 = 0x7fffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I32 has copy, drop, store {
        bits: u32
    }

    // Creates and returns an I32 representing zero
    public fun zero(): I32 {
        I32 { bits: 0 }
    }

    // Creates an I32 from a u32 without any checks
    public fun from_u32(v: u32): I32 {
        I32 { bits: v }
    }

    // Creates an I32 from a u32, asserting that it's not greater than the maximum positive value
    public fun from(v: u32): I32 {
        assert!(v <= MAX_AS_U32, OVERFLOW);
        I32 { bits: v }
    }

    // Creates a negative I32 from a u32, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u32): I32 {
        assert!(v <= MIN_AS_U32, OVERFLOW);
        if (v == 0) {
            I32 { bits: v }
        } else {
            I32 {
                bits: (u32_neg(v) + 1) | (1 << 31)
            }
        }
    }

    // Performs wrapping addition on two I32 numbers
    public fun wrapping_add(num1: I32, num2: I32): I32 {
        I32 { bits: (((num1.bits as u64) + (num2.bits as u64)) & 0xffffffff as u32) }
    }

    // Performs checked addition on two I32 numbers, asserting on overflow
    public fun add(num1: I32, num2: I32): I32 {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I32 numbers
    public fun wrapping_sub(num1: I32, num2: I32): I32 {
        let sub_num = wrapping_add(I32 { bits: u32_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I32 numbers, asserting on overflow
    public fun sub(num1: I32, num2: I32): I32 {
        let sub_num = wrapping_add(I32 { bits: u32_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    // Performs multiplication on two I32 numbers
    public fun mul(num1: I32, num2: I32): I32 {
        let product = (abs_u32(num1) as u64) * (abs_u32(num2) as u64);
        assert!(product <= (MAX_AS_U32 as u64) + 1, OVERFLOW);
        if (sign(num1) != sign(num2)) {
            return neg_from((product as u32))
        };
        from((product as u32))
    }

    // Performs division on two I32 numbers
    public fun div(num1: I32, num2: I32): I32 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u32(num1) / abs_u32(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    // Returns the absolute value of an I32 number
    public fun abs(v: I32): I32 {
        if (sign(v) == 0) { v }
        else {
            assert!(v.bits > MIN_AS_U32, OVERFLOW);
            I32 { bits: u32_neg(v.bits - 1) }
        }
    }

    // Returns the absolute value of an I32 number as a u32
    public fun abs_u32(v: I32): u32 {
        if (sign(v) == 0) { v.bits }
        else {
            u32_neg(v.bits - 1)
        }
    }

    // Returns the modulo of two I32 numbers
    public fun mod(a: I32, b: I32): I32 {
        assert!(!is_zero(b), DIVISION_BY_ZERO);
        let r = abs_u32(a) % abs_u32(b);
        if (r == 0) return zero();
        // Result takes the sign of the dividend (a)
        if (is_neg(a)) neg_from(r) else from(r)
    }

    // Returns the minimum of two I32 numbers
    public fun min(a: I32, b: I32): I32 {
        if (lt(a, b)) { a }
        else { b }
    }

    // Returns the maximum of two I32 numbers
    public fun max(a: I32, b: I32): I32 {
        if (gt(a, b)) { a }
        else { b }
    }

    // Raises an I32 number to a u32 power
    public fun pow(base: I32, exponent: u32): I32 {
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

    // Converts an I32 to u32
    public fun as_u32(v: I32): u32 {
        v.bits
    }

    // Returns the sign of an I32 number (0 for positive, 1 for negative)
    public fun sign(v: I32): u8 {
        ((v.bits >> 31) as u8)
    }

    // Checks if an I32 number is zero
    public fun is_zero(v: I32): bool {
        v.bits == 0
    }

    // Checks if an I32 number is negative
    public fun is_neg(v: I32): bool {
        sign(v) == 1
    }

    // Compares two I32 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I32, num2: I32): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I32 numbers are equal
    public fun eq(num1: I32, num2: I32): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I32 number is greater than the second
    public fun gt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I32 number is greater than or equal to the second
    public fun gte(num1: I32, num2: I32): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I32 number is less than the second
    public fun lt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I32 number is less than or equal to the second
    public fun lte(num1: I32, num2: I32): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I32 numbers
    public fun or(num1: I32, num2: I32): I32 {
        I32 { bits: (num1.bits | num2.bits) }
    }

    // Performs bitwise AND on two I32 numbers
    public fun and(num1: I32, num2: I32): I32 {
        I32 { bits: (num1.bits & num2.bits) }
    }

    // Helper function to perform bitwise negation on a u32
    fun u32_neg(v: u32): u32 {
        v ^ 0xffffffff
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }
}
