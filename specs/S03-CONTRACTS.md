# S03: CONTRACTS - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. SIMPLE_REGEX Contracts

```eiffel
-- make_from_pattern
ensure
    pattern_set: attached pattern as p and then p.same_string_general (a_pattern)

-- compile
ensure
    compiled_xor_error: is_compiled xor (not last_error.is_empty)
    pattern_stored: attached pattern as p and then p.same_string_general (a_pattern)

-- match, find_all, replace, etc.
require
    compiled: is_compiled
ensure
    result_attached: Result /= Void

-- split
ensure
    result_attached: Result /= Void
    at_least_one: Result.count >= 1

-- case_insensitive, multiline, dotall
ensure
    result_attached: Result /= Void
    new_object: Result /= Current
    option_set: Result.is_caseless / is_multiline / is_dotall

-- pattern_complexity
ensure
    valid_range: Result >= 1 and Result <= 10

invariant
    last_error_attached: last_error /= Void
```

## 2. SIMPLE_REGEX_BUILDER Contracts

```eiffel
-- make
ensure
    empty_pattern: pattern.is_empty
    no_open_groups: open_group_count = 0

-- to_regex
require
    balanced_groups: open_group_count = 0
ensure
    result_attached: Result /= Void

-- literal, raw, etc.
ensure
    result_is_current: Result = Current
    has_quantifiable: condition implies has_quantifiable_element

-- quantifiers (zero_or_more, one_or_more, etc.)
require
    has_element: has_quantifiable_element
ensure
    result_is_current: Result = Current
    not_quantifiable: not has_quantifiable_element

-- group_start
ensure
    group_opened: open_group_count = old open_group_count + 1

-- group_end
require
    has_open_group: open_group_count > 0
ensure
    group_closed: open_group_count = old open_group_count - 1
    has_quantifiable: has_quantifiable_element

invariant
    pattern_attached: internal_pattern /= Void
    non_negative_groups: open_group_count >= 0
```

## 3. SIMPLE_REGEX_MATCH Contracts

```eiffel
-- make_matched
require
    valid_positions: a_start >= 1 and a_start <= a_end + 1
ensure
    matched: is_matched

-- value, length, group, text_before, text_after
require
    matched: is_matched

-- group
require
    valid_index: n >= 0 and n <= group_count

-- group_count
ensure
    non_negative: Result >= 0
    model_consistent: Result = (groups_model.count - 1).max (0)

invariant
    subject_attached: subject /= Void
    matched_has_value: is_matched implies internal_value.count >= 0
    positions_valid: is_matched implies (start_position >= 1 and start_position <= end_position + 1)
```

## 4. SIMPLE_REGEX_MATCH_LIST Contracts

```eiffel
-- make
ensure
    subject_set: subject = a_subject
    empty: is_empty
    model_empty: model.is_empty

-- item
require
    valid_index: i >= 1 and i <= count
ensure
    model_consistent: Result = model [i]

-- extend
ensure
    count_increased: count = old count + 1
    model_extended: model |=| (old model.deep_twin & a_match)

invariant
    subject_attached: subject /= Void
    count_non_negative: count >= 0
```
