note
	description: "Test suite for SIMPLE_REGEX"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_REGEX_TEST

inherit
	TEST_SET_BASE

feature -- Basic Match Tests

	test_basic_match
			-- Test basic pattern matching
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("hello")
			assert ("compiled", regex.is_compiled)

			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("hello"))
			assert ("start", match.start_position = 1)
			assert ("end", match.end_position = 5)
		end

	test_no_match
			-- Test when pattern doesn't match
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("xyz")
			match := regex.match ("hello world")
			assert ("not_matched", not match.is_matched)
		end

	test_match_in_middle
			-- Test matching in middle of string
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("world")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("start", match.start_position = 7)
			assert ("end", match.end_position = 11)
		end

	test_empty_pattern
			-- Test empty pattern
		local
			regex: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("")
			-- Empty pattern should compile (matches empty string)
			-- Behavior depends on Gobo
		end

feature -- Character Class Tests

	test_digit_class
			-- Test \d character class
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("\d+")
			match := regex.match ("abc123def")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("123"))
		end

	test_word_class
			-- Test \w character class
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("\w+")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("hello"))
		end

	test_whitespace_class
			-- Test \s character class
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("\s+")
			match := regex.match ("hello   world")
			assert ("matched", match.is_matched)
			assert ("length", match.length = 3)
		end

	test_custom_class
			-- Test custom character class [abc]
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("[aeiou]+")
			match := regex.match ("hello")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("e"))
		end

feature -- Capturing Group Tests

	test_single_group
			-- Test single capturing group
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("(hello)")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("group_count", match.group_count = 1)
			assert ("group_0", attached match.group (0) as g and then g.same_string ("hello"))
			assert ("group_1", attached match.group (1) as g and then g.same_string ("hello"))
		end

	test_multiple_groups
			-- Test multiple capturing groups
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("(\w+)\s+(\w+)")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("group_count", match.group_count = 2)
			assert ("group_1", attached match.group (1) as g and then g.same_string ("hello"))
			assert ("group_2", attached match.group (2) as g and then g.same_string ("world"))
		end

	test_nested_groups
			-- Test nested capturing groups
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("((a+)(b+))")
			match := regex.match ("aaabbb")
			assert ("matched", match.is_matched)
			assert ("group_count", match.group_count = 3)
			assert ("group_1", attached match.group (1) as g and then g.same_string ("aaabbb"))
			assert ("group_2", attached match.group (2) as g and then g.same_string ("aaa"))
			assert ("group_3", attached match.group (3) as g and then g.same_string ("bbb"))
		end

	test_non_capturing_group
			-- Test non-capturing group (?:...)
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("(?:foo)(bar)")
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			assert ("group_count", match.group_count = 1)
			assert ("group_1", attached match.group (1) as g and then g.same_string ("bar"))
		end

feature -- Match All Tests

	test_match_all_basic
			-- Test finding all matches
		local
			regex: SIMPLE_REGEX
			matches: SIMPLE_REGEX_MATCH_LIST
		do
			create regex.make_from_pattern ("\d+")
			matches := regex.match_all ("a1b22c333d")
			assert ("has_matches", matches.has_matches)
			assert ("count", matches.count = 3)
			assert ("first", matches.first.value.same_string ("1"))
			assert ("last", matches.last.value.same_string ("333"))
		end

	test_match_all_no_matches
			-- Test match_all with no matches
		local
			regex: SIMPLE_REGEX
			matches: SIMPLE_REGEX_MATCH_LIST
		do
			create regex.make_from_pattern ("\d+")
			matches := regex.match_all ("no digits here")
			assert ("no_matches", matches.is_empty)
		end

	test_match_all_as_strings
			-- Test as_strings conversion
		local
			regex: SIMPLE_REGEX
			matches: SIMPLE_REGEX_MATCH_LIST
			strings: ARRAYED_LIST [STRING_32]
		do
			create regex.make_from_pattern ("\w+")
			matches := regex.match_all ("one two three")
			strings := matches.as_strings
			assert ("count", strings.count = 3)
			assert ("first", strings [1].same_string ("one"))
			assert ("second", strings [2].same_string ("two"))
			assert ("third", strings [3].same_string ("three"))
		end

feature -- Replace Tests

	test_replace_first
			-- Test replacing first match
		local
			regex: SIMPLE_REGEX
			l_result: STRING_32
		do
			create regex.make_from_pattern ("world")
			l_result := regex.replace ("hello world world", "universe")
			assert ("replaced", l_result.same_string ("hello universe world"))
		end

	test_replace_all
			-- Test replacing all matches
		local
			regex: SIMPLE_REGEX
			l_result: STRING_32
		do
			create regex.make_from_pattern ("a")
			l_result := regex.replace_all ("banana", "X")
			assert ("replaced", l_result.same_string ("bXnXnX"))
		end

	test_replace_with_groups
			-- Test replacement with group references
		local
			regex: SIMPLE_REGEX
			l_result: STRING_32
		do
			create regex.make_from_pattern ("(\w+)\s+(\w+)")
			l_result := regex.replace ("hello world", "\2\ \1\")
			assert ("swapped", l_result.same_string ("world hello"))
		end

	test_replace_no_match
			-- Test replace when no match
		local
			regex: SIMPLE_REGEX
			l_result: STRING_32
		do
			create regex.make_from_pattern ("xyz")
			l_result := regex.replace ("hello world", "replaced")
			assert ("unchanged", l_result.same_string ("hello world"))
		end

feature -- Split Tests

	test_split_basic
			-- Test basic splitting
		local
			regex: SIMPLE_REGEX
			parts: ARRAYED_LIST [STRING_32]
		do
			create regex.make_from_pattern (",\s*")
			parts := regex.split ("a, b, c")
			assert ("count", parts.count = 3)
			assert ("first", parts [1].same_string ("a"))
			assert ("second", parts [2].same_string ("b"))
			assert ("third", parts [3].same_string ("c"))
		end

	test_split_no_match
			-- Test split when pattern doesn't match
		local
			regex: SIMPLE_REGEX
			parts: ARRAYED_LIST [STRING_32]
		do
			create regex.make_from_pattern (",")
			parts := regex.split ("no commas here")
			assert ("one_part", parts.count = 1)
			assert ("original", parts [1].same_string ("no commas here"))
		end

feature -- Options Tests

	test_case_insensitive
			-- Test case-insensitive matching
		local
			regex, regex_ci: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			-- Without case insensitive
			create regex.make_from_pattern ("hello")
			match := regex.match ("HELLO")
			assert ("not_matched_case_sensitive", not match.is_matched)

			-- With case insensitive
			regex_ci := regex.case_insensitive
			match := regex_ci.match ("HELLO")
			assert ("matched_case_insensitive", match.is_matched)
		end

	test_multiline
			-- Test multiline mode
		local
			regex, regex_ml: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("^line")
			regex_ml := regex.multiline
			match := regex_ml.match ("first%Nline two")
			assert ("matched_multiline", match.is_matched)
		end

	test_dotall
			-- Test dotall mode
		local
			regex, regex_ds: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("a.b")
			regex_ds := regex.dotall
			match := regex_ds.match ("a%Nb")
			assert ("matched_dotall", match.is_matched)
		end

	test_option_immutability
			-- Test that options return new instance
		local
			regex, regex_ci: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("test")
			regex_ci := regex.case_insensitive
			assert ("different_objects", regex /= regex_ci)
			assert ("original_unchanged", not regex.is_caseless)
			assert ("new_has_option", regex_ci.is_caseless)
		end

feature -- Convenience Method Tests

	test_matches_pattern
			-- Test convenience matches method
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("matches", regex.matches_pattern ("\d+", "abc123"))
			assert ("no_match", not regex.matches_pattern ("\d+", "no digits"))
		end

	test_first_match_for
			-- Test convenience first_match method
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("found", attached regex.first_match_for ("\d+", "a1b2c3") as m and then m.same_string ("1"))
			assert ("not_found", regex.first_match_for ("\d+", "no digits") = Void)
		end

	test_all_matches_for
			-- Test convenience all_matches method
		local
			regex: SIMPLE_REGEX
			matches: ARRAYED_LIST [STRING_32]
		do
			create regex.make
			matches := regex.all_matches_for ("\d+", "a1b22c333")
			assert ("count", matches.count = 3)
		end

	test_replace_first_match
			-- Test convenience replace_first method
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("replaced", regex.replace_first_match ("world", "hello world", "universe").same_string ("hello universe"))
		end

	test_replace_all_matches
			-- Test convenience replace_all method
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("replaced", regex.replace_all_matches ("a", "banana", "X").same_string ("bXnXnX"))
		end

	test_split_by_pattern
			-- Test convenience split method
		local
			regex: SIMPLE_REGEX
			parts: ARRAYED_LIST [STRING_32]
		do
			create regex.make
			parts := regex.split_by_pattern (",", "a,b,c")
			assert ("count", parts.count = 3)
		end

feature -- Match Context Tests

	test_text_before
			-- Test text_before accessor
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("world")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("before", match.text_before.same_string ("hello "))
		end

	test_text_after
			-- Test text_after accessor
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("hello")
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("after", match.text_after.same_string (" world"))
		end

feature -- Safety Tests

	test_escape
			-- Test escaping special characters
		local
			regex: SIMPLE_REGEX
			escaped: STRING_32
		do
			create regex.make
			escaped := regex.escape ("a.b*c?")
			assert ("escaped", escaped.same_string ("a\.b\*c\?"))
		end

	test_pattern_complexity_simple
			-- Test complexity scoring for simple pattern
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("low_complexity", regex.pattern_complexity ("hello") <= 3)
		end

	test_pattern_complexity_dangerous
			-- Test complexity scoring for dangerous pattern
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("high_complexity", regex.pattern_complexity ("(a+)+") >= 4)
		end

	test_is_potentially_dangerous
			-- Test dangerous pattern detection
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("safe", not regex.is_potentially_dangerous ("hello"))
			-- Note: Actual dangerous pattern detection is heuristic
		end

feature -- Error Handling Tests

	test_invalid_pattern
			-- Test error handling for invalid pattern
		local
			regex: SIMPLE_REGEX
		do
			create regex.make_from_pattern ("(unclosed")
			assert ("not_compiled", not regex.is_compiled)
			assert ("has_error", not regex.last_error.is_empty)
		end

	test_is_valid_pattern
			-- Test pattern validation
		local
			regex: SIMPLE_REGEX
		do
			create regex.make
			assert ("valid", regex.is_valid_pattern ("hello"))
			assert ("invalid", not regex.is_valid_pattern ("(unclosed"))
		end

feature -- Advanced Feature Tests (Verified by Gobo capability tests)

	test_lookahead_positive
			-- Test positive lookahead
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("foo(?=bar)")
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("foo"))
		end

	test_lookahead_negative
			-- Test negative lookahead
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("foo(?!baz)")
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			match := regex.match ("foobaz")
			assert ("not_matched", not match.is_matched)
		end

	test_lookbehind_positive
			-- Test positive lookbehind
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("(?<=foo)bar")
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("bar"))
		end

	test_backreference
			-- Test backreference
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("(a+)\1")
			match := regex.match ("aaaa")
			assert ("matched", match.is_matched)
		end

	test_unicode_property
			-- Test Unicode property
		local
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create regex.make_from_pattern ("\p{L}+")
			match := regex.match ("Hello123")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("Hello"))
		end

end
