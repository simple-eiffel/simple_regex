note
	description: "Runner for Gobo capability tests"
	date: "$Date$"

class
	GOBO_TEST_RUNNER

create
	make

feature {NONE} -- Initialization

	make
			-- Run all capability tests
		local
			tests: GOBO_CAPABILITY_TEST
		do
			print ("=== GOBO REGEX CAPABILITY TESTS ===%N%N")

			create tests

			print ("--- BASIC TESTS ---%N")
			run_test (agent tests.test_basic_match, "test_basic_match")
			run_test (agent tests.test_character_classes, "test_character_classes")

			print ("%N--- CAPTURING GROUPS ---%N")
			run_test (agent tests.test_basic_groups, "test_basic_groups")
			run_test (agent tests.test_named_groups, "test_named_groups")
			run_test (agent tests.test_non_capturing_groups, "test_non_capturing_groups")

			print ("%N--- ADVANCED FEATURES ---%N")
			run_test (agent tests.test_lookahead_positive, "test_lookahead_positive")
			run_test (agent tests.test_lookahead_negative, "test_lookahead_negative")
			run_test (agent tests.test_lookbehind_positive, "test_lookbehind_positive")
			run_test (agent tests.test_lookbehind_negative, "test_lookbehind_negative")
			run_test (agent tests.test_atomic_groups, "test_atomic_groups")
			run_test (agent tests.test_recursion, "test_recursion")
			run_test (agent tests.test_conditionals, "test_conditionals")
			run_test (agent tests.test_backreferences, "test_backreferences")

			print ("%N--- UNICODE TESTS ---%N")
			run_test (agent tests.test_unicode_basic, "test_unicode_basic")
			run_test (agent tests.test_unicode_properties, "test_unicode_properties")
			run_test (agent tests.test_unicode_grapheme, "test_unicode_grapheme")

			print ("%N--- OPTIONS TESTS ---%N")
			run_test (agent tests.test_case_insensitive, "test_case_insensitive")
			run_test (agent tests.test_multiline, "test_multiline")
			run_test (agent tests.test_dotall, "test_dotall")

			print ("%N--- REPLACE/SPLIT TESTS ---%N")
			run_test (agent tests.test_replace_basic, "test_replace_basic")
			run_test (agent tests.test_replace_all, "test_replace_all")
			run_test (agent tests.test_replace_with_groups, "test_replace_with_groups")
			run_test (agent tests.test_split, "test_split")

			print ("%N--- ERROR/MISC TESTS ---%N")
			run_test (agent tests.test_invalid_pattern, "test_invalid_pattern")
			run_test (agent tests.test_match_atomicity, "test_match_atomicity")

			print ("%N=== TESTS COMPLETE ===%N")
		end

feature {NONE} -- Implementation

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test with error handling
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
			end
		rescue
			print ("FAILED: " + a_name + " - Exception occurred%N")
			l_retried := True
			retry
		end

end
