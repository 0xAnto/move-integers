module move_int::i8 {
    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    const MIN_AS_U8: u8 = 1 << 7;
    const MAX_AS_U8: u8 = 0x7f;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I8 has copy, drop, store {
        bits: u8
    }

    // Creates and returns an I8 representing zero
    public fun zero(): I8 {
        I8 { bits: 0 }
    }

    // Creates an I8 from a u8 without any checks
    public fun from_u8(v: u8): I8 {
        I8 { bits: v }
    }

    // Creates an I8 from a u8, asserting that it's not greater than the maximum positive value
    public fun from(v: u8): I8 {
        assert!(v <= MAX_AS_U8, OVERFLOW);
        I8 { bits: v }
    }

    // Creates a negative I8 from a u8, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u8): I8 {
        assert!(v <= MIN_AS_U8, OVERFLOW);
        if (v == 0) {
            I8 { bits: v }
        } else {
            I8 {
                bits: (u8_neg(v) + 1) | (1 << 7)
            }
        }
    }

    // Performs wrapping addition on two I8 numbers
    public fun wrapping_add(num1: I8, num2: I8): I8 {
        I8 { bits: (((num1.bits as u16) + (num2.bits as u16)) & 0xff as u8) }
    }

    // Performs checked addition on two I8 numbers, asserting on overflow
    public fun add(num1: I8, num2: I8): I8 {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                | (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I8 numbers
    public fun wrapping_sub(num1: I8, num2: I8): I8 {
        let sub_num = wrapping_add(I8 { bits: u8_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I8 numbers, asserting on overflow
    public fun sub(num1: I8, num2: I8): I8 {
        let sub_num = wrapping_add(I8 { bits: u8_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    public fun mul(num1: I8, num2: I8): I8 {
        let product = (abs_u8(num1) as u16) * (abs_u8(num2) as u16);
        assert!(product <= (MAX_AS_U8 as u16) + 1, OVERFLOW);

        if (sign(num1) != sign(num2)) {
            neg_from((product as u8))
        } else {
            from((product as u8))
        }
    }

    // Performs division on two I8 numbers
    public fun div(num1: I8, num2: I8): I8 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u8(num1) / abs_u8(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        from(result)
    }

    // Returns the absolute value of an I8 number
    public fun abs(v: I8): I8 {
        if (sign(v) == 0) { v }
        else {
            assert!(v.bits > MIN_AS_U8, OVERFLOW);
            I8 { bits: u8_neg(v.bits - 1) }
        }
    }

    // Returns the absolute value of an I8 number as a u8
    public fun abs_u8(v: I8): u8 {
        if (sign(v) == 0) { v.bits }
        else {
            u8_neg(v.bits - 1)
        }
    }

    // Returns the modulo of two I8 numbers
    public fun mod(a: I8, b: I8): I8 {
        assert!(!is_zero(b), DIVISION_BY_ZERO);
        let r = abs_u8(a) % abs_u8(b);
        if (r == 0) return zero();
        // Result takes the sign of the dividend (a)
        if (is_neg(a)) neg_from(r) else from(r)
    }

    // Returns the minimum of two I8 numbers
    public fun min(a: I8, b: I8): I8 {
        if (lt(a, b)) { a }
        else { b }
    }

    // Returns the maximum of two I8 numbers
    public fun max(a: I8, b: I8): I8 {
        if (gt(a, b)) { a }
        else { b }
    }

    // Raises an I8 number to a u8 power
    public fun pow(base: I8, exponent: u8): I8 {
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

    // Converts an I8 to u8
    public fun as_u8(v: I8): u8 {
        v.bits
    }

    // Returns the sign of an I8 number (0 for positive, 1 for negative)
    public fun sign(v: I8): u8 {
        (v.bits >> 7)
    }

    // Checks if an I8 number is zero
    public fun is_zero(v: I8): bool {
        v.bits == 0
    }

    // Checks if an I8 number is negative
    public fun is_neg(v: I8): bool {
        sign(v) == 1
    }

    // Compares two I8 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I8, num2: I8): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I8 numbers are equal
    public fun eq(num1: I8, num2: I8): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I8 number is greater than the second
    public fun gt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I8 number is greater than or equal to the second
    public fun gte(num1: I8, num2: I8): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I8 number is less than the second
    public fun lt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I8 number is less than or equal to the second
    public fun lte(num1: I8, num2: I8): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I8 numbers
    public fun or(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits | num2.bits) }
    }

    // Performs bitwise AND on two I8 numbers
    public fun and(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits & num2.bits) }
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }
}
