module move_int::i16 {

    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;


    const MIN_AS_U16: u16 = 1 << 15;
    const MAX_AS_U16: u16 = 0x7fff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I16 has copy, drop, store {
        bits: u16
    }

    // Creates and returns an I16 representing zero
    public fun zero(): I16 {
        I16 { bits: 0 }
    }

    // Creates an I16 from a u16 without any checks
    public fun from_u16(v: u16): I16 {
        I16 { bits: v }
    }

    // Creates an I16 from a u16, asserting that it's not greater than the maximum positive value
    public fun from(v: u16): I16 {
        assert!(v <= MAX_AS_U16, OVERFLOW);
        I16 { bits: v }
    }

    // Creates a negative I16 from a u16, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u16): I16 {
        assert!(v <= MIN_AS_U16, OVERFLOW);
        if (v == 0) {
            I16 { bits: v }
        } else {
            I16 {
                bits: (u16_neg(v) + 1) | (1 << 15)
            }
        }
    }

    // Performs wrapping addition on two I16 numbers
    public fun wrapping_add(num1: I16, num2: I16): I16 {
        I16 { bits: (((num1.bits as u32) + (num2.bits as u32)) & 0xffff as u16) }
    }

    // Performs checked addition on two I16 numbers, asserting on overflow
    public fun add(num1: I16, num2: I16): I16 {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I16 numbers
    public fun wrapping_sub(num1: I16, num2: I16): I16 {
        let sub_num = wrapping_add(I16 { bits: u16_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I16 numbers, asserting on overflow
    public fun sub(num1: I16, num2: I16): I16 {
        let sub_num = wrapping_add(I16 { bits: u16_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    // Performs multiplication on two I16 numbers
    public fun mul(num1: I16, num2: I16): I16 {
        let product = (abs_u16(num1) as u32) * (abs_u16(num2) as u32);
        assert!(product <= (MAX_AS_U16 as u32) + 1, OVERFLOW);
        if (sign(num1) != sign(num2)) {
            return neg_from((product as u16))
        };
        from((product as u16))
    }

    // Performs division on two I16 numbers
    public fun div(num1: I16, num2: I16): I16 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u16(num1) / abs_u16(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    // Returns the absolute value of an I16 number
    public fun abs(v: I16): I16 {
        if (sign(v) == 0) { v }
        else {
            assert!(v.bits > MIN_AS_U16, OVERFLOW);
            I16 { bits: u16_neg(v.bits - 1) }
        }
    }

    // Returns the absolute value of an I16 number as a u16
    public fun abs_u16(v: I16): u16 {
        if (sign(v) == 0) { v.bits }
        else {
            u16_neg(v.bits - 1)
        }
    }

    // Returns the modulo of two I16 numbers
    public fun mod(a: I16, b: I16): I16 {
        assert!(!is_zero(b), DIVISION_BY_ZERO);
        let r = abs_u16(a) % abs_u16(b);
        if (r == 0) return zero();
        // Result takes the sign of the dividend (a)
        if (is_neg(a)) neg_from(r) else from(r)
    }

    // Returns the minimum of two I16 numbers
    public fun min(a: I16, b: I16): I16 {
        if (lt(a, b)) { a }
        else { b }
    }

    // Returns the maximum of two I16 numbers
    public fun max(a: I16, b: I16): I16 {
        if (gt(a, b)) { a }
        else { b }
    }

    // Raises an I16 number to a u16 power
    public fun pow(base: I16, exponent: u16): I16 {
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

    // Converts an I16 to u16
    public fun as_u16(v: I16): u16 {
        v.bits
    }

    // Returns the sign of an I16 number (0 for positive, 1 for negative)
    public fun sign(v: I16): u8 {
        ((v.bits >> 15) as u8)
    }

    // Checks if an I16 number is zero
    public fun is_zero(v: I16): bool {
        v.bits == 0
    }

    // Checks if an I16 number is negative
    public fun is_neg(v: I16): bool {
        sign(v) == 1
    }

    // Compares two I16 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I16, num2: I16): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I16 numbers are equal
    public fun eq(num1: I16, num2: I16): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I16 number is greater than the second
    public fun gt(num1: I16, num2: I16): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I16 number is greater than or equal to the second
    public fun gte(num1: I16, num2: I16): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I16 number is less than the second
    public fun lt(num1: I16, num2: I16): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I16 number is less than or equal to the second
    public fun lte(num1: I16, num2: I16): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I16 numbers
    public fun or(num1: I16, num2: I16): I16 {
        I16 { bits: (num1.bits | num2.bits) }
    }

    // Performs bitwise AND on two I16 numbers
    public fun and(num1: I16, num2: I16): I16 {
        I16 { bits: (num1.bits & num2.bits) }
    }

    // Helper function to perform bitwise negation on a u16
    fun u16_neg(v: u16): u16 {
        v ^ 0xffff
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }
}
