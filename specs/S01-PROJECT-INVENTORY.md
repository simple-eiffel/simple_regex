# S01: PROJECT INVENTORY - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Project Structure

```
simple_regex/
  src/
    simple_regex.e               # Main regex facade
    simple_regex_builder.e       # Fluent pattern builder
    simple_regex_patterns.e      # Common pattern library
    simple_regex_match.e         # Match result
    simple_regex_match_list.e    # Match collection
    simple_regex_quick.e         # Zero-config facade
  testing/
    lib_tests.e                  # Test suite
    test_app.e                   # Test runner
    simple_regex_test.e          # Main tests
    simple_regex_builder_test.e  # Builder tests
    simple_regex_patterns_test.e # Pattern tests
  gobo_tests/
    gobo_test_runner.e           # Gobo capability runner
    gobo_capability_test.e       # Gobo feature tests
  research/
  specs/
  simple_regex.ecf
```

## 2. Source Files

| File | Purpose | Lines |
|------|---------|-------|
| simple_regex.e | Main facade | ~590 |
| simple_regex_builder.e | Pattern builder | ~740 |
| simple_regex_patterns.e | Pattern library | ~550 |
| simple_regex_match.e | Match result | ~215 |
| simple_regex_match_list.e | Match collection | ~165 |
| simple_regex_quick.e | Quick facade | ~235 |

## 3. Dependencies

### 3.1 External Libraries
| Library | Purpose |
|---------|---------|
| Gobo (regexp) | PCRE regex engine |

### 3.2 EiffelBase Dependencies
- ARRAYED_LIST: Collections
- HASH_TABLE: Pattern cache
- STRING_32: Unicode strings
