# 7S-04: SIMPLE-STAR - simple_regex


**Date**: 2026-01-23

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Ecosystem Integration

### 1.1 Dependencies
| Library | Purpose |
|---------|---------|
| Gobo (regexp) | PCRE engine |

### 1.2 Dependents
Libraries that may use simple_regex:
- simple_json (JSON path matching)
- simple_http (URL routing)
- simple_config (configuration parsing)
- Any validation framework

## 2. Simple Ecosystem Patterns

### 2.1 Naming
- Main class: SIMPLE_REGEX
- Builder: SIMPLE_REGEX_BUILDER
- Patterns: SIMPLE_REGEX_PATTERNS
- Match: SIMPLE_REGEX_MATCH
- Quick: SIMPLE_REGEX_QUICK

### 2.2 Structure
```
simple_regex/
  src/
    simple_regex.e
    simple_regex_builder.e
    simple_regex_patterns.e
    simple_regex_match.e
    simple_regex_match_list.e
    simple_regex_quick.e
  testing/
    lib_tests.e
    test_app.e
    simple_regex_test.e
    simple_regex_builder_test.e
    simple_regex_patterns_test.e
  gobo_tests/
    gobo_test_runner.e
    gobo_capability_test.e
  simple_regex.ecf
```

## 3. Reuse Opportunities

### 3.1 Pattern Library
Pre-built patterns reusable across applications:
- Email validation
- URL validation
- Phone numbers
- Dates
- Financial data

### 3.2 Builder Pattern
Reusable fluent builder approach for other domain-specific builders.
