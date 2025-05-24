#[test_only]
module move_int::i64_test {
    use move_int::i64::{as_u64, from, from_u64, neg_from, abs, abs_u64,
        add, sub, mul, div, wrapping_add, wrapping_sub, pow, sign, cmp,
        min, max, eq, gt, lt, gte, lte, and, or, is_zero, is_neg, zero, mod, Self
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const MIN_AS_U64: u64 = 1 << 63;
    const MAX_AS_U64: u64 = 0x7fffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u64(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u64(from(0)) == 0, 3);
        assert!(as_u64(from(10)) == 10, 4);
        assert!(as_u64(from(MAX_AS_U64)) == MAX_AS_U64, 5);

        // Test from_u64()
        assert!(as_u64(from_u64(42)) == 42, 6);
        assert!(as_u64(from_u64(MIN_AS_U64)) == MIN_AS_U64, 7);

        // Test neg_from()
        assert!(as_u64(neg_from(0)) == 0, 8);
        assert!(as_u64(neg_from(1)) == 0xffffffffffffffff, 9);
        assert!(as_u64(neg_from(MIN_AS_U64)) == MIN_AS_U64, 10);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_from_overflow() {
        from(MIN_AS_U64);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_neg_from_overflow() {
        neg_from(0x8000000000000001);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping_add
        assert!(
            as_u64(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u64(wrapping_add(from(MAX_AS_U64), from(1))) == MIN_AS_U64,
            1
        );

        // Test wrapping_sub
        assert!(
            as_u64(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            as_u64(wrapping_sub(from(0), from(1))) == as_u64(neg_from(1)),
            3
        );

        // Test add/sub without overflow
        assert!(as_u64(add(from(15), from(25))) == 40, 4);
        assert!(as_u64(sub(from(25), from(15))) == 10, 5);

        // Test multiplication
        assert!(as_u64(mul(from(10), from(10))) == 100, 6);
        assert!(
            as_u64(mul(neg_from(10), from(10))) == as_u64(neg_from(100)),
            7
        );

        // Test division
        assert!(as_u64(div(from(100), from(10))) == 10, 8);
        assert!(
            as_u64(div(from(100), neg_from(10))) == as_u64(neg_from(10)),
            9
        );
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_add_overflow() {
        add(from(MAX_AS_U64), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U64), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_mul_overflow() {
        mul(from(MAX_AS_U64), from(2));
    }

    #[test]
    #[expected_failure(abort_code = 1, location = move_int::i64)]
    fun test_division_by_zero() {
        div(from(MAX_AS_U64), from(0));
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

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test OR
        assert!(
            as_u64(or(from(0x0F), from(0xF0))) == 0xFF,
            0
        );
        assert!(
            as_u64(or(from(0), neg_from(1))) == 0xffffffffffffffff,
            1
        );

        // Test AND
        assert!(
            as_u64(and(from(0x0F), from(0xFF))) == 0x0F,
            2
        );
        assert!(
            as_u64(and(neg_from(1), from(0xFF))) == 0xFF,
            3
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u64
        assert!(as_u64(abs(from(10))) == 10, 0);
        assert!(as_u64(abs(neg_from(10))) == 10, 1);
        assert!(abs_u64(from(10)) == 10, 2);
        assert!(abs_u64(neg_from(10)) == 10, 3);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 4);
        assert!(sign(from(10)) == 0, 5);
        assert!(is_neg(neg_from(1)), 6);
        assert!(!is_neg(from(1)), 7);

        // Test min/max
        assert!(eq(min(from(10), from(5)), from(5)), 8);
        assert!(eq(max(from(10), from(5)), from(10)), 9);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i64)]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U64));
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
        assert!(eq(mod(from(MAX_AS_U64), from(8)),from(7)), 0);

        // Mathematical property: (a / b) * b + (a % b) == a
        let a = from(17);
        let b = from(5);
        let quotient = div(a, b);
        let remainder = mod(a, b);
        let reconstructed = add(mul(quotient, b), remainder);
        assert!(eq(a, reconstructed), 0);
    }

    #[test]
    #[expected_failure(abort_code = i64::DIVISION_BY_ZERO)]
    fun test_mod_division_by_zero() {
        mod(from(5), zero());
    }

    #[test]
    #[expected_failure(abort_code = i64::DIVISION_BY_ZERO)]
    fun test_mod_zero_by_zero() {
        mod(zero(), zero());
    }
}
