# S02: CLASS CATALOG - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Class Overview

| Class | Type | Purpose |
|-------|------|---------|
| SIMPLE_REGEX | Effective | Main regex facade |
| SIMPLE_REGEX_BUILDER | Effective | Fluent pattern builder |
| SIMPLE_REGEX_PATTERNS | Effective | Common pattern library |
| SIMPLE_REGEX_MATCH | Effective | Single match result |
| SIMPLE_REGEX_MATCH_LIST | Effective | Match collection |
| SIMPLE_REGEX_QUICK | Effective | Zero-config facade |

## 2. Class Details

### 2.1 SIMPLE_REGEX
**Purpose**: High-level regex API with caching.
- Pattern compilation
- Matching (first, all)
- Replacement
- Splitting
- Fluent options
- Pattern validation
- Complexity scoring

### 2.2 SIMPLE_REGEX_BUILDER
**Purpose**: Fluent pattern construction.
- Literal and raw patterns
- Character classes
- Quantifiers
- Groups (capturing, non-capturing, atomic)
- Anchors
- Lookahead/lookbehind
- Backreferences
- Recursion and conditionals

### 2.3 SIMPLE_REGEX_PATTERNS
**Purpose**: Pre-built common patterns.
Categories:
- Email and web
- Network (IP, MAC)
- Phone numbers
- Dates and times
- Financial
- Identifiers
- Security (passwords)
- Markup
- Files

### 2.4 SIMPLE_REGEX_MATCH
**Purpose**: Single match result.
- Match value and position
- Captured groups
- Context (before/after)
- MML model contracts

### 2.5 SIMPLE_REGEX_MATCH_LIST
**Purpose**: Collection of matches.
- Iteration
- Conversion to strings
- MML model contracts

### 2.6 SIMPLE_REGEX_QUICK
**Purpose**: Simplified one-liner API.
- matches, find, find_all
- replace, replace_all
- split
- Common shortcuts (is_email, is_url)
