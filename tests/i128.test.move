#[test_only]
module move_int::i128_test {
    use move_int::i128::{from, neg_from, abs, abs_u128, add, sub, mul,
        div, wrapping_add, wrapping_sub, overflowing_add, overflowing_sub, pow, mod, neg,
        sign, cmp, min, max, eq, gt, lt, gte, lte, is_zero, is_neg, zero, unpack
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const BITS_MIN_I128: u128 = 1 << 127;
    const BITS_MAX_I128: u128 = 0x7fffffffffffffffffffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(unpack(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(unpack(from(0)) == 0, 3);
        assert!(unpack(from(10)) == 10, 4);
        assert!(unpack(from(BITS_MAX_I128)) == BITS_MAX_I128, 5);

        // Test neg_from()
        assert!(unpack(neg_from(0)) == 0, 6);
        assert!(unpack(neg_from(1)) == 0xffffffffffffffffffffffffffffffff, 7);
        assert!(unpack(neg_from(BITS_MIN_I128)) == BITS_MIN_I128, 8);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_from_overflow() {
        from(BITS_MIN_I128);
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
            unpack(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            unpack(
                wrapping_add(from(BITS_MAX_I128), from(1))
            ) == BITS_MIN_I128,
            1
        );
        assert!(
            unpack(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            unpack(wrapping_sub(from(0), from(1))) == unpack(neg_from(1)),
            3
        );

        // Test overflowing operations
        let (result, overflow) = overflowing_add(
            from(BITS_MAX_I128), neg_from(1)
        );
        assert!(
            !overflow && unpack(result) == BITS_MAX_I128 - 1,
            4
        );
        let (_, overflow) = overflowing_add(from(BITS_MAX_I128), from(1));
        assert!(overflow, 5);

        let (result, overflow) = overflowing_sub(from(BITS_MAX_I128), from(1));
        assert!(
            !overflow && unpack(result) == BITS_MAX_I128 - 1,
            6
        );
        let (_, overflow) = overflowing_sub(neg_from(BITS_MIN_I128), from(1));
        assert!(overflow, 7);

        // Test basic operations
        assert!(unpack(add(from(15), from(25))) == 40, 8);
        assert!(unpack(sub(from(25), from(15))) == 10, 9);

        // Test multiplication with all sign combinations
        assert!(
            unpack(mul(from(10), from(10))) == 100,
            10
        );
        assert!(
            unpack(mul(neg_from(10), from(10))) == unpack(neg_from(100)),
            11
        );
        assert!(
            unpack(mul(from(10), neg_from(10))) == unpack(neg_from(100)),
            12
        );
        assert!(unpack(mul(from(0), from(10))) == 0, 13);
        assert!(unpack(mul(from(10), from(0))) == 0, 14);
        assert!(
            unpack(mul(from(BITS_MIN_I128 / 2), neg_from(2)))
                == unpack(neg_from(BITS_MIN_I128)),
            15
        );

        // Test division with all sign combinations
        assert!(
            unpack(div(from(100), from(10))) == 10,
            16
        );
        assert!(
            unpack(div(from(100), neg_from(10))) == unpack(neg_from(10)),
            17
        );
        assert!(
            unpack(div(neg_from(100), neg_from(10))) == unpack(from(10)),
            18
        );
        assert!(
            unpack(div(neg_from(100), from(10))) == unpack(neg_from(10)),
            19
        );
        assert!(unpack(div(from(0), from(10))) == 0, 20);
        assert!(
            unpack(div(neg_from(BITS_MIN_I128), from(1))) == BITS_MIN_I128,
            21
        );

        // Test mod
        assert!(eq(mod(neg_from(3), from(3)), zero()), 10);
        assert!(eq(mod(neg_from(4), from(3)), neg_from(1)), 11);
        assert!(eq(mod(neg_from(5), from(3)), neg_from(2)), 12);
        assert!(eq(mod(neg_from(6), from(3)), zero()), 13);
        std::debug::print(&(170141183460469231731687303715884105727u128 / 170141183460469231731687303715884105728u128 ))
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_add_overflow() {
        add(from(BITS_MAX_I128), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_sub_underflow() {
        sub(neg_from(BITS_MIN_I128), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_mul_positive_overflow() {
        mul(from(BITS_MAX_I128), from(BITS_MAX_I128));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_mul_negative_overflow() {
        mul(from(BITS_MIN_I128), from(BITS_MAX_I128));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i128)]
    fun test_div_overflow() {
        div(neg_from(BITS_MIN_I128), neg_from(1));
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
                neg(from(BITS_MAX_I128)),
                neg_from(BITS_MAX_I128)
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
            cmp(neg_from(BITS_MIN_I128), from(BITS_MAX_I128)) == LT,
            5
        );
        assert!(
            cmp(from(BITS_MAX_I128), neg_from(BITS_MIN_I128)) == GT,
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
                max(from(BITS_MAX_I128), from(0)),
                from(BITS_MAX_I128)
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

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u128
        assert!(abs_u128(abs(from(10))) == 10, 0);
        assert!(abs_u128(abs(neg_from(10))) == 10, 1);
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
        abs(neg_from(BITS_MIN_I128));
    }
}
