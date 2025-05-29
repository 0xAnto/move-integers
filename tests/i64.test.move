#[test_only]
module move_int::i64_test {
    use move_int::i64::{from, neg_from, abs, abs_u64,
        add, sub, mul, div, mod, wrapping_add, wrapping_sub, pow, sign, cmp,
        min, max, eq, gt, lt, gte, lte, is_zero, is_neg, zero, unpack
    };

    // Constants for testing
    const BITS_MIN_I64: u64 = 1 << 63;
    const BITS_MAX_I64: u64 = 0x7fffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_from_overflow() {
        from(BITS_MIN_I64);
    }

    #[test]
    fun test_from() {
        for (i in 0..10) {
            assert!(unpack(from(i)) == i, 0);
        }
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_neg_from_overflow() {
        neg_from(BITS_MIN_I64 + 1);
    }

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
        assert!(unpack(from(BITS_MAX_I64 - 1)) == BITS_MAX_I64 - 1, 5);

        // Test from_u64()
        assert!(unpack(from(42)) == 42, 6);

        // Test neg_from()
        assert!(unpack(neg_from(0)) == 0, 8);
        assert!(unpack(neg_from(1)) == 0xffffffffffffffff, 9);
        assert!(unpack(neg_from(BITS_MIN_I64)) == BITS_MIN_I64, 10);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping_add
        assert!(
            unpack(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            unpack(wrapping_add(from(BITS_MAX_I64), from(1))) == BITS_MIN_I64,
            1
        );

        // Test wrapping_sub
        assert!(
            unpack(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            unpack(wrapping_sub(from(0), from(1))) == unpack(neg_from(1)),
            3
        );

        // Test add/sub without overflow
        assert!(unpack(add(from(15), from(25))) == 40, 4);
        assert!(unpack(sub(from(25), from(15))) == 10, 5);

        // Test multiplication
        assert!(unpack(mul(from(10), from(10))) == 100, 6);
        assert!(
            unpack(mul(neg_from(10), from(10))) == unpack(neg_from(100)),
            7
        );

        // Test division
        assert!(unpack(div(from(100), from(10))) == 10, 8);
        assert!(
            unpack(div(from(100), neg_from(10))) == unpack(neg_from(10)),
            9
        );

        // Test mod
        assert!(eq(mod(neg_from(3), from(3)), zero()), 10);
        assert!(eq(mod(neg_from(4), from(3)), neg_from(1)), 11);
        assert!(eq(mod(neg_from(5), from(3)), neg_from(2)), 12);
        assert!(eq(mod(neg_from(6), from(3)), zero()), 13);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_add_overflow() {
        add(from(BITS_MAX_I64), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_sub_underflow() {
        sub(neg_from(BITS_MIN_I64), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_mul_positive_overflow() {
        mul(from(BITS_MAX_I64), from(BITS_MAX_I64));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_mul_negative_overflow() {
        mul(from(BITS_MIN_I64), from(BITS_MAX_I64));
    }

    #[test]
    #[expected_failure(abort_code = 1, location = move_int::i64)]
    fun test_division_by_zero() {
        div(from(BITS_MAX_I64), from(0));
    }

    // === Advanced Math Operation Tests ===
    #[test]
    fun test_advanced_operations() {
        // Test pow
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 1);
        assert!(eq(pow(from(2), 0), from(1)), 2);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_pow_overflow() {
        pow(from(1 << 31), 2);
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
        ); // neg vs neg
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            9
        ); // neg vs pos
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            10
        ); // pos vs neg
        assert!(eq(min(from(1), from(2)), from(1)), 11); // pos vs pos

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            12
        ); // neg vs neg
        assert!(
            eq(max(neg_from(1), from(0)), from(0)),
            13
        ); // neg vs pos
        assert!(
            eq(max(from(0), neg_from(1)), from(0)),
            14
        ); // pos vs neg
        assert!(eq(max(from(1), from(2)), from(2)), 15); // pos vs pos

        // Test basic comparisons
        assert!(gt(from(6), from(5)), 16);
        assert!(!gt(from(5), from(5)), 17);
        assert!(lt(from(4), from(5)), 18);
        assert!(!lt(from(5), from(5)), 19);
        assert!(gte(from(5), from(5)), 20);
        assert!(gte(from(6), from(5)), 21);
        assert!(lte(from(5), from(5)), 22);
        assert!(lte(from(4), from(5)), 23);
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u64
        assert!(abs_u64(abs(from(10))) == 10, 0);
        assert!(abs_u64(abs(neg_from(10))) == 10, 1);
        assert!(abs_u64(from(10)) == 10, 2);
        assert!(abs_u64(neg_from(10)) == 10, 3);
        assert!(abs_u64(neg_from(BITS_MIN_I64)) == BITS_MIN_I64, 4);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 5);
        assert!(sign(from(10)) == 0, 6);
        assert!(is_neg(neg_from(1)), 7);
        assert!(!is_neg(from(1)), 8);

        // Test min/max
        assert!(eq(min(from(10), from(5)), from(5)), 9);
        assert!(eq(max(from(10), from(5)), from(10)), 10);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_abs_overflow() {
        abs(neg_from(BITS_MIN_I64));
    }
}
