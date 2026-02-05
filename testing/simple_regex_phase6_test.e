note
	description: "Phase 6 Adversarial tests for SIMPLE_REGEX hardening"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	SIMPLE_REGEX_PHASE6_TEST

inherit
	TEST_SET_BASE

feature -- Boundary Value Tests

	test_empty_pattern
			-- Empty pattern should handle gracefully
		local
			regex: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("")
			assert_true ("no_crash", True)
		end

	test_empty_subject
			-- Match against empty subject
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("a")
			match := regex.match ("")
			assert_false ("no_match_empty", match.is_matched)
		end

	test_single_character_match
			-- Match single character
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("a")
			match := regex.match ("a")
			assert_true ("single_matches", match.is_matched)
		end

feature -- ReDoS Detection Tests

	test_nested_quantifiers_complexity
			-- Test nested quantifiers detection
		local
			regex: SIMPLE_REGEX
			complexity: INTEGER
		do
			create regex.make
			complexity := regex.pattern_complexity ("(a+)+")
			assert_true ("nested_detects", complexity > 5)
		end

	test_dangerous_pattern
			-- Patterns with high ReDoS risk
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert_true ("nested_quantifiers_dangerous",
				regex.is_potentially_dangerous ("(a+)+b"))
		end

	test_complexity_range
			-- Complexity score must stay in valid range
		local
			regex: SIMPLE_REGEX
			score: INTEGER
		do
			create regex.make
			score := regex.pattern_complexity (".*")
			assert_true ("score_min", score >= 1)
			assert_true ("score_max", score <= 10)

			score := regex.pattern_complexity ("(a+)+|b|c|d|e|f|g|h|i|j|\\1+")
			assert_true ("complex_score_min", score >= 1)
			assert_true ("complex_score_max", score <= 10)
		end

feature -- Text Position Tests

	test_match_at_start
			-- Match at position 1
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("hello")
			match := regex.match ("hello world")
			assert_integers_equal ("start_pos_one", 1, match.start_position)
		end

	test_match_at_end
			-- Match at end of string
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("world")
			match := regex.match ("hello world")
			assert_integers_equal ("end_pos", 11, match.end_position)
		end

	test_all_matches_with_details_empty
			-- No matches returns empty list
		local
			regex: SIMPLE_REGEX
			matches: ARRAYED_LIST [TUPLE [value: STRING_32; start_position: INTEGER;
										  end_position: INTEGER; length: INTEGER;
										  text_before: STRING_32; text_after: STRING_32]]
		do
			create regex.make_from_pattern ("xyz")
			matches := regex.all_matches_with_details ("xyz", "abc")
			assert_integers_equal ("empty_result", 0, matches.count)
		end

	test_all_matches_with_details_single_start
			-- Single match at start
		local
			regex: SIMPLE_REGEX
			matches: ARRAYED_LIST [TUPLE [value: STRING_32; start_position: INTEGER;
										  end_position: INTEGER; length: INTEGER;
										  text_before: STRING_32; text_after: STRING_32]]
		do
			create regex.make_from_pattern ("a+")
			matches := regex.all_matches_with_details ("a+", "aaa")
			assert_integers_equal ("match_count", 1, matches.count)
			assert_integers_equal ("start_at_1", 1, matches [1].start_position)
			assert_strings_equal ("text_before_empty", "", matches [1].text_before)
		end

	test_all_matches_with_details_adjacent
			-- Adjacent matches (no text between)
		local
			regex: SIMPLE_REGEX
			matches: ARRAYED_LIST [TUPLE [value: STRING_32; start_position: INTEGER;
										  end_position: INTEGER; length: INTEGER;
										  text_before: STRING_32; text_after: STRING_32]]
		do
			create regex.make_from_pattern ("a")
			matches := regex.all_matches_with_details ("a", "aaa")
			assert_integers_equal ("three_matches", 3, matches.count)
			assert_strings_equal ("second_text_before", "a", matches [2].text_before)
			assert_strings_equal ("third_text_before", "aa", matches [3].text_before)
		end

feature -- Replacement Tests

	test_replace_no_match
			-- Replace when pattern doesn't match
		local
			regex: SIMPLE_REGEX
			result_str: STRING_32
		do
			create regex.make_from_pattern ("xyz")
			result_str := regex.replace ("hello", "world")
			assert_strings_equal ("no_match_unchanged", "hello", result_str)
		end

	test_replace_all_no_match
			-- Replace all when nothing matches
		local
			regex: SIMPLE_REGEX
			result_str: STRING_32
		do
			create regex.make_from_pattern ("xyz")
			result_str := regex.replace_all ("hello", "world")
			assert_strings_equal ("no_change", "hello", result_str)
		end

	test_replace_all_everything
			-- Replace pattern that matches everything
		local
			regex: SIMPLE_REGEX
			result_str: STRING_32
		do
			create regex.make_from_pattern (".")
			result_str := regex.replace_all ("ab", "X")
			assert_strings_equal ("all_replaced", "XX", result_str)
		end

feature -- Options Immutability Tests

	test_case_insensitive_new_object
			-- case_insensitive should return new object
		local
			regex1, regex2: SIMPLE_REGEX
		do
			create regex1.make_from_pattern ("test")
			regex2 := regex1.case_insensitive
			assert_false ("different_objects", regex1 = regex2)
			assert_true ("new_is_caseless", regex2.is_caseless)
			assert_false ("old_unchanged", regex1.is_caseless)
		end

	test_multiline_new_object
			-- multiline should return new object
		local
			regex1, regex2: SIMPLE_REGEX
		do
			create regex1.make_from_pattern ("test")
			regex2 := regex1.multiline
			assert_false ("different_objects", regex1 = regex2)
			assert_true ("new_is_multiline", regex2.is_multiline)
			assert_false ("old_unchanged", regex1.is_multiline)
		end

	test_chained_options
			-- Options can be chained
		local
			regex: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("test")
			regex := regex.case_insensitive.multiline.dotall
			assert_true ("caseless_set", regex.is_caseless)
			assert_true ("multiline_set", regex.is_multiline)
			assert_true ("dotall_set", regex.is_dotall)
		end

feature -- Compilation State Tests

	test_not_compiled_after_make
			-- Default creation should not be compiled
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert_false ("not_compiled_after_make", regex.is_compiled)
		end

	test_error_message_empty_on_success
			-- Successful compile clears error
		local
			regex: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("test")
			assert_true ("compiled", regex.is_compiled)
			assert_true ("error_empty", regex.last_error.is_empty)
		end

feature -- Convenience Method Tests

	test_contains_pattern_true
			-- Test convenience method with match
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert_true ("contains",
				regex.contains_pattern ("hello", "hello world"))
		end

	test_contains_pattern_false
			-- Test convenience method without match
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert_false ("not_contains",
				regex.contains_pattern ("xyz", "hello world"))
		end

	test_first_match_for_value
			-- Test first_match_for convenience method
		local
			regex: SIMPLE_REGEX
			value: detachable STRING_32
		do
			create regex.make
			value := regex.first_match_for ("world", "hello world")
			assert_true ("attached", attached value)
			if attached value then
				assert_strings_equal ("correct_value", "world", value)
			end
		end

	test_first_match_for_void
			-- Test first_match_for with no match
		local
			regex: SIMPLE_REGEX
			value: detachable STRING_32
		do
			create regex.make
			value := regex.first_match_for ("xyz", "hello")
			assert_false ("void_result", attached value)
		end

	test_all_matches_for_convenience
			-- Test all_matches_for convenience method
		local
			regex: SIMPLE_REGEX
			matches: ARRAYED_LIST [STRING_32]
		do
			create regex.make
			matches := regex.all_matches_for ("\d", "a1b2c3")
			assert_integers_equal ("three_digits", 3, matches.count)
		end

end
