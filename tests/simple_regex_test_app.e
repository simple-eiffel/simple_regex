note
	description: "Test application for simple_regex"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests
		local
			tests: SIMPLE_REGEX_TEST
			builder_tests: SIMPLE_REGEX_BUILDER_TEST
			patterns_tests: SIMPLE_REGEX_PATTERNS_TEST
		do
			create tests
			create builder_tests
			create patterns_tests
			io.put_string ("simple_regex test runner%N")
			io.put_string ("===========================%N%N")

			passed := 0
			failed := 0

			run_regex_tests (tests)
			run_builder_tests (builder_tests)
			run_patterns_tests (patterns_tests)

			io.put_string ("%N===========================%N")
			io.put_string ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

	run_regex_tests (tests: SIMPLE_REGEX_TEST)
			-- Run SIMPLE_REGEX tests
		do
			-- Basic Match Tests
			io.put_string ("Basic Match Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_basic_match, "test_basic_match")
			run_test (agent tests.test_no_match, "test_no_match")
			run_test (agent tests.test_match_in_middle, "test_match_in_middle")
			run_test (agent tests.test_empty_pattern, "test_empty_pattern")

			-- Character Class Tests
			io.put_string ("%NCharacter Class Tests%N")
			io.put_string ("---------------------%N")
			run_test (agent tests.test_digit_class, "test_digit_class")
			run_test (agent tests.test_word_class, "test_word_class")
			run_test (agent tests.test_whitespace_class, "test_whitespace_class")
			run_test (agent tests.test_custom_class, "test_custom_class")

			-- Capturing Group Tests
			io.put_string ("%NCapturing Group Tests%N")
			io.put_string ("---------------------%N")
			run_test (agent tests.test_single_group, "test_single_group")
			run_test (agent tests.test_multiple_groups, "test_multiple_groups")
			run_test (agent tests.test_nested_groups, "test_nested_groups")
			run_test (agent tests.test_non_capturing_group, "test_non_capturing_group")

			-- Match All Tests
			io.put_string ("%NMatch All Tests%N")
			io.put_string ("---------------%N")
			run_test (agent tests.test_match_all_basic, "test_match_all_basic")
			run_test (agent tests.test_match_all_no_matches, "test_match_all_no_matches")
			run_test (agent tests.test_match_all_as_strings, "test_match_all_as_strings")

			-- Replace Tests
			io.put_string ("%NReplace Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_replace_first, "test_replace_first")
			run_test (agent tests.test_replace_all, "test_replace_all")
			run_test (agent tests.test_replace_with_groups, "test_replace_with_groups")
			run_test (agent tests.test_replace_no_match, "test_replace_no_match")

			-- Split Tests
			io.put_string ("%NSplit Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_split_basic, "test_split_basic")
			run_test (agent tests.test_split_no_match, "test_split_no_match")

			-- Options Tests
			io.put_string ("%NOptions Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_case_insensitive, "test_case_insensitive")
			run_test (agent tests.test_multiline, "test_multiline")
			run_test (agent tests.test_dotall, "test_dotall")
			run_test (agent tests.test_option_immutability, "test_option_immutability")

			-- Convenience Method Tests
			io.put_string ("%NConvenience Method Tests%N")
			io.put_string ("------------------------%N")
			run_test (agent tests.test_matches_pattern, "test_matches_pattern")
			run_test (agent tests.test_first_match_for, "test_first_match_for")
			run_test (agent tests.test_all_matches_for, "test_all_matches_for")
			run_test (agent tests.test_replace_first_match, "test_replace_first_match")
			run_test (agent tests.test_replace_all_matches, "test_replace_all_matches")
			run_test (agent tests.test_split_by_pattern, "test_split_by_pattern")

			-- Match Context Tests
			io.put_string ("%NMatch Context Tests%N")
			io.put_string ("-------------------%N")
			run_test (agent tests.test_text_before, "test_text_before")
			run_test (agent tests.test_text_after, "test_text_after")

			-- Safety Tests
			io.put_string ("%NSafety Tests%N")
			io.put_string ("------------%N")
			run_test (agent tests.test_escape, "test_escape")
			run_test (agent tests.test_pattern_complexity_simple, "test_pattern_complexity_simple")
			run_test (agent tests.test_pattern_complexity_dangerous, "test_pattern_complexity_dangerous")
			run_test (agent tests.test_is_potentially_dangerous, "test_is_potentially_dangerous")

			-- Error Handling Tests
			io.put_string ("%NError Handling Tests%N")
			io.put_string ("--------------------%N")
			run_test (agent tests.test_invalid_pattern, "test_invalid_pattern")
			run_test (agent tests.test_is_valid_pattern, "test_is_valid_pattern")

			-- Advanced Feature Tests
			io.put_string ("%NAdvanced Feature Tests%N")
			io.put_string ("----------------------%N")
			run_test (agent tests.test_lookahead_positive, "test_lookahead_positive")
			run_test (agent tests.test_lookahead_negative, "test_lookahead_negative")
			run_test (agent tests.test_lookbehind_positive, "test_lookbehind_positive")
			run_test (agent tests.test_backreference, "test_backreference")
			run_test (agent tests.test_unicode_property, "test_unicode_property")
		end

	run_builder_tests (tests: SIMPLE_REGEX_BUILDER_TEST)
			-- Run SIMPLE_REGEX_BUILDER tests
		do
			io.put_string ("%N%N=== BUILDER TESTS ===%N%N")

			-- Literal Tests
			io.put_string ("Literal Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_literal_simple, "test_literal_simple")
			run_test (agent tests.test_literal_escapes_special_chars, "test_literal_escapes_special_chars")
			run_test (agent tests.test_raw_no_escaping, "test_raw_no_escaping")

			-- Character Class Tests
			io.put_string ("%NCharacter Class Tests%N")
			io.put_string ("---------------------%N")
			run_test (agent tests.test_digit, "test_digit")
			run_test (agent tests.test_word_char, "test_word_char")
			run_test (agent tests.test_whitespace, "test_whitespace")
			run_test (agent tests.test_one_of, "test_one_of")
			run_test (agent tests.test_none_of, "test_none_of")
			run_test (agent tests.test_range, "test_range")

			-- Quantifier Tests
			io.put_string ("%NQuantifier Tests%N")
			io.put_string ("----------------%N")
			run_test (agent tests.test_zero_or_more, "test_zero_or_more")
			run_test (agent tests.test_one_or_more, "test_one_or_more")
			run_test (agent tests.test_optional, "test_optional")
			run_test (agent tests.test_exactly, "test_exactly")
			run_test (agent tests.test_at_least, "test_at_least")
			run_test (agent tests.test_between, "test_between")
			run_test (agent tests.test_lazy_quantifiers, "test_lazy_quantifiers")

			-- Group Tests
			io.put_string ("%NGroup Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_capturing_group, "test_capturing_group")
			run_test (agent tests.test_non_capturing_group, "test_non_capturing_group")
			run_test (agent tests.test_multiple_groups, "test_multiple_groups")
			run_test (agent tests.test_group_balancing, "test_group_balancing")

			-- Anchor Tests
			io.put_string ("%NAnchor Tests%N")
			io.put_string ("------------%N")
			run_test (agent tests.test_start_of_string, "test_start_of_string")
			run_test (agent tests.test_end_of_string, "test_end_of_string")
			run_test (agent tests.test_word_boundary, "test_word_boundary")

			-- Alternation Tests
			io.put_string ("%NAlternation Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_alternation, "test_alternation")

			-- Lookahead/Lookbehind Tests
			io.put_string ("%NLookahead/Lookbehind Tests%N")
			io.put_string ("--------------------------%N")
			run_test (agent tests.test_positive_lookahead, "test_positive_lookahead")
			run_test (agent tests.test_negative_lookahead, "test_negative_lookahead")
			run_test (agent tests.test_positive_lookbehind, "test_positive_lookbehind")
			run_test (agent tests.test_negative_lookbehind, "test_negative_lookbehind")

			-- Advanced Feature Tests
			io.put_string ("%NAdvanced Feature Tests%N")
			io.put_string ("----------------------%N")
			run_test (agent tests.test_atomic_group, "test_atomic_group")
			run_test (agent tests.test_backreference, "test_backreference")
			run_test (agent tests.test_recursion, "test_recursion")
			run_test (agent tests.test_conditional, "test_conditional")

			-- Special Character Tests
			io.put_string ("%NSpecial Character Tests%N")
			io.put_string ("-----------------------%N")
			run_test (agent tests.test_special_chars, "test_special_chars")

			-- Fluent API Tests
			io.put_string ("%NFluent API Tests%N")
			io.put_string ("----------------%N")
			run_test (agent tests.test_fluent_chaining, "test_fluent_chaining")
			run_test (agent tests.test_reset, "test_reset")

			-- Options Tests
			io.put_string ("%NOptions Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_to_regex_with_options, "test_to_regex_with_options")

			-- Any Character Tests
			io.put_string ("%NAny Character Tests%N")
			io.put_string ("-------------------%N")
			run_test (agent tests.test_any_char, "test_any_char")

			-- Unicode Tests
			io.put_string ("%NUnicode Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_unicode_property, "test_unicode_property")
			run_test (agent tests.test_grapheme, "test_grapheme")
		end

	run_patterns_tests (tests: SIMPLE_REGEX_PATTERNS_TEST)
			-- Run SIMPLE_REGEX_PATTERNS tests
		do
			io.put_string ("%N%N=== PATTERNS TESTS ===%N%N")

			-- Email and Web Tests
			io.put_string ("Email and Web Tests%N")
			io.put_string ("-------------------%N")
			run_test (agent tests.test_email_valid, "test_email_valid")
			run_test (agent tests.test_email_invalid, "test_email_invalid")
			run_test (agent tests.test_url_valid, "test_url_valid")
			run_test (agent tests.test_url_invalid, "test_url_invalid")
			run_test (agent tests.test_domain_valid, "test_domain_valid")

			-- Network Tests
			io.put_string ("%NNetwork Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_ipv4_valid, "test_ipv4_valid")
			run_test (agent tests.test_ipv4_invalid, "test_ipv4_invalid")
			run_test (agent tests.test_mac_address_valid, "test_mac_address_valid")

			-- Phone Tests
			io.put_string ("%NPhone Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_phone_us_valid, "test_phone_us_valid")
			run_test (agent tests.test_phone_us_invalid, "test_phone_us_invalid")

			-- Date Tests
			io.put_string ("%NDate Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_date_iso_valid, "test_date_iso_valid")
			run_test (agent tests.test_date_iso_invalid, "test_date_iso_invalid")
			run_test (agent tests.test_date_us_valid, "test_date_us_valid")
			run_test (agent tests.test_date_eu_valid, "test_date_eu_valid")
			run_test (agent tests.test_datetime_iso_valid, "test_datetime_iso_valid")

			-- Time Tests
			io.put_string ("%NTime Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_time_24h_valid, "test_time_24h_valid")
			run_test (agent tests.test_time_24h_invalid, "test_time_24h_invalid")
			run_test (agent tests.test_time_12h_valid, "test_time_12h_valid")

			-- Financial Tests
			io.put_string ("%NFinancial Tests%N")
			io.put_string ("---------------%N")
			run_test (agent tests.test_credit_card_valid, "test_credit_card_valid")
			run_test (agent tests.test_currency_valid, "test_currency_valid")

			-- Identifier Tests
			io.put_string ("%NIdentifier Tests%N")
			io.put_string ("----------------%N")
			run_test (agent tests.test_uuid_valid, "test_uuid_valid")
			run_test (agent tests.test_uuid_invalid, "test_uuid_invalid")
			run_test (agent tests.test_hex_color_valid, "test_hex_color_valid")
			run_test (agent tests.test_hex_color_invalid, "test_hex_color_invalid")
			run_test (agent tests.test_username_valid, "test_username_valid")
			run_test (agent tests.test_username_invalid, "test_username_invalid")
			run_test (agent tests.test_slug_valid, "test_slug_valid")
			run_test (agent tests.test_slug_invalid, "test_slug_invalid")

			-- Security Tests
			io.put_string ("%NSecurity Tests%N")
			io.put_string ("--------------%N")
			run_test (agent tests.test_strong_password_valid, "test_strong_password_valid")
			run_test (agent tests.test_strong_password_invalid, "test_strong_password_invalid")
			run_test (agent tests.test_medium_password_valid, "test_medium_password_valid")

			-- US-Specific Tests
			io.put_string ("%NUS-Specific Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_zip_code_valid, "test_zip_code_valid")
			run_test (agent tests.test_ssn_valid, "test_ssn_valid")
			run_test (agent tests.test_ssn_invalid, "test_ssn_invalid")

			-- Number Tests
			io.put_string ("%NNumber Tests%N")
			io.put_string ("------------%N")
			run_test (agent tests.test_integer_valid, "test_integer_valid")
			run_test (agent tests.test_decimal_valid, "test_decimal_valid")
			run_test (agent tests.test_scientific_notation_valid, "test_scientific_notation_valid")
			run_test (agent tests.test_hex_number_valid, "test_hex_number_valid")

			-- Text Tests
			io.put_string ("%NText Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_alphanumeric_valid, "test_alphanumeric_valid")
			run_test (agent tests.test_alphanumeric_invalid, "test_alphanumeric_invalid")
			run_test (agent tests.test_alphabetic_valid, "test_alphabetic_valid")
			run_test (agent tests.test_whitespace_only, "test_whitespace_only")

			-- File Tests
			io.put_string ("%NFile Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_extract_extension, "test_extract_extension")
			run_test (agent tests.test_unix_path_valid, "test_unix_path_valid")
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
