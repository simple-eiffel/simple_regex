note
	description: "[
		Library of common, pre-built regex patterns for typical validation tasks.

		Provides both pattern strings and compiled SIMPLE_REGEX instances.
		All patterns are cached after first use.

		Categories:
		- Email and web (email, URL, domain)
		- Network (IPv4, IPv6, MAC address)
		- Phone numbers (US, international)
		- Dates and times (ISO, US, EU formats)
		- Financial (credit card, currency)
		- Identifiers (UUID, hex color, username, slug)
		- Security (password strength)
		- Markup (HTML tags)
		- Files (path, extension)

		Usage:
			patterns: SIMPLE_REGEX_PATTERNS
			create patterns.make
			if patterns.is_email ("user@example.com") then ...
			if patterns.is_valid_password ("MyP@ss123") then ...
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_REGEX_PATTERNS

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize pattern cache
		do
			create pattern_cache.make (30)
		end

feature -- Email and Web Patterns

	email_pattern: STRING_32
			-- Pattern for basic email validation
			-- Matches: user@domain.com, user.name+tag@sub.domain.org
		once
			Result := {STRING_32} "^[a-zA-Z0-9._%%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
		end

	is_email (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match email pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (email_pattern, a_text)
		end

	url_pattern: STRING_32
			-- Pattern for URL validation (http, https, ftp)
		once
			Result := {STRING_32} "^(https?|ftp)://[^\s/$.?#].[^\s]*$"
		end

	is_url (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match URL pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (url_pattern, a_text)
		end

	domain_pattern: STRING_32
			-- Pattern for domain name
		once
			Result := {STRING_32} "^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"
		end

	is_domain (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match domain pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (domain_pattern, a_text)
		end

feature -- Network Patterns

	ipv4_pattern: STRING_32
			-- Pattern for IPv4 address
			-- Matches: 192.168.1.1, 10.0.0.255
		once
			Result := {STRING_32} "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
		end

	is_ipv4 (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match IPv4 pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (ipv4_pattern, a_text)
		end

	ipv6_pattern: STRING_32
			-- Pattern for IPv6 address (simplified)
			-- Matches standard and compressed formats
		once
			Result := {STRING_32} "^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::$|^([0-9a-fA-F]{1,4}:){1,7}:$|^::[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){0,6}$"
		end

	is_ipv6 (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match IPv6 pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (ipv6_pattern, a_text)
		end

	mac_address_pattern: STRING_32
			-- Pattern for MAC address
			-- Matches: 00:1A:2B:3C:4D:5E, 00-1A-2B-3C-4D-5E
		once
			Result := {STRING_32} "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
		end

	is_mac_address (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match MAC address pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (mac_address_pattern, a_text)
		end

feature -- Phone Patterns

	phone_us_pattern: STRING_32
			-- Pattern for US phone number
			-- Matches: (123) 456-7890, 123-456-7890, 1234567890
		once
			Result := {STRING_32} "^(\+1)?[\s.-]?\(?[0-9]{3}\)?[\s.-]?[0-9]{3}[\s.-]?[0-9]{4}$"
		end

	is_phone_us (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match US phone pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (phone_us_pattern, a_text)
		end

	phone_international_pattern: STRING_32
			-- Pattern for international phone number
			-- Matches: +1-234-567-8900, +44 20 7946 0958
		once
			Result := {STRING_32} "^\+[1-9][0-9]{0,2}[\s.-]?(\(?[0-9]{1,4}\)?[\s.-]?){1,4}[0-9]{1,4}$"
		end

	is_phone_international (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match international phone pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (phone_international_pattern, a_text)
		end

feature -- Date Patterns

	date_iso_pattern: STRING_32
			-- Pattern for ISO date (YYYY-MM-DD)
		once
			Result := {STRING_32} "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"
		end

	is_date_iso (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match ISO date pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (date_iso_pattern, a_text)
		end

	date_us_pattern: STRING_32
			-- Pattern for US date (MM/DD/YYYY)
		once
			Result := {STRING_32} "^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/[0-9]{4}$"
		end

	is_date_us (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match US date pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (date_us_pattern, a_text)
		end

	date_eu_pattern: STRING_32
			-- Pattern for EU date (DD/MM/YYYY or DD.MM.YYYY)
		once
			Result := {STRING_32} "^(0[1-9]|[12][0-9]|3[01])[/\.](0[1-9]|1[0-2])[/\.][0-9]{4}$"
		end

	is_date_eu (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match EU date pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (date_eu_pattern, a_text)
		end

	datetime_iso_pattern: STRING_32
			-- Pattern for ISO datetime (YYYY-MM-DDTHH:MM:SS)
		once
			Result := {STRING_32} "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](Z|[+-][0-9]{2}:[0-9]{2})?$"
		end

	is_datetime_iso (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match ISO datetime pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (datetime_iso_pattern, a_text)
		end

feature -- Time Patterns

	time_24h_pattern: STRING_32
			-- Pattern for 24-hour time (HH:MM or HH:MM:SS)
		once
			Result := {STRING_32} "^([01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$"
		end

	is_time_24h (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match 24-hour time pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (time_24h_pattern, a_text)
		end

	time_12h_pattern: STRING_32
			-- Pattern for 12-hour time (HH:MM AM/PM)
		once
			Result := {STRING_32} "^(0?[1-9]|1[0-2]):[0-5][0-9]\s?(AM|PM|am|pm)$"
		end

	is_time_12h (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match 12-hour time pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (time_12h_pattern, a_text)
		end

feature -- Financial Patterns

	credit_card_pattern: STRING_32
			-- Pattern for credit card number (with or without spaces/dashes)
			-- Validates format, not Luhn checksum
		once
			Result := {STRING_32} "^[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}$"
		end

	is_credit_card (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match credit card pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (credit_card_pattern, a_text)
		end

	currency_pattern: STRING_32
			-- Pattern for currency amount
			-- Matches: $1,234.56, 1234.56, -$99.99
		once
			Result := {STRING_32} "^-?\$?[0-9]{1,3}(,[0-9]{3})*(\.[0-9]{2})?$"
		end

	is_currency (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match currency pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (currency_pattern, a_text)
		end

feature -- Identifier Patterns

	uuid_pattern: STRING_32
			-- Pattern for UUID/GUID
			-- Matches: 550e8400-e29b-41d4-a716-446655440000
		once
			Result := {STRING_32} "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
		end

	is_uuid (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match UUID pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (uuid_pattern, a_text)
		end

	hex_color_pattern: STRING_32
			-- Pattern for hex color code
			-- Matches: #FFF, #FFFFFF, #fff, #ffffff
		once
			Result := {STRING_32} "^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$"
		end

	is_hex_color (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match hex color pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (hex_color_pattern, a_text)
		end

	username_pattern: STRING_32
			-- Pattern for username (alphanumeric, underscore, 3-20 chars)
		once
			Result := {STRING_32} "^[a-zA-Z][a-zA-Z0-9_]{2,19}$"
		end

	is_username (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match username pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (username_pattern, a_text)
		end

	slug_pattern: STRING_32
			-- Pattern for URL slug (lowercase, hyphens)
		once
			Result := {STRING_32} "^[a-z0-9]+(-[a-z0-9]+)*$"
		end

	is_slug (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match slug pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (slug_pattern, a_text)
		end

feature -- Security Patterns

	password_strong_pattern: STRING_32
			-- Pattern for strong password
			-- Requires: 8+ chars, uppercase, lowercase, digit, special char
		once
			Result := {STRING_32} "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%%^&*()_+=-]).{8,}$"
		end

	is_strong_password (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match strong password requirements?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (password_strong_pattern, a_text)
		end

	password_medium_pattern: STRING_32
			-- Pattern for medium-strength password
			-- Requires: 6+ chars, letter and digit
		once
			Result := {STRING_32} "^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$"
		end

	is_medium_password (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match medium password requirements?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (password_medium_pattern, a_text)
		end

feature -- Markup Patterns

	html_tag_pattern: STRING_32
			-- Pattern for HTML tag (opening, closing, or self-closing)
		once
			Result := {STRING_32} "<(/)?([a-zA-Z][a-zA-Z0-9]*)\b[^>]*(/)?>"
		end

	extract_html_tags (a_text: READABLE_STRING_GENERAL): ARRAYED_LIST [STRING_32]
			-- Extract all HTML tags from text
		require
			text_attached: a_text /= Void
		do
			Result := get_regex (html_tag_pattern).all_matches_for (html_tag_pattern, a_text)
		end

	html_comment_pattern: STRING_32
			-- Pattern for HTML comment
		once
			Result := {STRING_32} "<!--[\s\S]*?-->"
		end

feature -- File Patterns

	file_extension_pattern: STRING_32
			-- Pattern for file with extension
		once
			Result := {STRING_32} "^.+\.([a-zA-Z0-9]+)$"
		end

	extract_extension (a_filename: READABLE_STRING_GENERAL): detachable STRING_32
			-- Extract file extension, or Void if none
		require
			filename_attached: a_filename /= Void
		local
			l_regex: SIMPLE_REGEX
			l_match: SIMPLE_REGEX_MATCH
		do
			l_regex := get_regex (file_extension_pattern)
			create l_regex.make_from_pattern (file_extension_pattern)
			l_match := l_regex.match (a_filename)
			if l_match.is_matched and then attached l_match.group (1) as ext then
				Result := ext
			end
		end

	windows_path_pattern: STRING_32
			-- Pattern for Windows file path (simplified)
		once
			Result := {STRING_32} "^[a-zA-Z]:\\[^<>|]+$"
		end

	is_windows_path (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match Windows path pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (windows_path_pattern, a_text)
		end

	unix_path_pattern: STRING_32
			-- Pattern for Unix file path
		once
			Result := {STRING_32} "^(/[^/\0]+)+/?$"
		end

	is_unix_path (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match Unix path pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (unix_path_pattern, a_text)
		end

feature -- US-Specific Patterns

	zip_code_us_pattern: STRING_32
			-- Pattern for US ZIP code (5 digit or ZIP+4)
		once
			Result := {STRING_32} "^[0-9]{5}(-[0-9]{4})?$"
		end

	is_zip_code_us (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match US ZIP code pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (zip_code_us_pattern, a_text)
		end

	ssn_pattern: STRING_32
			-- Pattern for Social Security Number
			-- Matches: 123-45-6789
		once
			Result := {STRING_32} "^[0-9]{3}-[0-9]{2}-[0-9]{4}$"
		end

	is_ssn (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match SSN pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (ssn_pattern, a_text)
		end

feature -- Number Patterns

	integer_pattern: STRING_32
			-- Pattern for integer (positive or negative)
		once
			Result := {STRING_32} "^-?[0-9]+$"
		end

	is_integer (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match integer pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (integer_pattern, a_text)
		end

	decimal_pattern: STRING_32
			-- Pattern for decimal number
		once
			Result := {STRING_32} "^-?[0-9]+(\.[0-9]+)?$"
		end

	is_decimal (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match decimal pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (decimal_pattern, a_text)
		end

	scientific_notation_pattern: STRING_32
			-- Pattern for scientific notation
			-- Matches: 1.23e10, -4.5E-6
		once
			Result := {STRING_32} "^-?[0-9]+(\.[0-9]+)?[eE][+-]?[0-9]+$"
		end

	is_scientific_notation (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match scientific notation pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (scientific_notation_pattern, a_text)
		end

	hex_number_pattern: STRING_32
			-- Pattern for hexadecimal number
			-- Matches: 0xFF, 0x1a2b, FF
		once
			Result := {STRING_32} "^(0x)?[0-9a-fA-F]+$"
		end

	is_hex_number (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match hex number pattern?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (hex_number_pattern, a_text)
		end

feature -- Text Patterns

	alphanumeric_pattern: STRING_32
			-- Pattern for alphanumeric text only
		once
			Result := {STRING_32} "^[a-zA-Z0-9]+$"
		end

	is_alphanumeric (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text contain only alphanumeric characters?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (alphanumeric_pattern, a_text)
		end

	alphabetic_pattern: STRING_32
			-- Pattern for alphabetic text only
		once
			Result := {STRING_32} "^[a-zA-Z]+$"
		end

	is_alphabetic (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text contain only alphabetic characters?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (alphabetic_pattern, a_text)
		end

	whitespace_only_pattern: STRING_32
			-- Pattern for whitespace-only text
		once
			Result := {STRING_32} "^\s*$"
		end

	is_whitespace_only (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text contain only whitespace?
		require
			text_attached: a_text /= Void
		do
			Result := matches_pattern (whitespace_only_pattern, a_text)
		end

feature {NONE} -- Implementation

	pattern_cache: HASH_TABLE [SIMPLE_REGEX, STRING_32]
			-- Cache of compiled patterns

	get_regex (a_pattern: STRING_32): SIMPLE_REGEX
			-- Get or create cached regex for pattern
		require
			pattern_attached: a_pattern /= Void
		do
			if attached pattern_cache.item (a_pattern) as l_cached then
				Result := l_cached
			else
				create Result.make_from_pattern (a_pattern)
				if Result.is_compiled then
					pattern_cache.put (Result, a_pattern)
				end
			end
		ensure
			result_attached: Result /= Void
		end

	matches_pattern (a_pattern: STRING_32; a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does text match pattern?
		require
			pattern_attached: a_pattern /= Void
			text_attached: a_text /= Void
		local
			l_regex: SIMPLE_REGEX
		do
			l_regex := get_regex (a_pattern)
			if l_regex.is_compiled then
				Result := l_regex.match (a_text).is_matched
			end
		end

invariant
	cache_attached: pattern_cache /= Void

end
