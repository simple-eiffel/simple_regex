# S06: BOUNDARIES - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. API Boundaries

### 1.1 Public Interface (SIMPLE_REGEX)
- Creation, compilation
- Matching operations
- Replacement operations
- Splitting
- Options (fluent)
- Class methods (cached)
- Safety features

### 1.2 Internal Features
| Feature | Visibility | Purpose |
|---------|------------|---------|
| internal_regex | {NONE} | Gobo wrapper |
| create_match_result | {NONE} | Result creation |
| twin_with_options | {NONE} | Option cloning |
| apply_options | {NONE} | Apply to Gobo |
| is_special_char | {NONE} | Escape helper |
| cached_regex | {NONE} | Cache lookup |
| pattern_cache | {NONE} | Once cache |
| set_options | {SIMPLE_REGEX, SIMPLE_REGEX_BUILDER} | Internal setter |

### 1.3 Builder Internal Features
| Feature | Visibility | Purpose |
|---------|------------|---------|
| internal_pattern | {NONE} | Pattern storage |
| escape_class_chars | {NONE} | Class escaping |

## 2. Input Boundaries

### 2.1 Pattern Inputs
| Constraint | Validation |
|------------|------------|
| Pattern syntax | is_valid_pattern |
| Complexity | pattern_complexity |
| Safety | is_potentially_dangerous |

### 2.2 Builder Inputs
| Constraint | Validation |
|------------|------------|
| Character sets | not_empty (one_of, none_of) |
| Range | valid_range (from <= to) |
| Quantifiers | valid counts (min >= 0, max >= min) |
| Group numbers | valid (1-9 for backreference) |

## 3. Output Boundaries

### 3.1 Match Results
| Field | Range |
|-------|-------|
| is_matched | BOOLEAN |
| value | Non-empty if matched |
| start_position | >= 1 |
| end_position | >= start - 1 |
| group_count | >= 0 |

### 3.2 Match List
| Field | Range |
|-------|-------|
| count | >= 0 |
| is_empty | BOOLEAN |

### 3.3 Complexity Score
- Range: 1 to 10
- Threshold: 7 (default dangerous)
