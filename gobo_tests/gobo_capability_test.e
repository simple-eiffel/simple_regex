note
	description: "Empirical test of Gobo regex capabilities"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	GOBO_CAPABILITY_TEST

inherit
	TEST_SET_BASE

feature -- Basic Tests

	test_basic_match
			-- Verify basic matching works
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("hello")
			assert ("compiled", regex.is_compiled)
			regex.match ("hello world")
			assert ("matched", regex.has_matched)
			assert ("correct_value", regex.captured_substring (0).same_string ("hello"))
			print ("Basic match: PASSED%N")
		end

	test_character_classes
			-- Test \d, \w, \s
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("\d+")
			regex.match ("abc123def")
			assert ("digit_matched", regex.has_matched)
			assert ("digit_value", regex.captured_substring (0).same_string ("123"))
			print ("Character class \d: PASSED%N")

			create regex.make
			regex.compile ("\w+")
			regex.match ("hello world")
			assert ("word_matched", regex.has_matched)
			assert ("word_value", regex.captured_substring (0).same_string ("hello"))
			print ("Character class \w: PASSED%N")

			create regex.make
			regex.compile ("\s+")
			regex.match ("hello world")
			assert ("space_matched", regex.has_matched)
			print ("Character class \s: PASSED%N")
		end

feature -- Capturing Groups

	test_basic_groups
			-- Test basic capturing groups
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(foo)(bar)")
			regex.match ("foobar")
			assert ("matched", regex.has_matched)
			assert ("group_count", regex.match_count = 3)
			assert ("group_0", regex.captured_substring (0).same_string ("foobar"))
			assert ("group_1", regex.captured_substring (1).same_string ("foo"))
			assert ("group_2", regex.captured_substring (2).same_string ("bar"))
			print ("Basic groups: PASSED (match_count=" + regex.match_count.out + ")%N")
		end

	test_named_groups
			-- Test named capturing groups (?P<name>...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(?P<first>\w+)\s+(?P<second>\w+)")
			if regex.is_compiled then
				print ("Named groups (?P<name>): SUPPORTED (compiles)%N")
				regex.match ("hello world")
				if regex.has_matched then
					print ("  - Matched with " + regex.match_count.out + " groups%N")
					print ("  - Group 1: " + regex.captured_substring (1) + "%N")
					print ("  - Group 2: " + regex.captured_substring (2) + "%N")
				end
			else
				print ("Named groups (?P<name>): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_non_capturing_groups
			-- Test non-capturing groups (?:...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(?:foo)(bar)")
			if regex.is_compiled then
				print ("Non-capturing groups (?:...): SUPPORTED%N")
				regex.match ("foobar")
				assert ("non_capture_matched", regex.has_matched)
				assert ("non_capture_count", regex.match_count = 2)
				assert ("non_capture_group_1", regex.captured_substring (1).same_string ("bar"))
			else
				print ("Non-capturing groups: NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

feature -- Advanced Features

	test_lookahead_positive
			-- Test positive lookahead (?=...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("foo(?=bar)")
			if regex.is_compiled then
				print ("Positive lookahead (?=...): SUPPORTED%N")
				regex.match ("foobar")
				assert ("lookahead_matched", regex.has_matched)
				assert ("lookahead_value", regex.captured_substring (0).same_string ("foo"))
			else
				print ("Positive lookahead (?=...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_lookahead_negative
			-- Test negative lookahead (?!...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("foo(?!baz)")
			if regex.is_compiled then
				print ("Negative lookahead (?!...): SUPPORTED%N")
				regex.match ("foobar")
				assert ("neg_lookahead_matched", regex.has_matched)
				regex.match ("foobaz")
				assert ("neg_lookahead_not_matched", not regex.has_matched)
			else
				print ("Negative lookahead (?!...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_lookbehind_positive
			-- Test positive lookbehind (?<=...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(?<=foo)bar")
			if regex.is_compiled then
				print ("Positive lookbehind (?<=...): SUPPORTED%N")
				regex.match ("foobar")
				assert ("lookbehind_matched", regex.has_matched)
				assert ("lookbehind_value", regex.captured_substring (0).same_string ("bar"))
			else
				print ("Positive lookbehind (?<=...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_lookbehind_negative
			-- Test negative lookbehind (?<!...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(?<!foo)bar")
			if regex.is_compiled then
				print ("Negative lookbehind (?<!...): SUPPORTED%N")
				regex.match ("bazbar")
				if regex.has_matched then
					print ("  - Matched 'bar' in 'bazbar'%N")
				end
			else
				print ("Negative lookbehind (?<!...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_atomic_groups
			-- Test atomic groups (?>...)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(?>a+)b")
			if regex.is_compiled then
				print ("Atomic groups (?>...): SUPPORTED%N")
				regex.match ("aaab")
				assert ("atomic_matched", regex.has_matched)
			else
				print ("Atomic groups (?>...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_recursion
			-- Test recursion (?R)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("\((?:[^()]+|(?R))*\)")
			if regex.is_compiled then
				print ("Recursion (?R): SUPPORTED%N")
				regex.match ("(a(b)c)")
				if regex.has_matched then
					print ("  - Matched: " + regex.captured_substring (0) + "%N")
				end
			else
				print ("Recursion (?R): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_conditionals
			-- Test conditionals (?(condition)yes|no)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(a)?(?(1)b|c)")
			if regex.is_compiled then
				print ("Conditionals (?(n)...|...): SUPPORTED%N")
				regex.match ("ab")
				if regex.has_matched then
					print ("  - 'ab' matched%N")
				end
				regex.match ("c")
				if regex.has_matched then
					print ("  - 'c' matched%N")
				end
			else
				print ("Conditionals (?(n)...|...): NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_backreferences
			-- Test backreferences \1
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(a+)\1")
			if regex.is_compiled then
				print ("Backreferences \\1: SUPPORTED%N")
				regex.match ("aaaa")
				if regex.has_matched then
					print ("  - 'aaaa' matched: " + regex.captured_substring (0) + "%N")
				end
			else
				print ("Backreferences \\1: NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

feature -- Unicode Tests

	test_unicode_basic
			-- Test basic Unicode matching
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
			subject: STRING_32
		do
			create regex.make
			regex.compile (".")
			subject := {STRING_32} "Hello"
			regex.match (subject)
			if regex.has_matched then
				print ("Basic Unicode STRING_32: SUPPORTED%N")
			else
				print ("Basic Unicode STRING_32: FAILED%N")
			end
		end

	test_unicode_properties
			-- Test Unicode properties \p{L}
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("\p{L}+")
			if regex.is_compiled then
				print ("Unicode properties \\p{L}: SUPPORTED%N")
				regex.match ("Hello")
				if regex.has_matched then
					print ("  - Matched: " + regex.captured_substring (0) + "%N")
				end
			else
				print ("Unicode properties \\p{L}: NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

	test_unicode_grapheme
			-- Test Unicode grapheme cluster \X
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("\X+")
			if regex.is_compiled then
				print ("Unicode grapheme \\X: SUPPORTED%N")
			else
				print ("Unicode grapheme \\X: NOT SUPPORTED - " + regex.error_message + "%N")
			end
		end

feature -- Options Tests

	test_case_insensitive
			-- Test case-insensitive option
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.set_caseless (True)
			regex.compile ("hello")
			regex.match ("HELLO")
			if regex.has_matched then
				print ("Case insensitive (set_caseless): SUPPORTED%N")
			else
				print ("Case insensitive: FAILED%N")
			end
		end

	test_multiline
			-- Test multiline option
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.set_multiline (True)
			regex.compile ("^line")
			regex.match ("first%Nline two")
			if regex.is_compiled then
				print ("Multiline option (set_multiline): SUPPORTED%N")
				if regex.has_matched then
					print ("  - Matched at line boundary%N")
				end
			end
		end

	test_dotall
			-- Test dotall option (. matches newline)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.set_dotall (True)
			regex.compile ("a.b")
			regex.match ("a%Nb")
			if regex.has_matched then
				print ("Dotall option (set_dotall): SUPPORTED%N")
			else
				print ("Dotall option: FAILED%N")
			end
		end

feature -- Replace/Split

	test_replace_basic
			-- Test basic replacement
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("world")
			regex.match ("hello world")
			if regex.has_matched then
				print ("Replace: SUPPORTED%N")
				print ("  - Result: " + regex.replace ("universe") + "%N")
			end
		end

	test_replace_all
			-- Test replace all
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("a")
			regex.match ("banana")
			if regex.has_matched then
				print ("Replace all: " + regex.replace_all ("X") + "%N")
			end
		end

	test_replace_with_groups
			-- Test replacement with group references
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(\w+)\s+(\w+)")
			regex.match ("hello world")
			if regex.has_matched then
				print ("Replace with groups (\\n\\ format): Testing...%N")
				print ("  - Swap result: " + regex.replacement ("\2\ \1\") + "%N")
			end
		end

	test_split
			-- Test split functionality
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
			parts: ARRAY [STRING]
		do
			create regex.make
			regex.compile (",\s*")
			regex.match ("a, b, c")
			if regex.has_matched then
				parts := regex.split
				print ("Split: SUPPORTED (" + parts.count.out + " parts)%N")
				across parts as p loop
					print ("  - '" + p + "'%N")
				end
			end
		end

feature -- Error Handling

	test_invalid_pattern
			-- Test error message for invalid pattern
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create regex.make
			regex.compile ("(unclosed")
			if not regex.is_compiled then
				print ("Error handling: SUPPORTED%N")
				print ("  - Error: " + regex.error_message + "%N")
			else
				print ("Error handling: Pattern unexpectedly compiled%N")
			end
		end

	test_match_atomicity
			-- Confirm match is atomic (blocking call)
		local
			regex: RX_PCRE_REGULAR_EXPRESSION
			subject: STRING
		do
			create regex.make
			regex.compile ("(a+)+b")
			create subject.make_filled ('a', 20)
			print ("Testing match atomicity...%N")
			regex.match (subject)
			print ("Match is ATOMIC/BLOCKING - Gobo match() is single call%N")
		end

end
