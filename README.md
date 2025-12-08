<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_regex

**[Documentation](https://simple-eiffel.github.io/simple_regex/)** | **[GitHub](https://github.com/simple-eiffel/simple_regex)**

High-level regex library for Eiffel providing pattern matching, replacement, splitting, and a fluent builder API with pre-built validation patterns.

## Overview

`simple_regex` wraps Gobo's PCRE regex engine with a simpler API featuring:

- **Pattern matching** - Match, match all, with captured groups
- **Replacement** - Replace first, replace all, with group backreferences
- **Splitting** - Split strings by regex patterns
- **Fluent builder** - Construct patterns programmatically
- **Pre-built patterns** - Email, URL, IP, phone, date, UUID, and more
- **Safety features** - Pattern complexity analysis, ReDoS detection

Design influenced by:
- **Gobo Eiffel Regexp** - Underlying PCRE implementation
- **Java Pattern/Matcher** - API design patterns
- **JavaScript RegExp** - Convenience methods

## API Integration

`simple_regex` is part of the `simple_*` API hierarchy:

```
FOUNDATION_API (core utilities: json, uuid, base64, validation, regex, etc.)
       |
SERVICE_API (services: jwt, smtp, sql, cors, cache, websocket, pdf)
       |
APP_API (full application stack)
```

### Using via FOUNDATION_API

If your project uses `simple_foundation_api`, you automatically have access:

```eiffel
class MY_SERVICE
inherit
    FOUNDATION_API
feature
    validate_email (email: STRING): BOOLEAN
        do
            Result := is_valid_email_pattern (email)
        end

    extract_numbers (text: STRING): ARRAYED_LIST [STRING_32]
        do
            Result := regex_all_matches ("\d+", text)
        end
end
```

### Standalone Installation

1. Clone the repository
2. Set environment variable: `SIMPLE_REGEX=D:\path\to\simple_regex`
3. Add to your ECF:

```xml
<library name="simple_regex" location="$SIMPLE_REGEX\simple_regex.ecf"/>
```

## Quick Start

```eiffel
local
    regex: SIMPLE_REGEX
    match: SIMPLE_REGEX_MATCH
    matches: SIMPLE_REGEX_MATCH_LIST
do
    -- Basic matching
    create regex.make ("\d{3}-\d{4}")
    match := regex.match ("Call 555-1234 today")
    if match.is_matched then
        print (match.value)  -- "555-1234"
    end

    -- Find all matches
    create regex.make ("\w+@\w+\.\w+")
    matches := regex.match_all ("Contact: a@b.com, c@d.org")
    across matches as m loop
        print (m.value)  -- "a@b.com", "c@d.org"
    end

    -- Replace
    create regex.make ("\s+")
    print (regex.replace_all ("hello   world", " "))  -- "hello world"
end
```

## Classes

### SIMPLE_REGEX
Core regex engine with matching, replacement, and splitting.

```eiffel
create regex.make ("[A-Z]+")
create regex.make_case_insensitive ("[a-z]+")

-- Matching
match := regex.match (subject)
matches := regex.match_all (subject)

-- Replacement
result := regex.replace_first (subject, replacement)
result := regex.replace_all (subject, replacement)

-- Splitting
parts := regex.split (subject)

-- Options (immutable - returns new instance)
regex_i := regex.case_insensitive
regex_m := regex.multiline
regex_s := regex.dotall
```

### SIMPLE_REGEX_MATCH
Result of a match operation with group access.

```eiffel
if match.is_matched then
    print (match.value)           -- Full match
    print (match.start_position)  -- 1-based start
    print (match.end_position)    -- Inclusive end
    print (match.group (1))       -- First captured group
    print (match.text_before)     -- Text before match
    print (match.text_after)      -- Text after match
end
```

### SIMPLE_REGEX_MATCH_LIST
Collection of matches with iteration support.

```eiffel
matches := regex.match_all (subject)
print (matches.count)
across matches as m loop
    print (m.value)
end
strings := matches.as_strings  -- ARRAYED_LIST [STRING_32]
```

### SIMPLE_REGEX_BUILDER
Fluent API for building regex patterns programmatically.

```eiffel
local
    builder: SIMPLE_REGEX_BUILDER
    regex: SIMPLE_REGEX
do
    create builder.make
    builder := builder.start_of_string
    builder := builder.literal ("Hello")
    builder := builder.whitespace.one_or_more
    builder := builder.group (agent (b: SIMPLE_REGEX_BUILDER): SIMPLE_REGEX_BUILDER
        do
            Result := b.word_char.one_or_more
        end)
    builder := builder.end_of_string

    regex := builder.to_regex
    -- Pattern: ^Hello\s+(\w+)$
end
```

### SIMPLE_REGEX_PATTERNS
Pre-built patterns for common validation tasks.

```eiffel
local
    patterns: SIMPLE_REGEX_PATTERNS
do
    create patterns.make

    -- Validation
    if patterns.email.match ("user@example.com").is_matched then ... end
    if patterns.url.match ("https://example.com").is_matched then ... end
    if patterns.ipv4.match ("192.168.1.1").is_matched then ... end
    if patterns.uuid.match ("550e8400-e29b-41d4-a716-446655440000").is_matched then ... end

    -- US formats
    if patterns.phone_us.match ("(555) 123-4567").is_matched then ... end
    if patterns.zip_code.match ("12345-6789").is_matched then ... end
    if patterns.ssn.match ("123-45-6789").is_matched then ... end

    -- Dates and times
    if patterns.date_iso.match ("2025-12-07").is_matched then ... end
    if patterns.time_24h.match ("14:30:00").is_matched then ... end

    -- Security
    if patterns.strong_password.match ("P@ssw0rd!").is_matched then ... end
end
```

## Builder API Examples

```eiffel
-- Email pattern
builder := builder.start_of_string
builder := builder.one_of ("a-zA-Z0-9._%+-").one_or_more
builder := builder.literal ("@")
builder := builder.one_of ("a-zA-Z0-9.-").one_or_more
builder := builder.literal (".")
builder := builder.one_of ("a-zA-Z").between (2, 6)
builder := builder.end_of_string

-- Phone number with groups
builder := builder.literal ("(")
builder := builder.group (agent (b: SIMPLE_REGEX_BUILDER): SIMPLE_REGEX_BUILDER
    do Result := b.digit.exactly (3) end)
builder := builder.literal (") ")
builder := builder.group (agent (b: SIMPLE_REGEX_BUILDER): SIMPLE_REGEX_BUILDER
    do Result := b.digit.exactly (3) end)
builder := builder.literal ("-")
builder := builder.group (agent (b: SIMPLE_REGEX_BUILDER): SIMPLE_REGEX_BUILDER
    do Result := b.digit.exactly (4) end)
```

## Safety Features

```eiffel
-- Pattern validation
if regex.is_valid_pattern ("[a-z]+") then ... end

-- Escape user input
safe := regex.escape (user_input)

-- ReDoS detection
complexity := regex.pattern_complexity ("(a+)+")
if regex.is_potentially_dangerous ("(a+)+") then
    -- Avoid using this pattern with untrusted input
end
```

## Testing

126/127 tests passing (1 known Gobo limitation with Unicode properties):

```bash
ec.exe -batch -config simple_regex.ecf -target simple_regex_tests -c_compile
./EIFGENs/simple_regex_tests/W_code/simple_regex.exe
```

## License

MIT License - Copyright (c) 2025, Larry Rix
