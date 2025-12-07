note
	description: "Result of a regex match operation"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_MATCH

create
	make_matched,
	make_not_matched

feature {NONE} -- Initialization

	make_matched (a_subject: READABLE_STRING_GENERAL; a_value: STRING_32;
			a_start, a_end: INTEGER; a_groups: ARRAYED_LIST [detachable STRING_32])
			-- Create a successful match result
		require
			subject_attached: a_subject /= Void
			value_attached: a_value /= Void
			valid_positions: a_start >= 1 and a_start <= a_end + 1
			groups_attached: a_groups /= Void
		do
			subject := a_subject
			internal_value := a_value
			start_position := a_start
			end_position := a_end
			internal_groups := a_groups
			is_matched := True
		ensure
			matched: is_matched
			subject_set: subject = a_subject
			value_set: internal_value = a_value
			start_set: start_position = a_start
			end_set: end_position = a_end
			groups_set: internal_groups = a_groups
		end

	make_not_matched (a_subject: READABLE_STRING_GENERAL)
			-- Create an unsuccessful match result
		require
			subject_attached: a_subject /= Void
		do
			subject := a_subject
			internal_value := {STRING_32} ""
			start_position := 0
			end_position := -1
			create internal_groups.make (0)
			is_matched := False
		ensure
			not_matched: not is_matched
			subject_set: subject = a_subject
		end

feature -- Status

	is_matched: BOOLEAN
			-- Did the match succeed?

	is_empty: BOOLEAN
			-- Is the matched string empty?
		require
			matched: is_matched
		do
			Result := start_position > end_position
		ensure
			definition: Result = (start_position > end_position)
		end

feature -- Access

	value: STRING_32
			-- The matched substring
		require
			matched: is_matched
		do
			Result := internal_value
		ensure
			result_attached: Result /= Void
		end

	start_position: INTEGER
			-- Start position in subject (1-based)

	end_position: INTEGER
			-- End position in subject (inclusive)

	length: INTEGER
			-- Length of match
		require
			matched: is_matched
		do
			Result := end_position - start_position + 1
			if Result < 0 then
				Result := 0
			end
		ensure
			non_negative: Result >= 0
		end

feature -- Groups

	group_count: INTEGER
			-- Number of capturing groups (not including group 0)
		do
			Result := internal_groups.count - 1
			if Result < 0 then
				Result := 0
			end
		ensure
			non_negative: Result >= 0
		end

	group (n: INTEGER): detachable STRING_32
			-- n-th captured group (0 = whole match)
		require
			valid_index: n >= 0 and n <= group_count
		do
			if n < internal_groups.count then
				Result := internal_groups [n + 1] -- 1-based list
			end
		end

	groups: ARRAYED_LIST [detachable STRING_32]
			-- All groups as list (index 1 = group 0 = full match)
		do
			Result := internal_groups.twin
		ensure
			result_attached: Result /= Void
		end

feature -- Context

	subject: READABLE_STRING_GENERAL
			-- The matched subject string

	text_before: STRING_32
			-- Subject text before match
		require
			matched: is_matched
		do
			if start_position > 1 then
				Result := subject.substring (1, start_position - 1).to_string_32
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

	text_after: STRING_32
			-- Subject text after match
		require
			matched: is_matched
		do
			if end_position < subject.count then
				Result := subject.substring (end_position + 1, subject.count).to_string_32
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	internal_value: STRING_32
			-- Internal storage for matched value

	internal_groups: ARRAYED_LIST [detachable STRING_32]
			-- Internal storage for captured groups

invariant
	subject_attached: subject /= Void
	internal_value_attached: internal_value /= Void
	internal_groups_attached: internal_groups /= Void
	matched_has_value: is_matched implies internal_value.count >= 0
	positions_valid: is_matched implies (start_position >= 1 and start_position <= end_position + 1)

end
