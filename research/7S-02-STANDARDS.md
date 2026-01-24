# 7S-02: STANDARDS - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Applicable Standards

### 1.1 PCRE (Perl Compatible Regular Expressions)
- Industry standard regex syntax
- Gobo provides PCRE implementation
- Supports most PCRE features

### 1.2 Gobo Capabilities (Empirically Verified)
Supported:
- Basic matching, character classes (\d, \w, \s)
- Capturing groups, non-capturing groups (?:...)
- Lookahead (?=...), (?!...) and lookbehind (?<=...), (?<!...)
- Atomic groups (?>...), recursion (?R), conditionals (?(n)...|...)
- Backreferences \1, Unicode properties \p{L}, graphemes \X

Not Supported:
- Named groups (?P<name>...) - use indexed access instead

## 2. Pattern Validation Standards

### 2.1 Email Pattern
- Based on RFC 5321/5322 simplified subset
- Handles common formats

### 2.2 URL Pattern
- HTTP, HTTPS, FTP protocols
- Standard URL structure

### 2.3 IPv4 Pattern
- Standard dotted decimal notation
- Range validation (0-255)

## 3. Eiffel Standards

### 3.1 Design by Contract
- Compilation state contracts
- Match result contracts
- Builder balanced group contracts

### 3.2 Void Safety
- Full void safety compliance
- Detachable for optional results

### 3.3 MML (Mathematical Model Library)
- SIMPLE_REGEX_MATCH and MATCH_LIST use MML_SEQUENCE
- Model-based contracts
