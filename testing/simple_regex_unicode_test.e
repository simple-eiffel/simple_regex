note
	description: "[
		Vector tests for general-string (non-8-bit) subjects.

		Regression cover for the 2026-09-02 defect in which `split' and
		`split_by_pattern' forwarded a STRING_32 subject to Gobo's
		`RX_REGULAR_EXPRESSION.split', whose `subject_is_string'
		precondition demands an 8-bit STRING. The public signature of
		SIMPLE_REGEX accepts READABLE_STRING_GENERAL, so a STRING_32
		subject raised a precondition violation inside the library.

		These tests drive the same STRING_32 subject - Hebrew, an
		astral-plane emoji and Greek - through both `split' and
		`match_all' and require the two to agree.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	SIMPLE_REGEX_UNICODE_TEST

inherit
	TEST_SET_BASE

feature -- Split Vector Tests

	test_split_unicode_subject
			-- `split' accepts a STRING_32 subject carrying Hebrew,
			-- an astral-plane emoji and Greek, and returns the pieces.
		local
			l_regex: SIMPLE_REGEX
			l_subject: STRING_32
			l_parts: ARRAYED_LIST [STRING_32]
		do
			l_subject := unicode_subject
			assert ("subject_is_wide", l_subject.count = 14)

			create l_regex.make_from_pattern (",")
			l_parts := l_regex.split (l_subject)

			assert ("three_parts", l_parts.count = 3)
			assert ("hebrew", l_parts [1].same_string (hebrew_shalom))
			assert ("emoji", l_parts [2].same_string (robot_emoji))
			assert ("greek", l_parts [3].same_string (greek_christos))
		end

	test_match_all_unicode_subject
			-- `match_all' accepts the same STRING_32 subject and
			-- yields the same pieces `split' does.
		local
			l_regex: SIMPLE_REGEX
			l_subject: STRING_32
			l_matches: SIMPLE_REGEX_MATCH_LIST
		do
			l_subject := unicode_subject

			create l_regex.make_from_pattern ("[^,]+")
			l_matches := l_regex.match_all (l_subject)

			assert ("three_matches", l_matches.count = 3)
			assert ("hebrew", l_matches.item (1).value.same_string (hebrew_shalom))
			assert ("emoji", l_matches.item (2).value.same_string (robot_emoji))
			assert ("greek", l_matches.item (3).value.same_string (greek_christos))
		end

	test_split_agrees_with_match_all_on_unicode_subject
			-- `split' and `match_all' agree piece for piece on the
			-- same STRING_32 subject.
		local
			l_splitter: SIMPLE_REGEX
			l_matcher: SIMPLE_REGEX
			l_subject: STRING_32
			l_parts: ARRAYED_LIST [STRING_32]
			l_matches: SIMPLE_REGEX_MATCH_LIST
			i: INTEGER
		do
			l_subject := unicode_subject

			create l_splitter.make_from_pattern (",")
			l_parts := l_splitter.split (l_subject)

			create l_matcher.make_from_pattern ("[^,]+")
			l_matches := l_matcher.match_all (l_subject)

			assert ("same_piece_count", l_parts.count = l_matches.count)
			from i := 1 until i > l_parts.count loop
				assert ("piece_" + i.out, l_parts [i].same_string (l_matches.item (i).value))
				i := i + 1
			end
		end

	test_split_unicode_positions_refer_to_caller_string
			-- Match positions reported for a STRING_32 subject index
			-- the caller's own string, code point for code point.
		local
			l_regex: SIMPLE_REGEX
			l_subject: STRING_32
			l_match: SIMPLE_REGEX_MATCH
		do
			l_subject := unicode_subject

			create l_regex.make_from_pattern (greek_christos)
			l_match := l_regex.match (l_subject)

			assert ("matched", l_match.is_matched)
			assert ("start", l_match.start_position = 8)
			assert ("end", l_match.end_position = 14)
			assert ("slice", l_subject.substring (l_match.start_position, l_match.end_position).same_string (greek_christos))
		end

	test_split_by_pattern_unicode_subject
			-- The cached class-method sibling `split_by_pattern'
			-- accepts a STRING_32 subject too.
		local
			l_regex: SIMPLE_REGEX
			l_parts: ARRAYED_LIST [STRING_32]
		do
			create l_regex.make
			l_parts := l_regex.split_by_pattern (",", unicode_subject)

			assert ("three_parts", l_parts.count = 3)
			assert ("hebrew", l_parts [1].same_string (hebrew_shalom))
			assert ("emoji", l_parts [2].same_string (robot_emoji))
			assert ("greek", l_parts [3].same_string (greek_christos))
		end

	test_split_ascii_string_32_subject
			-- A plain ASCII subject whose dynamic type is STRING_32
			-- splits exactly as the STRING_8 spelling of it does.
		local
			l_regex: SIMPLE_REGEX
			l_wide: STRING_32
			l_wide_parts: ARRAYED_LIST [STRING_32]
			l_narrow_parts: ARRAYED_LIST [STRING_32]
		do
			create l_wide.make_from_string ({STRING_32} "alpha,beta,gamma")
			create l_regex.make_from_pattern (",")

			l_wide_parts := l_regex.split (l_wide)
			assert ("three_parts", l_wide_parts.count = 3)
			assert ("alpha", l_wide_parts [1].same_string ("alpha"))
			assert ("beta", l_wide_parts [2].same_string ("beta"))
			assert ("gamma", l_wide_parts [3].same_string ("gamma"))

			l_narrow_parts := l_regex.split ("alpha,beta,gamma")
			assert ("narrow_agrees_count", l_narrow_parts.count = l_wide_parts.count)
			assert ("narrow_agrees_1", l_narrow_parts [1].same_string (l_wide_parts [1]))
			assert ("narrow_agrees_2", l_narrow_parts [2].same_string (l_wide_parts [2]))
			assert ("narrow_agrees_3", l_narrow_parts [3].same_string (l_wide_parts [3]))
		end

	test_split_unicode_no_match_returns_subject
			-- A STRING_32 subject with no separator comes back whole.
		local
			l_regex: SIMPLE_REGEX
			l_parts: ARRAYED_LIST [STRING_32]
		do
			create l_regex.make_from_pattern (";")
			l_parts := l_regex.split (unicode_subject)

			assert ("one_part", l_parts.count = 1)
			assert ("whole_subject", l_parts [1].same_string (unicode_subject))
		end

feature {NONE} -- Vector Data

	unicode_subject: STRING_32
			-- "shalom,<robot>,Christos" as a STRING_32:
			-- Hebrew (BMP), an astral-plane emoji (above U+FFFF), Greek (BMP).
			-- 4 + 1 + 1 + 1 + 7 = 14 code points.
		do
			create Result.make (14)
			Result.append (hebrew_shalom)
			Result.append_character (',')
			Result.append (robot_emoji)
			Result.append_character (',')
			Result.append (greek_christos)
		ensure
			result_attached: Result /= Void
		end

	hebrew_shalom: STRING_32
			-- Hebrew shalom, U+05E9 U+05DC U+05D5 U+05DD.
		do
			Result := code_string (<<1513, 1500, 1493, 1501>>)
		ensure
			four_code_points: Result.count = 4
		end

	robot_emoji: STRING_32
			-- Robot face, U+1F916 - a single astral-plane code point.
		do
			Result := code_string (<<129302>>)
		ensure
			one_code_point: Result.count = 1
		end

	greek_christos: STRING_32
			-- Greek Christos, U+03A7 U+03C1 U+03B9 U+03C3 U+03C4 U+03CC U+03C2.
		do
			Result := code_string (<<935, 961, 953, 963, 964, 972, 962>>)
		ensure
			seven_code_points: Result.count = 7
		end

	code_string (a_codes: ARRAY [INTEGER]): STRING_32
			-- STRING_32 holding the Unicode code points `a_codes'.
		require
			codes_attached: a_codes /= Void
		do
			create Result.make (a_codes.count)
			across a_codes as ic_c loop
				Result.append_code (ic_c.item.to_natural_32)
			end
		ensure
			same_count: Result.count = a_codes.count
		end

end
