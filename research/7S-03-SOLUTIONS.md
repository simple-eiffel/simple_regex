# 7S-03: SOLUTIONS - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Existing Solutions Evaluated

### 1.1 Gobo RX_PCRE_REGULAR_EXPRESSION
- **Pros**: Full PCRE support, well-tested
- **Cons**: Low-level API, no caching, verbose
- **Decision**: Wrap with high-level facade

### 1.2 Raw C PCRE Library
- **Pros**: Maximum performance
- **Cons**: C integration complexity
- **Decision**: Use Gobo (already Eiffel-integrated)

## 2. Chosen Approach

### 2.1 Architecture
Multi-class design with specialized responsibilities:
- SIMPLE_REGEX: Main facade, caching, operations
- SIMPLE_REGEX_BUILDER: Fluent pattern construction
- SIMPLE_REGEX_PATTERNS: Common pattern library
- SIMPLE_REGEX_MATCH: Single match result
- SIMPLE_REGEX_MATCH_LIST: Collection of matches
- SIMPLE_REGEX_QUICK: Zero-config facade

### 2.2 Key Design Decisions

1. **Pattern caching**: Once-compiled patterns reused
2. **Fluent options**: Immutable option chaining
3. **Rich results**: Group access, context, position
4. **Builder pattern**: Type-safe pattern construction
5. **Pattern library**: Pre-built common validations
6. **Complexity scoring**: ReDoS risk detection

### 2.3 Trade-offs
- Named groups not supported (Gobo limitation)
- Fluent options create new objects (immutability trade-off)
- Pattern library may not cover all edge cases
