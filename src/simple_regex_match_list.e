note
	description: "Collection of regex match results"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_MATCH_LIST

inherit
	ITERABLE [SIMPLE_REGEX_MATCH]

create
	make

feature {NONE} -- Initialization

	make (a_subject: READABLE_STRING_GENERAL)
			-- Create empty match list for subject
		require
			subject_attached: a_subject /= Void
		do
			subject := a_subject
			create internal_list.make (10)
		ensure
			subject_set: subject = a_subject
			empty: is_empty
		end

feature -- Access

	subject: READABLE_STRING_GENERAL
			-- The matched subject string

	count: INTEGER
			-- Number of matches
		do
			Result := internal_list.count
		ensure
			non_negative: Result >= 0
		end

	item (i: INTEGER): SIMPLE_REGEX_MATCH
			-- Match at index i (1-based)
		require
			valid_index: i >= 1 and i <= count
		do
			Result := internal_list [i]
		ensure
			result_attached: Result /= Void
		end

	first: SIMPLE_REGEX_MATCH
			-- First match
		require
			not_empty: not is_empty
		do
			Result := internal_list.first
		ensure
			result_attached: Result /= Void
		end

	last: SIMPLE_REGEX_MATCH
			-- Last match
		require
			not_empty: not is_empty
		do
			Result := internal_list.last
		ensure
			result_attached: Result /= Void
		end

feature -- Status

	is_empty: BOOLEAN
			-- Are there no matches?
		do
			Result := internal_list.is_empty
		ensure
			definition: Result = (count = 0)
		end

	has_matches: BOOLEAN
			-- Are there any matches?
		do
			Result := not is_empty
		ensure
			definition: Result = (count > 0)
		end

feature -- Conversion

	as_strings: ARRAYED_LIST [STRING_32]
			-- All matched values as strings
		do
			create Result.make (count)
			across internal_list as m loop
				Result.extend (m.item.value)
			end
		ensure
			result_attached: Result /= Void
			same_count: Result.count = count
		end

	as_array: ARRAY [SIMPLE_REGEX_MATCH]
			-- All matches as array
		do
			Result := internal_list.to_array
		ensure
			result_attached: Result /= Void
			same_count: Result.count = count
		end

feature -- Iteration

	new_cursor: INDEXABLE_ITERATION_CURSOR [SIMPLE_REGEX_MATCH]
			-- Fresh cursor for iteration
		do
			Result := internal_list.new_cursor
		end

feature {SIMPLE_REGEX} -- Modification

	extend (a_match: SIMPLE_REGEX_MATCH)
			-- Add a match to the list
		require
			match_attached: a_match /= Void
		do
			internal_list.extend (a_match)
		ensure
			count_increased: count = old count + 1
			has_match: internal_list.has (a_match)
		end

feature {NONE} -- Implementation

	internal_list: ARRAYED_LIST [SIMPLE_REGEX_MATCH]
			-- Internal storage

invariant
	subject_attached: subject /= Void
	internal_list_attached: internal_list /= Void

end
