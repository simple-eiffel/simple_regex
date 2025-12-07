note
	description: "[
		Fluent builder for constructing regex patterns programmatically.

		Provides a type-safe API for building regex patterns with:
		- Literals and raw patterns
		- Character classes (\d, \w, \s, custom)
		- Quantifiers (*, +, ?, {n}, {n,m})
		- Groups (capturing, non-capturing)
		- Lookahead/lookbehind assertions
		- Atomic groups and backreferences

		All builder methods return Current for fluent chaining.

		Example usage:
			builder.literal ("hello")
			       .whitespace
			       .group_start
			       .word_char.one_or_more
			       .group_end
			regex := builder.to_regex

		Produces pattern: hello\s(\w+)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_BUILDER

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty builder
		do
			create internal_pattern.make (50)
			open_group_count := 0
			has_quantifiable_element := False
		ensure
			empty_pattern: pattern.is_empty
			no_open_groups: open_group_count = 0
		end

feature -- Access

	pattern: STRING_32
			-- Current built pattern
		do
			Result := internal_pattern.twin
		ensure
			result_attached: Result /= Void
		end

	open_group_count: INTEGER
			-- Number of unclosed groups

	has_quantifiable_element: BOOLEAN
			-- Is there an element that can accept a quantifier?

feature -- Conversion

	to_regex: SIMPLE_REGEX
			-- Create compiled regex from current pattern
		require
			balanced_groups: open_group_count = 0
		do
			create Result.make_from_pattern (internal_pattern)
		ensure
			result_attached: Result /= Void
		end

	to_regex_with_options (a_caseless, a_multiline, a_dotall: BOOLEAN): SIMPLE_REGEX
			-- Create compiled regex with specified options
		require
			balanced_groups: open_group_count = 0
		do
			create Result.make
			Result.set_options (a_caseless, a_multiline, a_dotall)
			Result.compile (internal_pattern)
		ensure
			result_attached: Result /= Void
		end

feature -- Building: Literals

	literal (a_text: READABLE_STRING_GENERAL): like Current
			-- Add escaped literal text (special chars escaped)
		require
			text_attached: a_text /= Void
		local
			i: INTEGER
			c: CHARACTER_32
		do
			from i := 1 until i > a_text.count loop
				c := a_text [i]
				if is_special_char (c) then
					internal_pattern.append_character ('\')
				end
				internal_pattern.append_character (c)
				i := i + 1
			end
			has_quantifiable_element := a_text.count > 0
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: a_text.count > 0 implies has_quantifiable_element
		end

	raw (a_pattern: READABLE_STRING_GENERAL): like Current
			-- Add raw pattern text (no escaping)
		require
			pattern_attached: a_pattern /= Void
		do
			internal_pattern.append_string_general (a_pattern)
			has_quantifiable_element := a_pattern.count > 0
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Building: Any Character

	any_char: like Current
			-- Match any single character (.)
		do
			internal_pattern.append_character ('.')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Building: Character Classes

	digit: like Current
			-- Match digit (\d)
		do
			internal_pattern.append_string ("\d")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	non_digit: like Current
			-- Match non-digit (\D)
		do
			internal_pattern.append_string ("\D")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	word_char: like Current
			-- Match word character (\w)
		do
			internal_pattern.append_string ("\w")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	non_word_char: like Current
			-- Match non-word character (\W)
		do
			internal_pattern.append_string ("\W")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	whitespace: like Current
			-- Match whitespace (\s)
		do
			internal_pattern.append_string ("\s")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	non_whitespace: like Current
			-- Match non-whitespace (\S)
		do
			internal_pattern.append_string ("\S")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	one_of (a_chars: READABLE_STRING_GENERAL): like Current
			-- Match any single character from set [...]
		require
			chars_attached: a_chars /= Void
			not_empty: not a_chars.is_empty
		do
			internal_pattern.append_character ('[')
			internal_pattern.append_string_general (escape_class_chars (a_chars))
			internal_pattern.append_character (']')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	none_of (a_chars: READABLE_STRING_GENERAL): like Current
			-- Match any single character NOT in set [^...]
		require
			chars_attached: a_chars /= Void
			not_empty: not a_chars.is_empty
		do
			internal_pattern.append_string ("[^")
			internal_pattern.append_string_general (escape_class_chars (a_chars))
			internal_pattern.append_character (']')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	range (a_from, a_to: CHARACTER_32): like Current
			-- Match character in range [from-to]
		require
			valid_range: a_from <= a_to
		do
			internal_pattern.append_character ('[')
			internal_pattern.append_character (a_from)
			internal_pattern.append_character ('-')
			internal_pattern.append_character (a_to)
			internal_pattern.append_character (']')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Building: Unicode

	unicode_property (a_property: READABLE_STRING_GENERAL): like Current
			-- Match Unicode property \p{property}
		require
			property_attached: a_property /= Void
			not_empty: not a_property.is_empty
		do
			internal_pattern.append_string ("\p{")
			internal_pattern.append_string_general (a_property)
			internal_pattern.append_character ('}')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	unicode_not_property (a_property: READABLE_STRING_GENERAL): like Current
			-- Match NOT Unicode property \P{property}
		require
			property_attached: a_property /= Void
			not_empty: not a_property.is_empty
		do
			internal_pattern.append_string ("\P{")
			internal_pattern.append_string_general (a_property)
			internal_pattern.append_character ('}')
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	grapheme: like Current
			-- Match Unicode grapheme cluster (\X)
		do
			internal_pattern.append_string ("\X")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Building: Anchors

	start_of_string: like Current
			-- Match start of string (^)
		do
			internal_pattern.append_character ('^')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	end_of_string: like Current
			-- Match end of string ($)
		do
			internal_pattern.append_character ('$')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	word_boundary: like Current
			-- Match word boundary (\b)
		do
			internal_pattern.append_string ("\b")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	non_word_boundary: like Current
			-- Match non-word boundary (\B)
		do
			internal_pattern.append_string ("\B")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

feature -- Building: Quantifiers

	zero_or_more: like Current
			-- Match preceding element zero or more times (*)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_character ('*')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	zero_or_more_lazy: like Current
			-- Match preceding element zero or more times, lazy (*?)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_string ("*?")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	one_or_more: like Current
			-- Match preceding element one or more times (+)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_character ('+')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	one_or_more_lazy: like Current
			-- Match preceding element one or more times, lazy (+?)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_string ("+?")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	optional: like Current
			-- Match preceding element zero or one time (?)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_character ('?')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	optional_lazy: like Current
			-- Match preceding element zero or one time, lazy (??)
		require
			has_element: has_quantifiable_element
		do
			internal_pattern.append_string ("??")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	exactly (n: INTEGER): like Current
			-- Match preceding element exactly n times {n}
		require
			has_element: has_quantifiable_element
			positive: n >= 0
		do
			internal_pattern.append_character ('{')
			internal_pattern.append_integer (n)
			internal_pattern.append_character ('}')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	at_least (n: INTEGER): like Current
			-- Match preceding element at least n times {n,}
		require
			has_element: has_quantifiable_element
			non_negative: n >= 0
		do
			internal_pattern.append_character ('{')
			internal_pattern.append_integer (n)
			internal_pattern.append_string (",}")
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

	between (min, max: INTEGER): like Current
			-- Match preceding element between min and max times {min,max}
		require
			has_element: has_quantifiable_element
			valid_min: min >= 0
			valid_max: max >= min
		do
			internal_pattern.append_character ('{')
			internal_pattern.append_integer (min)
			internal_pattern.append_character (',')
			internal_pattern.append_integer (max)
			internal_pattern.append_character ('}')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

feature -- Building: Groups

	group_start: like Current
			-- Start capturing group (
		do
			internal_pattern.append_character ('(')
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	group_end: like Current
			-- End capturing group )
		require
			has_open_group: open_group_count > 0
		do
			internal_pattern.append_character (')')
			open_group_count := open_group_count - 1
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			group_closed: open_group_count = old open_group_count - 1
			has_quantifiable: has_quantifiable_element
		end

	non_capturing_start: like Current
			-- Start non-capturing group (?:
		do
			internal_pattern.append_string ("(?:")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	atomic_start: like Current
			-- Start atomic group (?>
			-- Prevents backtracking into group
		do
			internal_pattern.append_string ("(?>")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

feature -- Building: Alternation

	alternate: like Current
			-- Add alternation (|)
		do
			internal_pattern.append_character ('|')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			not_quantifiable: not has_quantifiable_element
		end

feature -- Building: Lookahead/Lookbehind

	lookahead_positive_start: like Current
			-- Start positive lookahead (?=
		do
			internal_pattern.append_string ("(?=")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	lookahead_negative_start: like Current
			-- Start negative lookahead (?!
		do
			internal_pattern.append_string ("(?!")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	lookbehind_positive_start: like Current
			-- Start positive lookbehind (?<=
		do
			internal_pattern.append_string ("(?<=")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	lookbehind_negative_start: like Current
			-- Start negative lookbehind (?<!
		do
			internal_pattern.append_string ("(?<!")
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

feature -- Building: Backreferences

	backreference (n: INTEGER): like Current
			-- Reference to captured group n (\n)
		require
			valid_group: n >= 1 and n <= 9
		do
			internal_pattern.append_character ('\')
			internal_pattern.append_integer (n)
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Building: Recursion

	recurse: like Current
			-- Recurse entire pattern (?R)
		do
			internal_pattern.append_string ("(?R)")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Building: Conditionals

	conditional_start (n: INTEGER): like Current
			-- Start conditional on group n: (?(n)
		require
			valid_group: n >= 1
		do
			internal_pattern.append_string ("(?(")
			internal_pattern.append_integer (n)
			internal_pattern.append_character (')')
			open_group_count := open_group_count + 1
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			group_opened: open_group_count = old open_group_count + 1
		end

	conditional_else: like Current
			-- Add else branch in conditional |
		do
			internal_pattern.append_character ('|')
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Building: Special Characters

	newline: like Current
			-- Match newline (\n)
		do
			internal_pattern.append_string ("\n")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	carriage_return: like Current
			-- Match carriage return (\r)
		do
			internal_pattern.append_string ("\r")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

	tab: like Current
			-- Match tab (\t)
		do
			internal_pattern.append_string ("\t")
			has_quantifiable_element := True
			Result := Current
		ensure
			result_is_current: Result = Current
			has_quantifiable: has_quantifiable_element
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is current pattern valid (balanced groups)?
		do
			Result := open_group_count = 0
		end

feature -- Reset

	reset: like Current
			-- Clear pattern and start fresh
		do
			internal_pattern.wipe_out
			open_group_count := 0
			has_quantifiable_element := False
			Result := Current
		ensure
			result_is_current: Result = Current
			empty_pattern: pattern.is_empty
			no_open_groups: open_group_count = 0
			not_quantifiable: not has_quantifiable_element
		end

feature {NONE} -- Implementation

	internal_pattern: STRING_32
			-- The pattern being built

	is_special_char (c: CHARACTER_32): BOOLEAN
			-- Is c a special regex character that needs escaping?
		do
			Result := c = '\' or c = '^' or c = '$' or c = '.' or
					  c = '[' or c = ']' or c = '|' or c = '(' or
					  c = ')' or c = '?' or c = '*' or c = '+' or
					  c = '{' or c = '}'
		end

	escape_class_chars (a_chars: READABLE_STRING_GENERAL): STRING_32
			-- Escape special characters inside character class
			-- Inside [...], only ] \ ^ - need escaping
		local
			i: INTEGER
			c: CHARACTER_32
		do
			create Result.make (a_chars.count + 5)
			from i := 1 until i > a_chars.count loop
				c := a_chars [i]
				if c = ']' or c = '\' or c = '^' or c = '-' then
					Result.append_character ('\')
				end
				Result.append_character (c)
				i := i + 1
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	pattern_attached: internal_pattern /= Void
	non_negative_groups: open_group_count >= 0

end
