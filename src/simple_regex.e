note
	description: "[
		High-level regex API for Eiffel wrapping Gobo's PCRE implementation.

		Provides:
		- Convenience class methods with internal pattern caching
		- Instance methods for compiled pattern reuse
		- Fluent options (case_insensitive, multiline, dotall)
		- Rich match results with group access

		Gobo Capabilities (Empirically Verified):
		- Basic matching, character classes (\d, \w, \s)
		- Capturing groups, non-capturing groups (?:...)
		- Lookahead (?=...), (?!...) and lookbehind (?<=...), (?<!...)
		- Atomic groups (?>...), recursion (?R), conditionals (?(n)...|...)
		- Backreferences \1, Unicode properties \p{L}, graphemes \X

		Not Supported by Gobo:
		- Named groups (?P<name>...) - use indexed access instead
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX

inherit
	ANY
		redefine
			default_create
		end

create
	default_create,
	make,
	make_from_pattern

feature {NONE} -- Initialization

	default_create
			-- Create without pattern
		do
			create last_error.make_empty
			is_caseless := False
			is_multiline := False
			is_dotall := False
		end

	make
			-- Create without pattern (alias for default_create)
		do
			default_create
		end

	make_from_pattern (a_pattern: READABLE_STRING_GENERAL)
			-- Create and compile pattern
		do
			default_create
			compile (a_pattern)
		ensure
			pattern_set: attached pattern as p and then p.same_string_general (a_pattern)
		end

feature -- Compilation

	compile,
	set_pattern,
	load_pattern (a_pattern: READABLE_STRING_GENERAL)
			-- Compile pattern for matching
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			pattern := a_pattern.to_string_32
			create l_regex.make
			apply_options (l_regex)
			l_regex.compile (a_pattern)

			if l_regex.is_compiled then
				internal_regex := l_regex
				last_error := {STRING_32} ""
			else
				internal_regex := Void
				last_error := l_regex.error_message.to_string_32
			end
		ensure
			compiled_xor_error: is_compiled xor (not last_error.is_empty)
			pattern_stored: attached pattern as p and then p.same_string_general (a_pattern)
		end

	is_compiled: BOOLEAN
			-- Has pattern been successfully compiled?
		do
			Result := internal_regex /= Void
		end

	last_error: STRING_32
			-- Last compilation error message (empty if none)

	pattern: detachable STRING_32
			-- Current pattern (if any)

feature -- Pattern Validation

	is_valid_pattern (a_pattern: READABLE_STRING_GENERAL): BOOLEAN
			-- Is pattern syntactically valid?
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create l_regex.make
			l_regex.compile (a_pattern)
			Result := l_regex.is_compiled
		end

feature -- Matching

	match,
	find,
	search,
	find_first (a_subject: READABLE_STRING_GENERAL): SIMPLE_REGEX_MATCH
			-- Match subject against compiled pattern
		require
			compiled: is_compiled
		do
			check attached internal_regex as l_regex then
				l_regex.match (a_subject)
				Result := create_match_result (l_regex, a_subject)
			end
		ensure
			result_attached: Result /= Void
		end

	match_all,
	find_all,
	search_all,
	matches (a_subject: READABLE_STRING_GENERAL): SIMPLE_REGEX_MATCH_LIST
			-- Find all matches in subject
		require
			compiled: is_compiled
		local
			l_match: SIMPLE_REGEX_MATCH
		do
			create Result.make (a_subject)
			check attached internal_regex as l_regex then
				l_regex.match (a_subject)
				from
				until
					not l_regex.has_matched
				loop
					l_match := create_match_result (l_regex, a_subject)
					Result.extend (l_match)
					l_regex.next_match
				end
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Replacement

	replace,
	substitute,
	sub (a_subject, a_replacement: READABLE_STRING_GENERAL): STRING_32
			-- Replace first match in subject
			-- Use \n\ for group references (e.g., \1\, \2\)
		require
			compiled: is_compiled
		do
			check attached internal_regex as l_regex then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					Result := l_regex.unicode_replace (a_replacement)
				else
					Result := a_subject.to_string_32
				end
			end
		ensure
			result_attached: Result /= Void
		end

	replace_all,
	substitute_all,
	gsub (a_subject, a_replacement: READABLE_STRING_GENERAL): STRING_32
			-- Replace all matches in subject
			-- Use \n\ for group references (e.g., \1\, \2\)
		require
			compiled: is_compiled
		do
			check attached internal_regex as l_regex then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					Result := l_regex.unicode_replace_all (a_replacement)
				else
					Result := a_subject.to_string_32
				end
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Splitting

	split,
	tokenize,
	divide (a_subject: READABLE_STRING_GENERAL): ARRAYED_LIST [STRING_32]
			-- Split subject by pattern
		require
			compiled: is_compiled
		local
			l_parts: ARRAY [STRING]
		do
			check attached internal_regex as l_regex then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					l_parts := l_regex.split
					create Result.make (l_parts.count)
					across l_parts as ic_p loop
						Result.extend (ic_p.item.to_string_32)
					end
				else
					create Result.make (1)
					Result.extend (a_subject.to_string_32)
				end
			end
		ensure
			result_attached: Result /= Void
			at_least_one: Result.count >= 1
		end

feature -- Options (Return new instance for immutability)

	case_insensitive: SIMPLE_REGEX
			-- New regex with case-insensitive matching
		do
			Result := twin_with_options (True, is_multiline, is_dotall)
		ensure
			result_attached: Result /= Void
			new_object: Result /= Current
			caseless_set: Result.is_caseless
		end

	multiline: SIMPLE_REGEX
			-- New regex with multiline mode (^ and $ match line boundaries)
		do
			Result := twin_with_options (is_caseless, True, is_dotall)
		ensure
			result_attached: Result /= Void
			new_object: Result /= Current
			multiline_set: Result.is_multiline
		end

	dotall: SIMPLE_REGEX
			-- New regex with dotall mode (. matches newlines)
		do
			Result := twin_with_options (is_caseless, is_multiline, True)
		ensure
			result_attached: Result /= Void
			new_object: Result /= Current
			dotall_set: Result.is_dotall
		end

feature -- Option Queries

	is_caseless: BOOLEAN
			-- Is case-insensitive matching enabled?

	is_multiline: BOOLEAN
			-- Is multiline mode enabled?

	is_dotall: BOOLEAN
			-- Is dotall mode enabled?

feature -- Convenience Class Methods (with caching)

	matches_pattern,
	test,
	is_match,
	contains_pattern (a_pattern, a_subject: READABLE_STRING_GENERAL): BOOLEAN
			-- Does subject contain a match for pattern?
			-- Pattern is cached after first compilation
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				Result := l_regex.has_matched
			end
		end

	first_match_for (a_pattern, a_subject: READABLE_STRING_GENERAL): detachable STRING_32
			-- First matching substring, or Void if no match
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					Result := l_regex.unicode_captured_substring (0)
				end
			end
		end

	all_matches_for (a_pattern, a_subject: READABLE_STRING_GENERAL): ARRAYED_LIST [STRING_32]
			-- All matching substrings
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create Result.make (10)
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				from
				until
					not l_regex.has_matched
				loop
					Result.extend (l_regex.unicode_captured_substring (0))
					l_regex.next_match
				end
			end
		ensure
			result_attached: Result /= Void
		end

	all_matches_with_details (a_pattern, a_subject: READABLE_STRING_GENERAL):
		ARRAYED_LIST [TUPLE [value: STRING_32; start_position: INTEGER;
							 end_position: INTEGER; length: INTEGER;
							 text_before: STRING_32; text_after: STRING_32]]
			-- All matching substrings with position and context information
			-- Each tuple contains: matched value, start/end positions, length,
			-- and the subject text before and after the match.
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
			l_start: INTEGER
			l_end: INTEGER
			l_text_before: STRING_32
			l_text_after: STRING_32
			l_length: INTEGER
			l_subject_32: STRING_32
		do
			create Result.make (10)
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_subject_32 := a_subject.to_string_32
				l_regex.match (a_subject)
				from
				until
					not l_regex.has_matched
				loop
					l_start := l_regex.captured_start_position (0)
					l_end := l_regex.captured_end_position (0)
					l_length := (l_end - l_start + 1).max (0)

					-- Text before match
					if l_start > 1 then
						l_text_before := l_subject_32.substring (1, l_start - 1)
					else
						create l_text_before.make_empty
					end

					-- Text after match
					if l_end < l_subject_32.count then
						l_text_after := l_subject_32.substring (l_end + 1, l_subject_32.count)
					else
						create l_text_after.make_empty
					end

					Result.extend ([
						l_regex.unicode_captured_substring (0),
						l_start,
						l_end,
						l_length,
						l_text_before,
						l_text_after
					])
					l_regex.next_match
				end
			end
		ensure
			empty_if_invalid_pattern: (not is_valid_pattern (a_pattern)) implies Result.count = 0
			result_not_void: Result /= Void
			all_positions_valid: across Result as ic all
				ic.item.start_position >= 1 and
				ic.item.end_position >= ic.item.start_position and
				ic.item.start_position <= a_subject.count and
				ic.item.end_position <= a_subject.count
			end
			all_lengths_consistent: across Result as ic all
				ic.item.length = (ic.item.end_position - ic.item.start_position + 1).max (0)
			end
			all_text_reconstructable: across Result as ic all
				ic.item.text_before.count + ic.item.value.count + ic.item.text_after.count =
				a_subject.count
			end
		end

	replace_first_match (a_pattern, a_subject, a_replacement: READABLE_STRING_GENERAL): STRING_32
			-- Replace first match of pattern in subject
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					Result := l_regex.unicode_replace (a_replacement)
				else
					Result := a_subject.to_string_32
				end
			else
				Result := a_subject.to_string_32
			end
		ensure
			result_attached: Result /= Void
		end

	replace_all_matches (a_pattern, a_subject, a_replacement: READABLE_STRING_GENERAL): STRING_32
			-- Replace all matches of pattern in subject
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					Result := l_regex.unicode_replace_all (a_replacement)
				else
					Result := a_subject.to_string_32
				end
			else
				Result := a_subject.to_string_32
			end
		ensure
			result_attached: Result /= Void
		end

	split_by_pattern (a_pattern, a_subject: READABLE_STRING_GENERAL): ARRAYED_LIST [STRING_32]
			-- Split subject by pattern
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
			l_parts: ARRAY [STRING]
		do
			l_regex := cached_regex (a_pattern)
			if l_regex.is_compiled then
				l_regex.match (a_subject)
				if l_regex.has_matched then
					l_parts := l_regex.split
					create Result.make (l_parts.count)
					across l_parts as ic_p loop
						Result.extend (ic_p.item.to_string_32)
					end
				else
					create Result.make (1)
					Result.extend (a_subject.to_string_32)
				end
			else
				create Result.make (1)
				Result.extend (a_subject.to_string_32)
			end
		ensure
			result_attached: Result /= Void
			at_least_one: Result.count >= 1
		end

feature -- Safety

	escape,
	quote,
	literal (a_literal: READABLE_STRING_GENERAL): STRING_32
			-- Escape special regex characters in literal for safe matching
		local
			i: INTEGER
			c: CHARACTER_32
		do
			create Result.make (a_literal.count + 10)
			from i := 1 until i > a_literal.count loop
				c := a_literal [i]
				if is_special_char (c) then
					Result.append_character ('\')
				end
				Result.append_character (c)
				i := i + 1
			end
		ensure
			result_attached: Result /= Void
		end

	pattern_complexity (a_pattern: READABLE_STRING_GENERAL): INTEGER
			-- Heuristic ReDoS risk score (1-10)
			-- Higher scores indicate potentially dangerous patterns
		local
			l_nested_quantifiers: INTEGER
			l_alternations: INTEGER
			l_backrefs_with_quantifiers: INTEGER
			i: INTEGER
			c: CHARACTER_32
			in_group: BOOLEAN
			prev_was_quantifier: BOOLEAN
		do
			-- Count potential problem patterns
			from i := 1 until i > a_pattern.count loop
				c := a_pattern [i]
				inspect c
				when '(' then
					in_group := True
					if prev_was_quantifier then
						l_nested_quantifiers := l_nested_quantifiers + 1
					end
				when ')' then
					in_group := False
				when '*', '+' then
					if prev_was_quantifier or in_group then
						l_nested_quantifiers := l_nested_quantifiers + 1
					end
					prev_was_quantifier := True
				when '|' then
					l_alternations := l_alternations + 1
				when '\' then
					-- Check for backreference
					if i < a_pattern.count then
						i := i + 1
						c := a_pattern [i]
						if c >= '1' and c <= '9' then
							if prev_was_quantifier then
								l_backrefs_with_quantifiers := l_backrefs_with_quantifiers + 1
							end
						end
					end
					prev_was_quantifier := False
				else
					prev_was_quantifier := False
				end
				i := i + 1
			end

			-- Calculate score
			Result := 1
			Result := Result + (l_nested_quantifiers * 3).min (6)
			Result := Result + (l_alternations // 3).min (2)
			Result := Result + (l_backrefs_with_quantifiers * 2).min (4)
			Result := Result.min (10)
		ensure
			valid_range: Result >= 1 and Result <= 10
		end

	is_potentially_dangerous (a_pattern: READABLE_STRING_GENERAL): BOOLEAN
			-- Is pattern potentially vulnerable to ReDoS?
		do
			Result := pattern_complexity (a_pattern) >= Dangerous_complexity_threshold
		end

	Dangerous_complexity_threshold: INTEGER = 7
			-- Complexity score at which patterns are considered dangerous

feature {NONE} -- Implementation

	internal_regex: detachable RX_PCRE_REGULAR_EXPRESSION
			-- Wrapped Gobo regex

	create_match_result (a_regex: RX_PCRE_REGULAR_EXPRESSION;
			a_subject: READABLE_STRING_GENERAL): SIMPLE_REGEX_MATCH
			-- Create match result from Gobo regex state
		local
			l_groups: ARRAYED_LIST [detachable STRING_32]
			i: INTEGER
		do
			if a_regex.has_matched then
				create l_groups.make (a_regex.match_count)
				from i := 0 until i >= a_regex.match_count loop
					if a_regex.captured_start_position (i) > 0 then
						l_groups.extend (a_regex.unicode_captured_substring (i))
					else
						l_groups.extend (Void)
					end
					i := i + 1
				end
				create Result.make_matched (
					a_subject,
					a_regex.unicode_captured_substring (0),
					a_regex.captured_start_position (0),
					a_regex.captured_end_position (0),
					l_groups)
			else
				create Result.make_not_matched (a_subject)
			end
		ensure
			result_attached: Result /= Void
		end

	twin_with_options (a_caseless, a_multiline, a_dotall: BOOLEAN): SIMPLE_REGEX
			-- Create new regex with specified options
		do
			create Result.make
			Result.set_options (a_caseless, a_multiline, a_dotall)
			if attached pattern as p then
				Result.compile (p)
			end
		end

	apply_options (a_regex: RX_PCRE_REGULAR_EXPRESSION)
			-- Apply current options to regex
		do
			a_regex.set_caseless (is_caseless)
			a_regex.set_multiline (is_multiline)
			a_regex.set_dotall (is_dotall)
		end

	is_special_char (a_c: CHARACTER_32): BOOLEAN
			-- Is c a special regex character that needs escaping?
		do
			Result := a_c = '\' or a_c = '^' or a_c = '$' or a_c = '.' or
					  a_c = '[' or a_c = ']' or a_c = '|' or a_c = '(' or
					  a_c = ')' or a_c = '?' or a_c = '*' or a_c = '+' or
					  a_c = '{' or a_c = '}'
		end

feature {SIMPLE_REGEX, SIMPLE_REGEX_BUILDER} -- Internal

	set_options (a_caseless, a_multiline, a_dotall: BOOLEAN)
			-- Set options
		do
			is_caseless := a_caseless
			is_multiline := a_multiline
			is_dotall := a_dotall
		ensure
			caseless_set: is_caseless = a_caseless
			multiline_set: is_multiline = a_multiline
			dotall_set: is_dotall = a_dotall
		end

feature {NONE} -- Pattern Cache

	cached_regex (a_pattern: READABLE_STRING_GENERAL): RX_PCRE_REGULAR_EXPRESSION
			-- Get or create cached regex for pattern
		local
			l_key: STRING_32
		do
			l_key := a_pattern.to_string_32
			if attached pattern_cache.item (l_key) as l_cached then
				Result := l_cached
			else
				create Result.make
				Result.compile (a_pattern)
				if Result.is_compiled and pattern_cache.count < Max_cache_size then
					pattern_cache.put (Result, l_key)
				end
			end
		ensure
			result_attached: Result /= Void
		end

	pattern_cache: HASH_TABLE [RX_PCRE_REGULAR_EXPRESSION, STRING_32]
			-- Cache of compiled patterns
		once
			create Result.make (100)
		end

	Max_cache_size: INTEGER = 1000
			-- Maximum number of cached patterns

invariant
	last_error_attached: last_error /= Void

end