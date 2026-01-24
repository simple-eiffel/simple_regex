# 7S-01: SCOPE - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Problem Domain

### 1.1 What Problem Does This Library Solve?
SIMPLE_REGEX provides a high-level, user-friendly regular expression API for Eiffel, wrapping Gobo's PCRE implementation. It simplifies regex operations while providing advanced features like pattern caching, fluent builders, and common pattern validation.

### 1.2 Who Needs This?
- Developers needing text pattern matching
- Input validation implementations
- Text parsing and extraction
- Search and replace operations

### 1.3 What Exists Already?
- Gobo's RX_PCRE_REGULAR_EXPRESSION (powerful but low-level)
- No built-in high-level regex API in EiffelBase

## 2. Scope Definition

### 2.1 IN Scope
- Pattern compilation with caching
- Matching (first, all matches)
- Replacement (first, all)
- Splitting by pattern
- Fluent options (caseless, multiline, dotall)
- Fluent pattern builder
- Common pattern library (email, URL, phone, etc.)
- Match result objects with groups
- Pattern validation and complexity scoring
- Zero-configuration facade for beginners

### 2.2 OUT of Scope
- Named groups (Gobo limitation)
- Custom regex engines
- Non-PCRE syntax support

## 3. Success Criteria

- Simplified API compared to raw Gobo
- Pattern caching for performance
- Rich match results with group access
- ReDoS risk detection
- Common patterns validated against real-world data
