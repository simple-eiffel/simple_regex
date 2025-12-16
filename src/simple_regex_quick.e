note
	description: "[
		Zero-configuration regex facade for beginners.

		One-liner regex operations.
		For full control, use SIMPLE_REGEX directly.

		Quick Start Examples:
			create rx.make

			-- Check if pattern matches
			if rx.matches ("[a-z]+", "hello") then ...

			-- Find first match
			word := rx.find ("\w+", "Hello World")  -- "Hello"

			-- Find all matches
			words := rx.find_all ("\w+", "Hello World")  -- ["Hello", "World"]

			-- Replace
			result := rx.replace ("World", "Eiffel", "Hello World")
			result := rx.replace_all ("\d+", "X", "a1b2c3")  -- "aXbXcX"
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick regex facade.
		do
			create regex.make
			create logger.make ("regex_quick")
		ensure
			regex_exists: regex /= Void
		end

feature -- Matching

	matches (a_pattern: STRING; a_text: STRING): BOOLEAN
			-- Does pattern match anywhere in text?
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			logger.debug_log ("Matching: " + a_pattern)
			Result := regex.matches (a_pattern, a_text)
		end

	matches_full (a_pattern: STRING; a_text: STRING): BOOLEAN
			-- Does pattern match entire text?
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			Result := regex.matches ("^" + a_pattern + "$", a_text)
		end

	is_match (a_pattern: STRING; a_text: STRING): BOOLEAN
			-- Alias for matches.
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			Result := matches (a_pattern, a_text)
		end

feature -- Finding

	find (a_pattern: STRING; a_text: STRING): detachable STRING
			-- Find first match of pattern in text.
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			logger.debug_log ("Finding: " + a_pattern)
			Result := regex.first_match (a_pattern, a_text)
		end

	find_all (a_pattern: STRING; a_text: STRING): ARRAYED_LIST [STRING]
			-- Find all matches of pattern in text.
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			logger.debug_log ("Finding all: " + a_pattern)
			Result := regex.all_matches (a_pattern, a_text)
			if Result = Void then
				create Result.make (0)
			end
		ensure
			result_exists: Result /= Void
		end

	find_groups (a_pattern: STRING; a_text: STRING): ARRAYED_LIST [STRING]
			-- Find capture groups from first match.
			-- Example: rx.find_groups ("(\w+)@(\w+)", "user@host") -- ["user", "host"]
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			Result := regex.capture_groups (a_pattern, a_text)
			if Result = Void then
				create Result.make (0)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Replacing

	replace (a_pattern: STRING; a_replacement: STRING; a_text: STRING): STRING
			-- Replace first match of pattern.
		require
			pattern_not_empty: not a_pattern.is_empty
			replacement_not_void: a_replacement /= Void
			text_not_void: a_text /= Void
		do
			logger.debug_log ("Replacing first: " + a_pattern)
			Result := regex.replace_first (a_pattern, a_replacement, a_text)
			if Result = Void then
				Result := a_text
			end
		ensure
			result_exists: Result /= Void
		end

	replace_all (a_pattern: STRING; a_replacement: STRING; a_text: STRING): STRING
			-- Replace all matches of pattern.
		require
			pattern_not_empty: not a_pattern.is_empty
			replacement_not_void: a_replacement /= Void
			text_not_void: a_text /= Void
		do
			logger.debug_log ("Replacing all: " + a_pattern)
			Result := regex.replace_all (a_pattern, a_replacement, a_text)
			if Result = Void then
				Result := a_text
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Splitting

	split (a_pattern: STRING; a_text: STRING): ARRAYED_LIST [STRING]
			-- Split text by pattern.
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			Result := regex.split (a_pattern, a_text)
			if Result = Void then
				create Result.make (1)
				Result.extend (a_text)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Common Pattern Shortcuts

	is_email (a_text: STRING): BOOLEAN
			-- Does text look like an email address?
		require
			text_not_void: a_text /= Void
		do
			Result := matches ("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", a_text)
		end

	is_url (a_text: STRING): BOOLEAN
			-- Does text look like a URL?
		require
			text_not_void: a_text /= Void
		do
			Result := matches ("^https?://[^\s]+$", a_text)
		end

	is_phone (a_text: STRING): BOOLEAN
			-- Does text look like a phone number?
			-- Matches common formats: 123-456-7890, (123) 456-7890, +1-123-456-7890
		require
			text_not_void: a_text /= Void
		do
			Result := matches ("^[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$", a_text)
		end

	is_ipv4 (a_text: STRING): BOOLEAN
			-- Does text look like an IPv4 address?
		require
			text_not_void: a_text /= Void
		do
			Result := matches ("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", a_text)
		end

	extract_emails (a_text: STRING): ARRAYED_LIST [STRING]
			-- Extract all email addresses from text.
		require
			text_not_void: a_text /= Void
		do
			Result := find_all ("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}", a_text)
		ensure
			result_exists: Result /= Void
		end

	extract_urls (a_text: STRING): ARRAYED_LIST [STRING]
			-- Extract all URLs from text.
		require
			text_not_void: a_text /= Void
		do
			Result := find_all ("https?://[^\s]+", a_text)
		ensure
			result_exists: Result /= Void
		end

	extract_numbers (a_text: STRING): ARRAYED_LIST [STRING]
			-- Extract all numbers from text.
		require
			text_not_void: a_text /= Void
		do
			Result := find_all ("-?[0-9]+\.?[0-9]*", a_text)
		ensure
			result_exists: Result /= Void
		end

feature -- Utility

	escape (a_text: STRING): STRING
			-- Escape regex special characters in text.
		require
			text_not_void: a_text /= Void
		do
			Result := regex.escape (a_text)
			if Result = Void then
				Result := a_text
			end
		ensure
			result_exists: Result /= Void
		end

	count_matches (a_pattern: STRING; a_text: STRING): INTEGER
			-- Count number of pattern matches in text.
		require
			pattern_not_empty: not a_pattern.is_empty
			text_not_void: a_text /= Void
		do
			Result := find_all (a_pattern, a_text).count
		end

feature -- Advanced Access

	regex: SIMPLE_REGEX
			-- Access underlying regex handler for advanced operations.

feature {NONE} -- Implementation

	logger: SIMPLE_LOGGER
			-- Logger for debugging.

invariant
	regex_exists: regex /= Void
	logger_exists: logger /= Void

end
