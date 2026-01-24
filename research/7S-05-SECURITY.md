# 7S-05: SECURITY - simple_regex


**Date**: 2026-01-23

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Security Considerations

### 1.1 ReDoS (Regular Expression Denial of Service)
Malicious or poorly-written patterns can cause exponential backtracking:
- Nested quantifiers: `(a+)+`
- Alternation with overlap: `(a|a)+`
- Backreferences with quantifiers: `(a*)\1+`

### 1.2 Built-in Protection
The library includes ReDoS detection:
- `pattern_complexity(pattern)`: Scores 1-10
- `is_potentially_dangerous(pattern)`: Threshold check
- `Dangerous_complexity_threshold`: Default 7

### 1.3 Using the Protection
```eiffel
regex: SIMPLE_REGEX
if regex.pattern_complexity (user_pattern) >= 7 then
    -- Reject pattern as potentially dangerous
else
    -- Safe to use
end
```

## 2. Input Validation

### 2.1 Pattern Validation
```eiffel
if regex.is_valid_pattern (user_pattern) then
    regex.compile (user_pattern)
end
```

### 2.2 Pattern Escaping
For literal matching of user input:
```eiffel
safe_pattern := regex.escape (user_input)
```

## 3. Recommendations

### 3.1 User-Supplied Patterns
1. Always validate pattern syntax
2. Check complexity score
3. Set execution timeouts (if available)
4. Consider whitelisting allowed patterns

### 3.2 Pre-built Patterns
- Use SIMPLE_REGEX_PATTERNS when possible
- Pre-built patterns are tested and safe

### 3.3 Sensitive Data
- Patterns may log/expose matched content
- Be careful with sensitive data in subjects
