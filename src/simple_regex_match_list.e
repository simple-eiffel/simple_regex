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
		do
			subject := a_subject
			create internal_list.make (10)
		ensure
			subject_set: subject = a_subject
			empty: is_empty
			model_empty: model.is_empty
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
			model_consistent: Result = model.count
		end

	item (a_i: INTEGER): SIMPLE_REGEX_MATCH
			-- Match at index i (1-based)
		require
			valid_index: a_i >= 1 and a_i <= count
		do
			Result := internal_list [a_i]
		ensure
			result_attached: Result /= Void
			model_consistent: Result = model [a_i]
		end

	first: SIMPLE_REGEX_MATCH
			-- First match
		require
			not_empty: not is_empty
		do
			Result := internal_list.first
		ensure
			result_attached: Result /= Void
			model_consistent: Result = model.first
		end

	last: SIMPLE_REGEX_MATCH
			-- Last match
		require
			not_empty: not is_empty
		do
			Result := internal_list.last
		ensure
			result_attached: Result /= Void
			model_consistent: Result = model.last
		end

feature -- Status

	is_empty: BOOLEAN
			-- Are there no matches?
		do
			Result := internal_list.is_empty
		ensure
			definition: Result = (count = 0)
			model_consistent: Result = model.is_empty
		end

	has_matches: BOOLEAN
			-- Are there any matches?
		do
			Result := not is_empty
		ensure
			definition: Result = (count > 0)
			model_consistent: Result = not model.is_empty
		end

feature -- Conversion

	as_strings: ARRAYED_LIST [STRING_32]
			-- All matched values as strings
		do
			create Result.make (count)
			across internal_list as ic_m loop
				Result.extend (ic_m.item.value)
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
		do
			internal_list.extend (a_match)
		ensure
			count_increased: count = old count + 1
			has_match: internal_list.has (a_match)
			model_extended: model |=| (old model.deep_twin & a_match)
		end

feature -- Model

	model: MML_SEQUENCE [SIMPLE_REGEX_MATCH]
			-- Mathematical model of match sequence
		do
			create Result
			across internal_list as ic loop
				Result := Result & ic.item
			end
		ensure
			result_attached: Result /= Void
			count_consistent: Result.count = count
		end

feature {NONE} -- Implementation

	internal_list: ARRAYED_LIST [SIMPLE_REGEX_MATCH]
			-- Internal storage

invariant
	subject_attached: subject /= Void
	internal_list_attached: internal_list /= Void
	count_non_negative: count >= 0

end