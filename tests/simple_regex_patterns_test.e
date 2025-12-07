note
	description: "Test suite for SIMPLE_REGEX_PATTERNS"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_REGEX_PATTERNS_TEST

inherit
	TEST_SET_BASE

feature -- Email and Web Tests

	test_email_valid
			-- Test valid email addresses
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_email ("user@example.com"))
			assert ("with_dot", patterns.is_email ("user.name@example.com"))
			assert ("with_plus", patterns.is_email ("user+tag@example.com"))
			assert ("subdomain", patterns.is_email ("user@sub.example.com"))
			assert ("long_tld", patterns.is_email ("user@example.museum"))
		end

	test_email_invalid
			-- Test invalid email addresses
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("no_at", not patterns.is_email ("userexample.com"))
			assert ("no_domain", not patterns.is_email ("user@"))
			assert ("no_tld", not patterns.is_email ("user@example"))
			assert ("double_at", not patterns.is_email ("user@@example.com"))
		end

	test_url_valid
			-- Test valid URLs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("http", patterns.is_url ("http://example.com"))
			assert ("https", patterns.is_url ("https://example.com"))
			assert ("with_path", patterns.is_url ("https://example.com/path/to/page"))
			assert ("with_query", patterns.is_url ("https://example.com?q=test"))
			assert ("ftp", patterns.is_url ("ftp://files.example.com"))
		end

	test_url_invalid
			-- Test invalid URLs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("no_protocol", not patterns.is_url ("example.com"))
			assert ("invalid_protocol", not patterns.is_url ("htp://example.com"))
		end

	test_domain_valid
			-- Test valid domain names
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_domain ("example.com"))
			assert ("subdomain", patterns.is_domain ("sub.example.com"))
			assert ("long", patterns.is_domain ("very-long-subdomain.example.co.uk"))
		end

feature -- Network Tests

	test_ipv4_valid
			-- Test valid IPv4 addresses
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("localhost", patterns.is_ipv4 ("127.0.0.1"))
			assert ("private", patterns.is_ipv4 ("192.168.1.1"))
			assert ("max", patterns.is_ipv4 ("255.255.255.255"))
			assert ("min", patterns.is_ipv4 ("0.0.0.0"))
		end

	test_ipv4_invalid
			-- Test invalid IPv4 addresses
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("too_high", not patterns.is_ipv4 ("256.0.0.1"))
			assert ("too_few_octets", not patterns.is_ipv4 ("192.168.1"))
			assert ("too_many_octets", not patterns.is_ipv4 ("192.168.1.1.1"))
			assert ("letters", not patterns.is_ipv4 ("192.168.a.1"))
		end

	test_mac_address_valid
			-- Test valid MAC addresses
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("colon_format", patterns.is_mac_address ("00:1A:2B:3C:4D:5E"))
			assert ("dash_format", patterns.is_mac_address ("00-1A-2B-3C-4D-5E"))
			assert ("lowercase", patterns.is_mac_address ("00:1a:2b:3c:4d:5e"))
		end

feature -- Phone Tests

	test_phone_us_valid
			-- Test valid US phone numbers
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("with_parens", patterns.is_phone_us ("(123) 456-7890"))
			assert ("dashes", patterns.is_phone_us ("123-456-7890"))
			assert ("plain", patterns.is_phone_us ("1234567890"))
			assert ("with_1", patterns.is_phone_us ("+1 123-456-7890"))
		end

	test_phone_us_invalid
			-- Test invalid US phone numbers
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("too_short", not patterns.is_phone_us ("123-456"))
			assert ("too_long", not patterns.is_phone_us ("123-456-78901"))
		end

feature -- Date Tests

	test_date_iso_valid
			-- Test valid ISO dates
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("standard", patterns.is_date_iso ("2024-12-06"))
			assert ("january", patterns.is_date_iso ("2024-01-01"))
			assert ("december", patterns.is_date_iso ("2024-12-31"))
		end

	test_date_iso_invalid
			-- Test invalid ISO dates
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("month_13", not patterns.is_date_iso ("2024-13-01"))
			assert ("day_32", not patterns.is_date_iso ("2024-01-32"))
			assert ("wrong_format", not patterns.is_date_iso ("12-06-2024"))
		end

	test_date_us_valid
			-- Test valid US dates
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("standard", patterns.is_date_us ("12/06/2024"))
			assert ("january", patterns.is_date_us ("01/01/2024"))
		end

	test_date_eu_valid
			-- Test valid EU dates
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("slash", patterns.is_date_eu ("06/12/2024"))
			assert ("dot", patterns.is_date_eu ("06.12.2024"))
		end

	test_datetime_iso_valid
			-- Test valid ISO datetimes
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("basic", patterns.is_datetime_iso ("2024-12-06T14:30:00"))
			assert ("with_z", patterns.is_datetime_iso ("2024-12-06T14:30:00Z"))
			assert ("with_offset", patterns.is_datetime_iso ("2024-12-06T14:30:00+05:30"))
		end

feature -- Time Tests

	test_time_24h_valid
			-- Test valid 24-hour times
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("midnight", patterns.is_time_24h ("00:00"))
			assert ("noon", patterns.is_time_24h ("12:00"))
			assert ("evening", patterns.is_time_24h ("23:59"))
			assert ("with_seconds", patterns.is_time_24h ("14:30:45"))
		end

	test_time_24h_invalid
			-- Test invalid 24-hour times
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("hour_25", not patterns.is_time_24h ("25:00"))
			assert ("minute_60", not patterns.is_time_24h ("12:60"))
		end

	test_time_12h_valid
			-- Test valid 12-hour times
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("morning", patterns.is_time_12h ("9:30 AM"))
			assert ("afternoon", patterns.is_time_12h ("2:45 PM"))
			assert ("lowercase", patterns.is_time_12h ("10:00 am"))
		end

feature -- Financial Tests

	test_credit_card_valid
			-- Test valid credit card formats
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("plain", patterns.is_credit_card ("1234567890123456"))
			assert ("spaces", patterns.is_credit_card ("1234 5678 9012 3456"))
			assert ("dashes", patterns.is_credit_card ("1234-5678-9012-3456"))
		end

	test_currency_valid
			-- Test valid currency amounts
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_currency ("123.45"))
			assert ("with_dollar", patterns.is_currency ("$123.45"))
			assert ("with_commas", patterns.is_currency ("$1,234.56"))
			assert ("negative", patterns.is_currency ("-$99.99"))
		end

feature -- Identifier Tests

	test_uuid_valid
			-- Test valid UUIDs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("standard", patterns.is_uuid ("550e8400-e29b-41d4-a716-446655440000"))
			assert ("uppercase", patterns.is_uuid ("550E8400-E29B-41D4-A716-446655440000"))
		end

	test_uuid_invalid
			-- Test invalid UUIDs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("too_short", not patterns.is_uuid ("550e8400-e29b-41d4-a716"))
			assert ("no_dashes", not patterns.is_uuid ("550e8400e29b41d4a716446655440000"))
		end

	test_hex_color_valid
			-- Test valid hex colors
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("six_digit", patterns.is_hex_color ("#FFFFFF"))
			assert ("three_digit", patterns.is_hex_color ("#FFF"))
			assert ("lowercase", patterns.is_hex_color ("#abc123"))
		end

	test_hex_color_invalid
			-- Test invalid hex colors
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("no_hash", not patterns.is_hex_color ("FFFFFF"))
			assert ("four_digit", not patterns.is_hex_color ("#FFFF"))
		end

	test_username_valid
			-- Test valid usernames
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_username ("john"))
			assert ("with_underscore", patterns.is_username ("john_doe"))
			assert ("with_numbers", patterns.is_username ("user123"))
		end

	test_username_invalid
			-- Test invalid usernames
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("starts_number", not patterns.is_username ("123user"))
			assert ("too_short", not patterns.is_username ("ab"))
			assert ("special_char", not patterns.is_username ("user@name"))
		end

	test_slug_valid
			-- Test valid slugs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_slug ("hello"))
			assert ("with_hyphen", patterns.is_slug ("hello-world"))
			assert ("with_numbers", patterns.is_slug ("post-123"))
		end

	test_slug_invalid
			-- Test invalid slugs
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("uppercase", not patterns.is_slug ("Hello-World"))
			assert ("underscore", not patterns.is_slug ("hello_world"))
			assert ("double_hyphen", not patterns.is_slug ("hello--world"))
		end

feature -- Security Tests

	test_strong_password_valid
			-- Test valid strong passwords
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("complex", patterns.is_strong_password ("MyP@ssw0rd"))
			assert ("longer", patterns.is_strong_password ("Str0ng!Pass"))
		end

	test_strong_password_invalid
			-- Test invalid strong passwords
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("no_special", not patterns.is_strong_password ("MyPassw0rd"))
			assert ("no_number", not patterns.is_strong_password ("MyP@ssword"))
			assert ("no_upper", not patterns.is_strong_password ("myp@ssw0rd"))
			assert ("too_short", not patterns.is_strong_password ("P@ss1"))
		end

	test_medium_password_valid
			-- Test valid medium passwords
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_medium_password ("pass123"))
			assert ("longer", patterns.is_medium_password ("mypassword1"))
		end

feature -- US-Specific Tests

	test_zip_code_valid
			-- Test valid US ZIP codes
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("five_digit", patterns.is_zip_code_us ("12345"))
			assert ("zip_plus_4", patterns.is_zip_code_us ("12345-6789"))
		end

	test_ssn_valid
			-- Test valid SSN format
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("standard", patterns.is_ssn ("123-45-6789"))
		end

	test_ssn_invalid
			-- Test invalid SSN format
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("no_dashes", not patterns.is_ssn ("123456789"))
			assert ("wrong_dashes", not patterns.is_ssn ("12-345-6789"))
		end

feature -- Number Tests

	test_integer_valid
			-- Test valid integers
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("positive", patterns.is_integer ("123"))
			assert ("negative", patterns.is_integer ("-456"))
			assert ("zero", patterns.is_integer ("0"))
		end

	test_decimal_valid
			-- Test valid decimals
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("simple", patterns.is_decimal ("123.45"))
			assert ("negative", patterns.is_decimal ("-123.45"))
			assert ("integer", patterns.is_decimal ("123"))
		end

	test_scientific_notation_valid
			-- Test valid scientific notation
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("positive_exp", patterns.is_scientific_notation ("1.23e10"))
			assert ("negative_exp", patterns.is_scientific_notation ("4.5E-6"))
			assert ("uppercase", patterns.is_scientific_notation ("1E5"))
		end

	test_hex_number_valid
			-- Test valid hex numbers
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("with_prefix", patterns.is_hex_number ("0xFF"))
			assert ("without_prefix", patterns.is_hex_number ("FF"))
			assert ("lowercase", patterns.is_hex_number ("0x1a2b"))
		end

feature -- Text Tests

	test_alphanumeric_valid
			-- Test alphanumeric validation
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("letters_only", patterns.is_alphanumeric ("Hello"))
			assert ("numbers_only", patterns.is_alphanumeric ("123"))
			assert ("mixed", patterns.is_alphanumeric ("Hello123"))
		end

	test_alphanumeric_invalid
			-- Test alphanumeric rejection
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("with_space", not patterns.is_alphanumeric ("Hello World"))
			assert ("with_special", not patterns.is_alphanumeric ("Hello!"))
		end

	test_alphabetic_valid
			-- Test alphabetic validation
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("lowercase", patterns.is_alphabetic ("hello"))
			assert ("uppercase", patterns.is_alphabetic ("HELLO"))
			assert ("mixed", patterns.is_alphabetic ("Hello"))
		end

	test_whitespace_only
			-- Test whitespace-only detection
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("spaces", patterns.is_whitespace_only ("   "))
			assert ("tabs", patterns.is_whitespace_only ("%T%T"))
			assert ("empty", patterns.is_whitespace_only (""))
			assert ("not_whitespace", not patterns.is_whitespace_only ("hello"))
		end

feature -- File Tests

	test_extract_extension
			-- Test file extension extraction
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("txt", attached patterns.extract_extension ("file.txt") as ext and then ext.same_string ("txt"))
			assert ("multiple_dots", attached patterns.extract_extension ("file.name.tar.gz") as ext and then ext.same_string ("gz"))
			assert ("no_extension", patterns.extract_extension ("filename") = Void)
		end

	test_unix_path_valid
			-- Test valid Unix paths
		local
			patterns: SIMPLE_REGEX_PATTERNS
		do
			create patterns.make
			assert ("absolute", patterns.is_unix_path ("/home/user/file.txt"))
			assert ("root", patterns.is_unix_path ("/root"))
		end

end
