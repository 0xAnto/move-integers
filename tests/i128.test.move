#[test_only]
module move_int::i128_test {
    use move_int::i128::{as_u128, from, neg_from, abs, abs_u128, add, sub, mul,
        div, wrapping_add, wrapping_sub, overflowing_add, overflowing_sub, pow, neg,
        sign, cmp, min, max, eq, gt, lt, gte, lte, and, or, is_zero, is_neg, zero, mod, Self
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const MIN_AS_U128: u128 = 1 << 127;
    const MAX_AS_U128: u128 = 0x7fffffffffffffffffffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u128(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u128(from(0)) == 0, 3);
        assert!(as_u128(from(10)) == 10, 4);
        assert!(as_u128(from(MAX_AS_U128)) == MAX_AS_U128, 5);

        // Test neg_from()
        assert!(as_u128(neg_from(0)) == 0, 6);
        assert!(as_u128(neg_from(1)) == 0xffffffffffffffffffffffffffffffff, 7);
        assert!(as_u128(neg_from(MIN_AS_U128)) == MIN_AS_U128, 8);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_from_overflow() {
        from(MIN_AS_U128);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_neg_from_overflow() {
        neg_from(0x80000000000000000000000000000001);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping operations
        assert!(
            as_u128(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u128(
                wrapping_add(from(MAX_AS_U128), from(1))
            ) == MIN_AS_U128,
            1
        );
        assert!(
            as_u128(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            as_u128(wrapping_sub(from(0), from(1))) == as_u128(neg_from(1)),
            3
        );

        // Test overflowing operations
        let (result, overflow) = overflowing_add(
            from(MAX_AS_U128), neg_from(1)
        );
        assert!(
            !overflow && as_u128(result) == MAX_AS_U128 - 1,
            4
        );
        let (_, overflow) = overflowing_add(from(MAX_AS_U128), from(1));
        assert!(overflow, 5);

        let (result, overflow) = overflowing_sub(from(MAX_AS_U128), from(1));
        assert!(
            !overflow && as_u128(result) == MAX_AS_U128 - 1,
            6
        );
        let (_, overflow) = overflowing_sub(neg_from(MIN_AS_U128), from(1));
        assert!(overflow, 7);

        // Test basic operations
        assert!(as_u128(add(from(15), from(25))) == 40, 8);
        assert!(as_u128(sub(from(25), from(15))) == 10, 9);

        // Test multiplication with all sign combinations
        assert!(
            as_u128(mul(from(10), from(10))) == 100,
            10
        );
        assert!(
            as_u128(mul(neg_from(10), from(10))) == as_u128(neg_from(100)),
            11
        );
        assert!(
            as_u128(mul(from(10), neg_from(10))) == as_u128(neg_from(100)),
            12
        );
        assert!(as_u128(mul(from(0), from(10))) == 0, 13);
        assert!(as_u128(mul(from(10), from(0))) == 0, 14);
        assert!(
            as_u128(mul(from(MIN_AS_U128 / 2), neg_from(2)))
                == as_u128(neg_from(MIN_AS_U128)),
            15
        );

        // Test division with all sign combinations
        assert!(
            as_u128(div(from(100), from(10))) == 10,
            16
        );
        assert!(
            as_u128(div(from(100), neg_from(10))) == as_u128(neg_from(10)),
            17
        );
        assert!(
            as_u128(div(neg_from(100), neg_from(10))) == as_u128(from(10)),
            18
        );
        assert!(
            as_u128(div(neg_from(100), from(10))) == as_u128(neg_from(10)),
            19
        );
        assert!(as_u128(div(from(0), from(10))) == 0, 20);
        assert!(
            as_u128(div(neg_from(MIN_AS_U128), from(1))) == MIN_AS_U128,
            21
        );
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_add_overflow() {
        add(from(MAX_AS_U128), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U128), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_mul_overflow() {
        mul(from(MIN_AS_U128 / 2), from(3));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_mul_overflow_negative() {
        mul(neg_from(MIN_AS_U128 / 2), neg_from(2));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U128), neg_from(1));
    }

    // === Advanced Math Operation Tests ===
    #[test]
    fun test_advanced_operations() {
        // Test pow with different cases
        assert!(eq(pow(from(2), 0), from(1)), 0);
        assert!(eq(pow(from(2), 10), from(1024)), 1);
        assert!(eq(pow(from(3), 4), from(81)), 2);

        // Test neg
        assert!(eq(neg(from(5)), neg_from(5)), 3);
        assert!(eq(neg(neg_from(5)), from(5)), 4);
        assert!(eq(neg(zero()), zero()), 5);
        assert!(
            eq(
                neg(from(MAX_AS_U128)),
                neg_from(MAX_AS_U128)
            ),
            6
        );
    }

    // === Comparison Tests ===
    #[test]
    fun test_comparisons() {
        // Test cmp with all sign combinations
        assert!(cmp(neg_from(2), neg_from(1)) == LT, 0);
        assert!(cmp(neg_from(1), neg_from(1)) == EQ, 1);
        assert!(cmp(neg_from(1), neg_from(2)) == GT, 2);
        assert!(cmp(neg_from(1), from(0)) == LT, 3);
        assert!(cmp(from(0), neg_from(1)) == GT, 4);
        assert!(
            cmp(neg_from(MIN_AS_U128), from(MAX_AS_U128)) == LT,
            5
        );
        assert!(
            cmp(from(MAX_AS_U128), neg_from(MIN_AS_U128)) == GT,
            6
        );

        // Test min/max with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            7
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            8
        );
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            9
        );
        assert!(eq(min(from(1), from(2)), from(1)), 10);
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            11
        );
        assert!(
            eq(max(neg_from(1), from(0)), from(0)),
            12
        );
        assert!(eq(max(from(1), from(2)), from(2)), 13);
        assert!(
            eq(
                max(from(MAX_AS_U128), from(0)),
                from(MAX_AS_U128)
            ),
            14
        );

        // Test comparison operators
        assert!(gt(from(6), from(5)), 15);
        assert!(!gt(from(5), from(5)), 16);
        assert!(lt(from(4), from(5)), 17);
        assert!(!lt(from(5), from(5)), 18);
        assert!(gte(from(5), from(5)), 19);
        assert!(lte(from(5), from(5)), 20);
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test AND
        assert!(
            as_u128(and(from(0x0F), from(0xFF))) == 0x0F,
            0
        );
        assert!(
            as_u128(and(neg_from(1), from(0xFF))) == 0xFF,
            1
        );
        assert!(as_u128(and(from(0), from(0xFF))) == 0, 2);

        // Test OR
        assert!(
            as_u128(or(from(0x0F), from(0xF0))) == 0xFF,
            3
        );
        assert!(
            as_u128(or(from(0), neg_from(1)))
                == 0xffffffffffffffffffffffffffffffff,
            4
        );
        assert!(
            as_u128(or(from(MAX_AS_U128), from(0))) == MAX_AS_U128,
            5
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u128
        assert!(as_u128(abs(from(10))) == 10, 0);
        assert!(as_u128(abs(neg_from(10))) == 10, 1);
        assert!(abs_u128(from(10)) == 10, 2);
        assert!(abs_u128(neg_from(10)) == 10, 3);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 4);
        assert!(sign(from(10)) == 0, 5);
        assert!(is_neg(neg_from(1)), 6);
        assert!(!is_neg(from(1)), 7);
        assert!(!is_neg(zero()), 8);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U128));
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
        assert!(eq(mod(from(MAX_AS_U128), from(8)),from(7)), 0);

        // Mathematical property: (a / b) * b + (a % b) == a
        let a = from(17);
        let b = from(5);
        let quotient = div(a, b);
        let remainder = mod(a, b);
        let reconstructed = add(mul(quotient, b), remainder);
        assert!(eq(a, reconstructed), 0);
    }

    #[test]
    #[expected_failure(abort_code = i128::DIVISION_BY_ZERO)]
    fun test_mod_division_by_zero() {
        mod(from(5), zero());
    }

    #[test]
    #[expected_failure(abort_code = i128::DIVISION_BY_ZERO)]
    fun test_mod_zero_by_zero() {
        mod(zero(), zero());
    }
}
