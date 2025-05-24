#[test_only]
module move_int::i32_test {
    use move_int::i32::{as_u32, from, from_u32, neg_from, abs, add, sub, mul,
        div, wrapping_add, wrapping_sub, pow, sign, cmp, min, max,
        eq, gt, lt, gte, lte, and, or, is_zero, is_neg, zero, mod, Self
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const MIN_AS_U32: u32 = 1 << 31;
    const MAX_AS_U32: u32 = 0x7fffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u32(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u32(from(0)) == 0, 3);
        assert!(as_u32(from(10)) == 10, 4);
        assert!(as_u32(from(MAX_AS_U32)) == MAX_AS_U32, 5);

        // Test from_u32()
        assert!(as_u32(from_u32(42)) == 42, 6);
        assert!(as_u32(from_u32(MIN_AS_U32)) == MIN_AS_U32, 7);
        assert!(sign(from_u32(MIN_AS_U32)) == 1, 8);

        // Test neg_from()
        assert!(as_u32(neg_from(0)) == 0, 9);
        assert!(as_u32(neg_from(1)) == 0xffffffff, 10);
        assert!(as_u32(neg_from(MIN_AS_U32)) == MIN_AS_U32, 11);
        assert!(as_u32(neg_from(0x7fffffff)) == 0x80000001, 12);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_from_overflow() {
        from(MIN_AS_U32);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_neg_from_overflow() {
        neg_from(0x80000001);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping_add
        assert!(
            as_u32(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u32(wrapping_add(from(MAX_AS_U32), from(1))) == MIN_AS_U32,
            1
        );
        assert!(
            as_u32(
                wrapping_add(from(MAX_AS_U32 - 1), from(1))
            ) == MAX_AS_U32,
            2
        );

        // Test wrapping_sub
        assert!(
            as_u32(wrapping_sub(from(20), from(10))) == 10,
            3
        );
        assert!(
            as_u32(wrapping_sub(from(0), from(1))) == as_u32(neg_from(1)),
            4
        );
        assert!(
            as_u32(wrapping_sub(from(1), neg_from(1))) == as_u32(from(2)),
            5
        );

        // Test add/sub without overflow
        assert!(as_u32(add(from(15), from(25))) == 40, 6);
        assert!(as_u32(sub(from(25), from(15))) == 10, 7);
        assert!(as_u32(add(neg_from(1), from(1))) == 0, 8);

        // Test multiplication
        assert!(as_u32(mul(from(10), from(10))) == 100, 9);
        assert!(
            as_u32(mul(neg_from(10), from(10))) == as_u32(neg_from(100)),
            10
        );
        assert!(
            as_u32(mul(from(MIN_AS_U32 / 2), neg_from(2)))
                == as_u32(neg_from(MIN_AS_U32)),
            11
        );

        // Test division
        assert!(as_u32(div(from(100), from(10))) == 10, 12);
        assert!(
            as_u32(div(from(10), neg_from(1))) == as_u32(neg_from(10)),
            13
        );
        assert!(
            as_u32(div(neg_from(10), neg_from(1))) == 10,
            14
        );
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_add_overflow() {
        add(from(MAX_AS_U32), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U32), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U32), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U32), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_mul_overflow() {
        mul(from(0x10000), from(0x10000));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_mul_overflow_negative() {
        mul(neg_from(0x10000), neg_from(0x10000));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U32), neg_from(1));
    }

    // === Advanced Math Operation Tests ===
    #[test]
    fun test_advanced_operations() {
        // Test pow
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 1);
        assert!(eq(pow(from(2), 0), from(1)), 2);
        assert!(eq(pow(neg_from(2), 2), from(4)), 3);
        assert!(eq(pow(from(1), 100), from(1)), 4);
    }

    // === Comparison Tests ===
    #[test]
    fun test_comparisons() {
        // Test cmp with all sign combinations
        assert!(cmp(neg_from(2), neg_from(1)) == LT, 0); // neg vs neg
        assert!(cmp(neg_from(1), neg_from(1)) == EQ, 1); // neg equal
        assert!(cmp(neg_from(1), neg_from(2)) == GT, 2); // neg vs neg
        assert!(cmp(neg_from(1), from(0)) == LT, 3); // neg vs pos
        assert!(cmp(from(0), neg_from(1)) == GT, 4); // pos vs neg
        assert!(cmp(from(1), from(2)) == LT, 5); // pos vs pos
        assert!(cmp(from(2), from(2)) == EQ, 6); // pos equal
        assert!(cmp(from(2), from(1)) == GT, 7); // pos vs pos

        // Test min with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            8
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            9
        );
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            10
        );
        assert!(
            eq(min(from(MAX_AS_U32), from(0)), from(0)),
            11
        );
        assert!(
            eq(
                min(neg_from(MIN_AS_U32), from(0)),
                neg_from(MIN_AS_U32)
            ),
            12
        );

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            13
        );
        assert!(
            eq(max(neg_from(1), from(0)), from(0)),
            14
        );
        assert!(
            eq(max(from(0), neg_from(1)), from(0)),
            15
        );
        assert!(
            eq(
                max(from(MAX_AS_U32), from(0)),
                from(MAX_AS_U32)
            ),
            16
        );
        assert!(
            eq(
                max(neg_from(MIN_AS_U32), from(0)),
                from(0)
            ),
            17
        );
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test OR
        assert!(
            as_u32(or(from(0x0F), from(0xF0))) == 0xFF,
            0
        );
        assert!(as_u32(or(from(0), from(0))) == 0, 1);
        assert!(
            as_u32(or(from(MAX_AS_U32), from(0))) == MAX_AS_U32,
            2
        );

        // Test AND
        assert!(
            as_u32(and(from(0x0F), from(0xFF))) == 0x0F,
            3
        );
        assert!(
            as_u32(and(from(0xFF), from(0xFF))) == 0xFF,
            4
        );
        assert!(as_u32(and(from(0), from(0xFF))) == 0, 5);
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs
        assert!(as_u32(abs(from(10))) == 10, 0);
        assert!(as_u32(abs(neg_from(10))) == 10, 1);
        assert!(as_u32(abs(neg_from(0))) == 0, 2);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 3);
        assert!(sign(from(10)) == 0, 4);
        assert!(is_neg(neg_from(1)), 5);
        assert!(!is_neg(from(1)), 6);
        assert!(!is_neg(zero()), 7);

        // Test comparison operators
        assert!(gt(from(10), from(5)), 8);
        assert!(lt(from(5), from(10)), 9);
        assert!(gte(from(5), from(5)), 10);
        assert!(lte(from(5), from(5)), 11);
        assert!(!gt(from(5), from(5)), 12);
        assert!(!lt(from(5), from(5)), 13);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i32)]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U32));
    }

    #[test]
    fun test_mod_general_and_edge_cases() {
        // Basic sign combinations
        assert!(eq(mod(from(7), from(3)), from(1)), 0);         // pos % pos
        assert!(eq(mod(neg_from(7), from(3)), neg_from(1)), 0); // neg % pos
        assert!(eq(mod(from(7), neg_from(3)), from(1)), 0);     // pos % neg
        assert!(eq(mod(neg_from(7), neg_from(3)), neg_from(1)), 0); // neg % neg

        // Zero dividend
        assert!(eq(mod(zero(), from(5)), zero()), 0);

        // Zero remainder (exact division)
        assert!(eq(mod(from(6), from(3)), zero()), 0);

        // Modulo by 1
        assert!(eq(mod(from(100), from(1)), zero()), 0);
        assert!(eq(mod(from(100), neg_from(1)), zero()), 0);

        // Smaller dividend than divisor
        assert!(eq(mod(from(2), from(5)), from(2)), 0);
        assert!(eq(mod(neg_from(2), from(5)), neg_from(2)), 0);

        // Large numbers
        assert!(eq(mod(from(MAX_AS_U32), from(8)),from(7)), 0);

        // Mathematical property: (a / b) * b + (a % b) == a
        let a = from(17);
        let b = from(5);
        let quotient = div(a, b);
        let remainder = mod(a, b);
        let reconstructed = add(mul(quotient, b), remainder);
        assert!(eq(a, reconstructed), 0);
    }

    #[test]
    #[expected_failure(abort_code = i32::DIVISION_BY_ZERO)]
    fun test_mod_division_by_zero() {
        mod(from(5), zero());
    }

    #[test]
    #[expected_failure(abort_code = i32::DIVISION_BY_ZERO)]
    fun test_mod_zero_by_zero() {
        mod(zero(), zero());
    }
}
