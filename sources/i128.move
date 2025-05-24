module move_int::i128 {
    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    const MIN_AS_U128: u128 = 1 << 127;
    const MAX_AS_U128: u128 = 0x7fffffffffffffffffffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I128 has copy, drop, store {
        bits: u128
    }

    public fun zero(): I128 {
        I128 { bits: 0 }
    }

    public fun from(v: u128): I128 {
        assert!(v <= MAX_AS_U128, OVERFLOW);
        I128 { bits: v }
    }

    public fun neg_from(v: u128): I128 {
        assert!(v <= MIN_AS_U128, OVERFLOW);
        if (v == 0) {
            I128 { bits: v }
        } else {
            I128 {
                bits: (u128_neg(v) + 1) | (1 << 127)
            }
        }
    }

    public fun neg(v: I128): I128 {
        if (is_neg(v)) { abs(v) }
        else {
            neg_from(v.bits)
        }
    }

    public fun wrapping_add(num1: I128, num2: I128): I128 {
        I128 { bits: (((num1.bits as u256) + (num2.bits as u256)) & 0xffffffffffffffffffffffffffffffff as u128) }
    }

    public fun add(num1: I128, num2: I128): I128 {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    public fun overflowing_add(num1: I128, num2: I128): (I128, bool) {
        let sum = wrapping_add(num1, num2);
        let overflow =
            (sign(num1) & sign(num2) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        (sum, overflow != 0)
    }

    public fun wrapping_sub(num1: I128, num2: I128): I128 {
        let sub_num = wrapping_add(I128 { bits: u128_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    public fun sub(num1: I128, num2: I128): I128 {
        let sub_num = wrapping_add(I128 { bits: u128_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    public fun overflowing_sub(num1: I128, num2: I128): (I128, bool) {
        let sub_num = wrapping_add(I128 { bits: u128_neg(num2.bits) }, from(1));
        let sum = wrapping_add(num1, sub_num);
        let overflow =
            (sign(num1) & sign(sub_num) & u8_neg(sign(sum)))
                + (u8_neg(sign(num1)) & u8_neg(sign(sub_num)) & sign(sum));
        (sum, overflow != 0)
    }

    public fun mul(num1: I128, num2: I128): I128 {
        let product = (abs_u128(num1) as u256) * (abs_u128(num2) as u256);
        assert!(
            product <= (MAX_AS_U128 as u256) + 1,
            OVERFLOW
        );
        if (sign(num1) != sign(num2)) {
            return neg_from((product as u128))
        };
        return from((product as u128))
    }

    public fun div(num1: I128, num2: I128): I128 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u128(num1) / abs_u128(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    public fun abs(v: I128): I128 {
        if (sign(v) == 0) { v }
        else {
            assert!(v.bits > MIN_AS_U128, OVERFLOW);
            I128 { bits: u128_neg(v.bits - 1) }
        }
    }

    public fun abs_u128(v: I128): u128 {
        if (sign(v) == 0) { v.bits }
        else {
            u128_neg(v.bits - 1)
        }
    }

    // Returns the modulo of two I128 numbers
    public fun mod(a: I128, b: I128): I128 {
        assert!(!is_zero(b), DIVISION_BY_ZERO);
        let r = abs_u128(a) % abs_u128(b);
        if (r == 0) return zero();
        // Result takes the sign of the dividend (a)
        if (is_neg(a)) neg_from(r) else from(r)
    }

    public fun min(a: I128, b: I128): I128 {
        if (lt(a, b)) { a }
        else { b }
    }

    public fun max(a: I128, b: I128): I128 {
        if (gt(a, b)) { a }
        else { b }
    }

    public fun pow(base: I128, exponent: u64): I128 {
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

    public fun is_zero(v: I128): bool {
        v.bits == 0
    }

    public fun as_u128(v: I128): u128 {
        v.bits
    }

    public fun sign(v: I128): u8 {
        ((v.bits >> 127) as u8)
    }

    public fun is_neg(v: I128): bool {
        sign(v) == 1
    }

    public fun cmp(num1: I128, num2: I128): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    public fun eq(num1: I128, num2: I128): bool {
        num1.bits == num2.bits
    }

    public fun gt(num1: I128, num2: I128): bool {
        cmp(num1, num2) == GT
    }

    public fun gte(num1: I128, num2: I128): bool {
        cmp(num1, num2) >= EQ
    }

    public fun lt(num1: I128, num2: I128): bool {
        cmp(num1, num2) == LT
    }

    public fun lte(num1: I128, num2: I128): bool {
        cmp(num1, num2) <= EQ
    }

    public fun or(num1: I128, num2: I128): I128 {
        I128 { bits: (num1.bits | num2.bits) }
    }

    public fun and(num1: I128, num2: I128): I128 {
        I128 { bits: (num1.bits & num2.bits) }
    }

    fun u128_neg(v: u128): u128 {
        v ^ 0xffffffffffffffffffffffffffffffff
    }

    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }
}
