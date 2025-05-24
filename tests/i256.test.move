#[test_only]
module move_int::i256_test {
    use move_int::i256::{as_u256, from, neg_from, abs, add, sub, mul,
        div, wrapping_add, wrapping_sub, overflowing_add, overflowing_sub, pow, neg, sign,
        cmp, min, max, eq, gt, lt, gte, lte, and, or, is_zero, is_neg, zero, mod, Self
    };

    // Constants for testing
    const MIN_AS_U256: u256 = 1 << 255;
    const MAX_AS_U256: u256 =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u256(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u256(from(0)) == 0, 3);
        assert!(as_u256(from(10)) == 10, 4);
        assert!(as_u256(from(MAX_AS_U256)) == MAX_AS_U256, 5);

        // Test neg_from()
        assert!(as_u256(neg_from(0)) == 0, 6);
        assert!(
            as_u256(neg_from(1))
                ==
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            7
        );
        assert!(as_u256(neg_from(MIN_AS_U256)) == MIN_AS_U256, 8);

        // Test neg()
        assert!(eq(neg(from(5)), neg_from(5)), 9);
        assert!(eq(neg(neg_from(5)), from(5)), 10);
        assert!(eq(neg(zero()), zero()), 11);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_from_overflow() {
        from(MIN_AS_U256);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_neg_from_overflow() {
        neg_from(
            0x8000000000000000000000000000000000000000000000000000000000000001
        );
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping operations
        assert!(
            as_u256(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u256(
                wrapping_add(from(MAX_AS_U256), from(1))
            ) == MIN_AS_U256,
            1
        );
        assert!(
            as_u256(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            as_u256(wrapping_sub(from(0), from(1))) == as_u256(neg_from(1)),
            3
        );

        // Test overflowing operations
        let (result, overflow) = overflowing_add(
            from(MAX_AS_U256), neg_from(1)
        );
        assert!(
            !overflow && as_u256(result) == MAX_AS_U256 - 1,
            4
        );
        let (_, overflow) = overflowing_add(from(MAX_AS_U256), from(1));
        assert!(overflow, 5);

        let (result, overflow) = overflowing_sub(from(MAX_AS_U256), from(1));
        assert!(
            !overflow && as_u256(result) == MAX_AS_U256 - 1,
            6
        );
        let (_, overflow) = overflowing_sub(neg_from(MIN_AS_U256), from(1));
        assert!(overflow, 7);

        // Test standard operations
        assert!(as_u256(add(from(15), from(25))) == 40, 8);
        assert!(as_u256(sub(from(25), from(15))) == 10, 9);
    }

    // === Multiplication and Division Tests ===
    #[test]
    fun test_mul_div() {
        // Test multiplication with different signs
        assert!(as_u256(mul(from(10), from(10))) == 100, 0);
        assert!(
            as_u256(mul(neg_from(10), from(10))) == as_u256(neg_from(100)),
            1
        );
        assert!(
            as_u256(mul(from(10), neg_from(10))) == as_u256(neg_from(100)),
            2
        );

        // Test multiplication edge cases
        assert!(as_u256(mul(from(0), from(10))) == 0, 3);
        assert!(as_u256(mul(from(10), from(0))) == 0, 4);
        assert!(
            as_u256(mul(from(MIN_AS_U256 / 2), neg_from(2)))
                == as_u256(neg_from(MIN_AS_U256)),
            5
        );

        // Test division with different signs
        assert!(as_u256(div(from(100), from(10))) == 10, 6);
        assert!(
            as_u256(div(from(100), neg_from(10))) == as_u256(neg_from(10)),
            7
        );
        assert!(
            as_u256(div(neg_from(100), neg_from(10))) == as_u256(from(10)),
            8
        );
        assert!(
            as_u256(div(neg_from(MIN_AS_U256), from(1))) == MIN_AS_U256,
            9
        );
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_mul_overflow() {
        mul(from(MIN_AS_U256 / 2), from(3));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_mul_overflow_negative() {
        mul(neg_from(MIN_AS_U256 / 2), neg_from(2));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U256), neg_from(1));
    }

    // === Overflow Tests ===
    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_add_overflow() {
        add(from(MAX_AS_U256), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U256), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U256), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U256), from(1));
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

        // Test comparison operators
        assert!(gt(from(6), from(5)), 8);
        assert!(!gt(from(5), from(5)), 9);
        assert!(lt(from(4), from(5)), 10);
        assert!(!lt(from(5), from(5)), 11);
        assert!(gte(from(5), from(5)), 12);
        assert!(lte(from(5), from(5)), 13);
        assert!(gte(from(6), from(5)), 14);
        assert!(lte(from(4), from(5)), 15);
    }

    // === Min/Max Tests ===
    #[test]
    fun test_min_max() {
        // Test min with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            0
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            1
        );
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            2
        );
        assert!(eq(min(from(1), from(2)), from(1)), 3);
        assert!(
            eq(min(from(MAX_AS_U256), from(0)), from(0)),
            4
        );
        assert!(
            eq(
                min(neg_from(MIN_AS_U256), from(0)),
                neg_from(MIN_AS_U256)
            ),
            5
        );

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            6
        );
        assert!(eq(max(neg_from(1), from(0)), from(0)), 7);
        assert!(eq(max(from(0), neg_from(1)), from(0)), 8);
        assert!(eq(max(from(1), from(2)), from(2)), 9);
        assert!(
            eq(
                max(from(MAX_AS_U256), from(0)),
                from(MAX_AS_U256)
            ),
            10
        );
        assert!(eq(max(from(5), from(5)), from(5)), 11);
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test AND
        assert!(
            as_u256(and(from(0x0F), from(0xFF))) == 0x0F,
            0
        );
        assert!(
            as_u256(and(neg_from(1), from(0xFF))) == 0xFF,
            1
        );
        assert!(as_u256(and(from(0), from(0xFF))) == 0, 2);

        // Test OR
        assert!(
            as_u256(or(from(0x0F), from(0xF0))) == 0xFF,
            3
        );
        assert!(
            as_u256(or(from(0), neg_from(1)))
                ==
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            4
        );
        assert!(
            as_u256(or(from(MAX_AS_U256), from(0))) == MAX_AS_U256,
            5
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u256
        assert!(as_u256(abs(from(10))) == 10, 0);
        assert!(as_u256(abs(neg_from(10))) == 10, 1);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 2);
        assert!(sign(from(10)) == 0, 3);
        assert!(sign(from(0)) == 0, 4);
        assert!(is_neg(neg_from(1)), 5);
        assert!(!is_neg(from(1)), 6);
        assert!(!is_neg(zero()), 7);

        // Test power function
        assert!(eq(pow(from(2), 10), from(1024)), 8);
        assert!(eq(pow(from(3), 4), from(81)), 9);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 10);
        assert!(eq(pow(neg_from(2), 4), from(16)), 11);
        assert!(eq(pow(from(1), 1000000), from(1)), 12); // Large exponent
        assert!(eq(pow(from(0), 5), from(0)), 13); // Zero base
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U256));
    }

    #[test]
    #[expected_failure()]
    fun test_pow_overflow() {
        let base = from(1000);
        let _result = pow(base, 100); // Should overflow but may not be caught
    }
    #[test]
    #[expected_failure()]
    fun test_silent_mul_overflow() {
        // Try to multiply numbers that would overflow u256 before range checking
        let a = from(0x1000000000000000000000000000000000000000000000000000000000000000);
        let b = from(0x1000000000000000000000000000000000000000000000000000000000000000);
        let _result = mul(a, b); // May produce incorrect result due to u256 overflow
    }

    #[test]
    fun test_neg_from_edge_case() {
        // This creates an invalid state that should be caught
        let _result = neg_from(MIN_AS_U256); // May create inconsistent representation
    }

    // === Division Edge Cases ===

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_div_min_by_neg_one() {
        // Division of minimum negative value by -1 should overflow
        // MIN_AS_U256 represents -2^255, dividing by -1 gives +2^255 which can't be represented
        let min_neg = neg_from(MIN_AS_U256);
        let neg_one = neg_from(1);
        div(min_neg, neg_one); // Should abort due to overflow
    }

    #[test]
    fun test_div_edge_cases_that_work() {
        // These should work fine
        let min_neg = neg_from(MIN_AS_U256);
        let pos_one = from(1);
        let result = div(min_neg, pos_one);
        assert!(eq(result, min_neg), 0); // -MIN / 1 = -MIN

        // Divide by 2
        let pos_two = from(2);
        let result2 = div(min_neg, pos_two);
        assert!(as_u256(result2) != MIN_AS_U256, 1); // Should be half of min
    }

    // === Comparison Logic Verification ===

    #[test]
    fun test_comparison_edge_cases() {
        let min_neg = neg_from(MIN_AS_U256);  // Most negative value
        let max_pos = from(MAX_AS_U256);      // Most positive value
        let zero_val = zero();
        let neg_one = neg_from(1);
        let pos_one = from(1);

        // Test extreme comparisons
        assert!(lt(min_neg, max_pos), 0);    // Most negative < Most positive
        assert!(gt(max_pos, min_neg), 1);    // Most positive > Most negative
        assert!(lt(min_neg, zero_val), 2);   // Most negative < 0
        assert!(gt(max_pos, zero_val), 3);   // Most positive > 0

        // Test near-zero comparisons
        assert!(lt(neg_one, zero_val), 4);   // -1 < 0
        assert!(lt(neg_one, pos_one), 5);    // -1 < 1
        assert!(gt(pos_one, neg_one), 6);    // 1 > -1

        // Test boundary values
        let almost_max = from(MAX_AS_U256 - 1);
        let almost_min_abs = MIN_AS_U256 - 1;
        let almost_min = neg_from(almost_min_abs);

        assert!(lt(almost_max, max_pos), 7);  // MAX-1 < MAX
        assert!(gt(almost_min, min_neg), 8);  // -(MIN-1) > -MIN
    }

    #[test]
    fun test_cmp_function_comprehensive() {
        // Test all comparison cases systematically
        let values = vector[
            neg_from(MIN_AS_U256),           // Most negative
            neg_from(100),                   // Medium negative
            neg_from(1),                     // Small negative
            zero(),                          // Zero
            from(1),                         // Small positive
            from(100),                       // Medium positive
            from(MAX_AS_U256)                // Most positive
        ];

        let i = 0;
        while (i < 7) {
            let j = 0;
            while (j < 7) {
                let val1 = values[i];
                let val2 = values[j];
                let cmp_result = cmp(val1, val2);

                if (i < j) {
                    assert!(cmp_result == LT, (i * 10 + j));
                } else if (i == j) {
                    assert!(cmp_result == EQ, (i * 10 + j));
                } else {
                    assert!(cmp_result == GT, (i * 10 + j));
                };
                j += 1;
            };
            i += 1;
        };
    }

    // === Power Function Edge Cases ===

    #[test]
    fun test_pow_edge_cases() {
        // Test power of 0
        assert!(eq(pow(from(0), 0), from(1)), 0);    // 0^0 = 1 (mathematical convention)
        assert!(eq(pow(from(0), 1), from(0)), 1);    // 0^1 = 0
        assert!(eq(pow(from(0), 100), from(0)), 2);  // 0^n = 0

        // Test power of 1
        assert!(eq(pow(from(1), 0), from(1)), 3);    // 1^0 = 1
        assert!(eq(pow(from(1), 1000000), from(1)), 4); // 1^n = 1

        // Test negative base
        assert!(eq(pow(neg_from(1), 0), from(1)), 5);    // (-1)^0 = 1
        assert!(eq(pow(neg_from(1), 1), neg_from(1)), 6); // (-1)^1 = -1
        assert!(eq(pow(neg_from(1), 2), from(1)), 7);     // (-1)^2 = 1
        assert!(eq(pow(neg_from(1), 3), neg_from(1)), 8); // (-1)^3 = -1

        // Test exponent 0
        assert!(eq(pow(from(12345), 0), from(1)), 9);     // n^0 = 1
        assert!(eq(pow(neg_from(12345), 0), from(1)), 10); // (-n)^0 = 1
    }

    #[test]
    #[expected_failure] // Should overflow at some point
    fun test_pow_overflow_with_base_2() {
        // 2^256 should definitely overflow
        pow(from(2), 256);
    }

    #[test]
    #[expected_failure] // Should overflow
    fun test_pow_large_base() {
        // Large base with small exponent should overflow
        let large_base = from(MAX_AS_U256 / 2);
        pow(large_base, 3);
    }

    // === Negation Edge Cases ===

    #[test]
    fun test_neg_edge_cases() {
        // Test double negation
        let val = from(12345);
        assert!(eq(neg(neg(val)), val), 0);

        let neg_val = neg_from(12345);
        assert!(eq(neg(neg(neg_val)), neg_val), 1);

        // Test negation of zero
        assert!(eq(neg(zero()), zero()), 2);

        // Test negation of max positive
        let max_pos = from(MAX_AS_U256);
        let neg_max = neg(max_pos);
        assert!(is_neg(neg_max), 3);
        assert!(eq(neg(neg_max), max_pos), 4);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_neg_min_value() {
        // Negating the minimum value should overflow
        let min_neg = neg_from(MIN_AS_U256);
        neg(min_neg); // Should abort
    }

    // === Bitwise Operation Edge Cases ===

    #[test]
    fun test_bitwise_edge_cases() {
        let all_ones = neg_from(1); // -1 in two's complement = all 1s
        let zero_val = zero();
        let max_pos = from(MAX_AS_U256);

        // AND with all 1s should return the other value
        assert!(eq(and(max_pos, all_ones), max_pos), 0);
        assert!(eq(and(zero_val, all_ones), zero_val), 1);

        // OR with all 1s should return all 1s
        assert!(eq(or(max_pos, all_ones), all_ones), 2);
        assert!(eq(or(zero_val, all_ones), all_ones), 3);

        // AND with zero should return zero
        assert!(eq(and(max_pos, zero_val), zero_val), 4);
        assert!(eq(and(neg_from(12345), zero_val), zero_val), 5);

        // OR with zero should return the other value
        assert!(eq(or(max_pos, zero_val), max_pos), 6);
        assert!(eq(or(neg_from(12345), zero_val), neg_from(12345)), 7);
    }

    // === Wrapping vs Non-Wrapping Arithmetic Edge Cases ===

    #[test]
    fun test_wrapping_vs_checked_consistency() {
        // Test that overflowing operations behave consistently
        let max_pos = from(MAX_AS_U256);
        let min_neg = neg_from(MIN_AS_U256);
        let one = from(1);

        // Test overflowing_add
        let (result1, overflow1) = overflowing_add(max_pos, one);
        assert!(overflow1, 0);

        let (result2, overflow2) = overflowing_sub(min_neg, one);
        assert!(overflow2, 1);

        // Test wrapping versions don't abort
        let wrap_result1 = wrapping_add(max_pos, one);
        let wrap_result2 = wrapping_sub(min_neg, one);

        // Results should match the overflowing versions
        assert!(eq(wrap_result1, result1), 2);
        assert!(eq(wrap_result2, result2), 3);
    }

    // === Sign and Zero Detection Edge Cases ===

    #[test]
    fun test_sign_detection_edge_cases() {
        // Test sign of boundary values
        assert!(sign(from(MAX_AS_U256)) == 0, 0);    // Max positive
        assert!(sign(neg_from(MIN_AS_U256)) == 1, 1); // Max negative
        assert!(sign(zero()) == 0, 2);                // Zero

        // Test is_neg
        assert!(!is_neg(from(MAX_AS_U256)), 3);
        assert!(is_neg(neg_from(MIN_AS_U256)), 4);
        assert!(!is_neg(zero()), 5);

        // Test is_zero
        assert!(!is_zero(from(1)), 6);
        assert!(!is_zero(neg_from(1)), 7);
        assert!(is_zero(zero()), 8);
    }

    // === Min/Max Edge Cases ===

    #[test]
    fun test_min_max_edge_cases() {
        let max_pos = from(MAX_AS_U256);
        let min_neg = neg_from(MIN_AS_U256);
        let zero_val = zero();

        // Test with extreme values
        assert!(eq(min(max_pos, min_neg), min_neg), 0);
        assert!(eq(max(max_pos, min_neg), max_pos), 1);

        // Test with zero
        assert!(eq(min(zero_val, max_pos), zero_val), 2);
        assert!(eq(max(zero_val, min_neg), zero_val), 3);

        // Test identical values
        assert!(eq(min(max_pos, max_pos), max_pos), 4);
        assert!(eq(max(min_neg, min_neg), min_neg), 5);
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
        assert!(eq(mod(from(MAX_AS_U256), from(8)),from(7)), 0);

        // Mathematical property: (a / b) * b + (a % b) == a
        let a = from(17);
        let b = from(5);
        let quotient = div(a, b);
        let remainder = mod(a, b);
        let reconstructed = add(mul(quotient, b), remainder);
        assert!(eq(a, reconstructed), 0);
    }

    #[test]
    #[expected_failure(abort_code = i256::DIVISION_BY_ZERO)]
    fun test_mod_division_by_zero() {
        mod(from(5), zero());
    }

    #[test]
    #[expected_failure(abort_code = i256::DIVISION_BY_ZERO)]
    fun test_mod_zero_by_zero() {
        mod(zero(), zero());
    }
}
