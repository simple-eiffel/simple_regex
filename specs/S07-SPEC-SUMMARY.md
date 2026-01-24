# S07: SPEC SUMMARY - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. Library Overview

**Name**: simple_regex
**Purpose**: High-level regex API with caching, builder, and pattern library
**Status**: Production ready

## 2. Quick Reference

### 2.1 Basic Usage
```eiffel
regex: SIMPLE_REGEX
create regex.make_from_pattern ("[a-z]+")
match := regex.match ("hello world")
if match.is_matched then
    print (match.value)  -- "hello"
end
```

### 2.2 Options
```eiffel
regex := regex.case_insensitive.multiline
```

### 2.3 Pattern Builder
```eiffel
builder: SIMPLE_REGEX_BUILDER
create builder.make
builder.start_of_string
       .literal ("Hello")
       .whitespace.one_or_more
       .group_start
       .word_char.one_or_more
       .group_end
       .end_of_string
regex := builder.to_regex
```

### 2.4 Common Patterns
```eiffel
patterns: SIMPLE_REGEX_PATTERNS
create patterns.make
if patterns.is_email (input) then ...
if patterns.is_ipv4 (address) then ...
```

### 2.5 Quick Facade
```eiffel
rx: SIMPLE_REGEX_QUICK
create rx.make
if rx.is_email ("user@example.com") then ...
emails := rx.extract_emails (text)
```

## 3. Key Specifications

| Aspect | Specification |
|--------|---------------|
| Classes | 6 |
| Dependencies | Gobo (regexp) |
| Cache Size | 1000 patterns max |
| Thread Safety | Cache is shared |

## 4. Warnings

1. **Named groups not supported** (Gobo limitation)
2. **Check pattern complexity** for user-supplied patterns
3. **Cache is global** - shared across instances
4. **Fluent options create new objects** - don't discard
