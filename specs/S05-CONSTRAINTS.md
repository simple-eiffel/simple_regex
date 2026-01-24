# S05: CONSTRAINTS - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Technical Constraints

### 1.1 Platform Constraints
- **EiffelStudio**: Requires EiffelStudio 25.02 or compatible
- **Gobo**: Requires Gobo library (regexp)

### 1.2 Gobo Limitations
- Named groups NOT supported: `(?P<name>...)` does not work
- Use indexed group access instead

## 2. Design Constraints

### 2.1 Builder Constraints
- Groups must be balanced (open_group_count = 0) before to_regex
- Quantifiers require preceding quantifiable element
- Anchors are not quantifiable

### 2.2 Pattern Cache Constraints
- Maximum cache size: 1000 patterns
- No automatic eviction (overflow stops caching)
- Cache is global (once function)

## 3. Performance Constraints

### 3.1 Pattern Complexity
| Complexity Score | Risk Level |
|------------------|------------|
| 1-3 | Low |
| 4-6 | Medium |
| 7-10 | High (potentially dangerous) |

### 3.2 Factors Affecting Complexity
- Nested quantifiers
- Multiple alternations
- Backreferences with quantifiers

## 4. Safety Constraints

### 4.1 ReDoS Prevention
- Check pattern_complexity before compiling user patterns
- Dangerous_complexity_threshold = 7 (default)
- Use escape() for literal user input

### 4.2 Pattern Validation
- Always check is_valid_pattern for user input
- Check is_compiled after compile()
- Handle last_error if compilation fails
