note
	description: "Test suite for SIMPLE_REGEX_BUILDER"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_REGEX_BUILDER_TEST

inherit
	TEST_SET_BASE

feature -- Literal Tests

	test_literal_simple
			-- Test simple literal building
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("hello")
			regex := builder.to_regex
			assert ("compiled", regex.is_compiled)
			assert ("matches", regex.match ("hello world").is_matched)
		end

	test_literal_escapes_special_chars
			-- Test that literal escapes special characters
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.literal ("a.b*c?")
			assert ("escaped", builder.pattern.same_string ("a\.b\*c\?"))
		end

	test_raw_no_escaping
			-- Test raw adds without escaping
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.raw ("\d+")
			regex := builder.to_regex
			assert ("compiled", regex.is_compiled)
			assert ("matches", regex.match ("abc123").is_matched)
		end

feature -- Character Class Tests

	test_digit
			-- Test digit character class
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.digit.one_or_more
			assert ("pattern", builder.pattern.same_string ("\d+"))
			regex := builder.to_regex
			assert ("matches", regex.match ("abc123def").value.same_string ("123"))
		end

	test_word_char
			-- Test word character class
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.word_char.one_or_more
			regex := builder.to_regex
			assert ("matches", regex.match ("hello world").value.same_string ("hello"))
		end

	test_whitespace
			-- Test whitespace character class
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.whitespace.one_or_more
			regex := builder.to_regex
			assert ("matches", regex.match ("a   b").value.same_string ("   "))
		end

	test_one_of
			-- Test custom character class
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.one_of ("aeiou").one_or_more
			regex := builder.to_regex
			assert ("matches", regex.match ("hello").value.same_string ("e"))
		end

	test_none_of
			-- Test negated character class
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.none_of ("aeiou").one_or_more
			regex := builder.to_regex
			assert ("matches", regex.match ("hello").value.same_string ("h"))
		end

	test_range
			-- Test character range
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.range ('a', 'z').one_or_more
			regex := builder.to_regex
			assert ("matches", regex.match ("ABC123abc").value.same_string ("abc"))
		end

feature -- Quantifier Tests

	test_zero_or_more
			-- Test * quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.zero_or_more
			assert ("pattern", builder.pattern.same_string ("\d*"))
		end

	test_one_or_more
			-- Test + quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.one_or_more
			assert ("pattern", builder.pattern.same_string ("\d+"))
		end

	test_optional
			-- Test ? quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.optional
			assert ("pattern", builder.pattern.same_string ("\d?"))
		end

	test_exactly
			-- Test {n} quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.exactly (3)
			assert ("pattern", builder.pattern.same_string ("\d{3}"))
		end

	test_at_least
			-- Test {n,} quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.at_least (2)
			assert ("pattern", builder.pattern.same_string ("\d{2,}"))
		end

	test_between
			-- Test {n,m} quantifier
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.digit.between (2, 4)
			assert ("pattern", builder.pattern.same_string ("\d{2,4}"))
		end

	test_lazy_quantifiers
			-- Test lazy quantifier variants
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.any_char.zero_or_more_lazy
			assert ("lazy_star", builder.pattern.same_string (".*?"))

			builder := builder.reset.any_char.one_or_more_lazy
			assert ("lazy_plus", builder.pattern.same_string (".+?"))

			builder := builder.reset.any_char.optional_lazy
			assert ("lazy_question", builder.pattern.same_string (".??"))
		end

feature -- Group Tests

	test_capturing_group
			-- Test capturing group
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create builder.make
			builder := builder.group_start.word_char.one_or_more.group_end
			assert ("pattern", builder.pattern.same_string ("(\w+)"))
			regex := builder.to_regex
			match := regex.match ("hello world")
			assert ("matched", match.is_matched)
			assert ("group", attached match.group (1) as g and then g.same_string ("hello"))
		end

	test_non_capturing_group
			-- Test non-capturing group
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.non_capturing_start.literal ("foo").group_end
			assert ("pattern", builder.pattern.same_string ("(?:foo)"))
		end

	test_multiple_groups
			-- Test multiple capturing groups
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create builder.make
			builder := builder.group_start.word_char.one_or_more.group_end
			       .whitespace.one_or_more
			       .group_start.word_char.one_or_more.group_end
			regex := builder.to_regex
			match := regex.match ("hello world")
			assert ("group_count", match.group_count = 2)
			assert ("group1", attached match.group (1) as g and then g.same_string ("hello"))
			assert ("group2", attached match.group (2) as g and then g.same_string ("world"))
		end

	test_group_balancing
			-- Test group open/close tracking
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			assert ("initially_balanced", builder.open_group_count = 0)
			builder := builder.group_start
			assert ("one_open", builder.open_group_count = 1)
			builder := builder.group_start
			assert ("two_open", builder.open_group_count = 2)
			builder := builder.group_end
			assert ("one_open_again", builder.open_group_count = 1)
			builder := builder.group_end
			assert ("balanced", builder.open_group_count = 0)
		end

feature -- Anchor Tests

	test_start_of_string
			-- Test ^ anchor
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.start_of_string.literal ("hello")
			regex := builder.to_regex
			assert ("matches_start", regex.match ("hello world").is_matched)
			assert ("no_middle", not regex.match ("say hello").is_matched)
		end

	test_end_of_string
			-- Test $ anchor
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("world").end_of_string
			regex := builder.to_regex
			assert ("matches_end", regex.match ("hello world").is_matched)
			assert ("no_middle", not regex.match ("world hello").is_matched)
		end

	test_word_boundary
			-- Test \b anchor
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.word_boundary.literal ("cat").word_boundary
			regex := builder.to_regex
			assert ("matches_word", regex.match ("the cat sat").is_matched)
			assert ("no_part", not regex.match ("category").is_matched)
		end

feature -- Alternation Tests

	test_alternation
			-- Test | alternation
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("cat").alternate.literal ("dog")
			regex := builder.to_regex
			assert ("matches_cat", regex.match ("I have a cat").is_matched)
			assert ("matches_dog", regex.match ("I have a dog").is_matched)
			assert ("no_fish", not regex.match ("I have a fish").is_matched)
		end

feature -- Lookahead/Lookbehind Tests

	test_positive_lookahead
			-- Test positive lookahead (?=...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create builder.make
			builder := builder.literal ("foo").lookahead_positive_start.literal ("bar").group_end
			regex := builder.to_regex
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("foo"))
		end

	test_negative_lookahead
			-- Test negative lookahead (?!...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("foo").lookahead_negative_start.literal ("baz").group_end
			regex := builder.to_regex
			assert ("matches_bar", regex.match ("foobar").is_matched)
			assert ("no_baz", not regex.match ("foobaz").is_matched)
		end

	test_positive_lookbehind
			-- Test positive lookbehind (?<=...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
			match: SIMPLE_REGEX_MATCH
		do
			create builder.make
			builder := builder.lookbehind_positive_start.literal ("foo").group_end.literal ("bar")
			regex := builder.to_regex
			match := regex.match ("foobar")
			assert ("matched", match.is_matched)
			assert ("value", match.value.same_string ("bar"))
		end

	test_negative_lookbehind
			-- Test negative lookbehind (?<!...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.lookbehind_negative_start.literal ("foo").group_end.literal ("bar")
			regex := builder.to_regex
			assert ("matches", regex.match ("xxxbar").is_matched)
			assert ("no_foobar", not regex.match ("foobar").is_matched)
		end

feature -- Advanced Feature Tests

	test_atomic_group
			-- Test atomic group (?>...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.atomic_start.literal ("a").one_or_more.group_end
			assert ("pattern", builder.pattern.same_string ("(?>a+)"))
			regex := builder.to_regex
			assert ("compiled", regex.is_compiled)
		end

	test_backreference
			-- Test backreference \n
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.group_start.literal ("a").one_or_more.group_end.backreference (1)
			regex := builder.to_regex
			assert ("matches", regex.match ("aaaa").is_matched)
		end

	test_recursion
			-- Test recursion (?R)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("(").recurse.optional.literal (")")
			regex := builder.to_regex
			assert ("compiled", regex.is_compiled)
			assert ("matches", regex.match ("(())").is_matched)
		end

	test_conditional
			-- Test conditional (?(n)...|...)
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.group_start.literal ("a").group_end.optional
			       .conditional_start (1).literal ("b").conditional_else.literal ("c").group_end
			regex := builder.to_regex
			assert ("compiled", regex.is_compiled)
			assert ("with_a", regex.match ("ab").is_matched)
			assert ("without_a", regex.match ("c").is_matched)
		end

feature -- Special Character Tests

	test_special_chars
			-- Test special character escapes
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.newline.carriage_return.tab
			assert ("pattern", builder.pattern.same_string ("\n\r\t"))
		end

feature -- Fluent API Tests

	test_fluent_chaining
			-- Test that all methods return Current for chaining
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			regex := builder
				.start_of_string
				.group_start
					.literal ("hello")
				.group_end
				.whitespace.one_or_more
				.group_start
					.word_char.one_or_more
				.group_end
				.end_of_string
				.to_regex

			assert ("compiled", regex.is_compiled)
			assert ("matches", regex.match ("hello world").is_matched)
		end

	test_reset
			-- Test reset clears builder state
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.literal ("test").group_start.digit
			assert ("has_content", not builder.pattern.is_empty)
			assert ("has_open_group", builder.open_group_count > 0)

			builder := builder.reset
			assert ("empty_after_reset", builder.pattern.is_empty)
			assert ("groups_cleared", builder.open_group_count = 0)
		end

feature -- Options Tests

	test_to_regex_with_options
			-- Test creating regex with options
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("hello")
			regex := builder.to_regex_with_options (True, False, False)
			assert ("case_insensitive", regex.is_caseless)
			assert ("matches_upper", regex.match ("HELLO").is_matched)
		end

feature -- Any Character Tests

	test_any_char
			-- Test . any character
		local
			builder: SIMPLE_REGEX_BUILDER
			regex: SIMPLE_REGEX
		do
			create builder.make
			builder := builder.literal ("a").any_char.literal ("c")
			regex := builder.to_regex
			assert ("matches_abc", regex.match ("abc").is_matched)
			assert ("matches_aXc", regex.match ("aXc").is_matched)
		end

feature -- Unicode Tests

	test_unicode_property
			-- Test Unicode property \p{...}
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.unicode_property ("L").one_or_more
			assert ("pattern", builder.pattern.same_string ("\p{L}+"))
		end

	test_grapheme
			-- Test Unicode grapheme \X
		local
			builder: SIMPLE_REGEX_BUILDER
		do
			create builder.make
			builder := builder.grapheme.one_or_more
			assert ("pattern", builder.pattern.same_string ("\X+"))
		end

end
