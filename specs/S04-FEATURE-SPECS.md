# S04: FEATURE SPECS - simple_regex

**BACKWASH DOCUMENT** - Generated: 2026-01-23
**Status**: Reverse-engineered from existing implementation

## 1. SIMPLE_REGEX Features

### 1.1 Initialization
| Feature | Description |
|---------|-------------|
| default_create | Create without pattern |
| make | Alias for default_create |
| make_from_pattern | Create and compile |

### 1.2 Compilation
| Feature | Description |
|---------|-------------|
| compile, set_pattern, load_pattern | Compile pattern |
| is_compiled | Check compilation status |
| is_valid_pattern | Validate syntax |
| last_error | Compilation error |
| pattern | Current pattern |

### 1.3 Matching
| Feature | Description |
|---------|-------------|
| match, find, search, find_first | First match |
| match_all, find_all, matches | All matches |

### 1.4 Replacement
| Feature | Description |
|---------|-------------|
| replace, substitute, sub | Replace first |
| replace_all, gsub | Replace all |

### 1.5 Splitting
| Feature | Description |
|---------|-------------|
| split, tokenize, divide | Split by pattern |

### 1.6 Options
| Feature | Description |
|---------|-------------|
| case_insensitive | New regex, caseless |
| multiline | New regex, multiline |
| dotall | New regex, dotall |

### 1.7 Class Methods (Cached)
| Feature | Description |
|---------|-------------|
| matches_pattern, test, is_match | Check match |
| first_match_for | Get first match |
| all_matches_for | Get all matches |
| replace_first_match | Replace first |
| replace_all_matches | Replace all |
| split_by_pattern | Split |

### 1.8 Safety
| Feature | Description |
|---------|-------------|
| escape, quote, literal | Escape special chars |
| pattern_complexity | ReDoS score (1-10) |
| is_potentially_dangerous | Check ReDoS risk |

## 2. SIMPLE_REGEX_BUILDER Features

### 2.1 Building
| Category | Features |
|----------|----------|
| Literals | literal, raw |
| Any | any_char |
| Classes | digit, non_digit, word_char, non_word_char, whitespace, non_whitespace, one_of, none_of, range |
| Unicode | unicode_property, unicode_not_property, grapheme |
| Anchors | start_of_string, end_of_string, word_boundary, non_word_boundary |
| Quantifiers | zero_or_more, zero_or_more_lazy, one_or_more, one_or_more_lazy, optional, optional_lazy, exactly, at_least, between |
| Groups | group_start, group_end, non_capturing_start, atomic_start |
| Alternation | alternate |
| Lookaround | lookahead_positive_start, lookahead_negative_start, lookbehind_positive_start, lookbehind_negative_start |
| Backrefs | backreference |
| Advanced | recurse, conditional_start, conditional_else |
| Special | newline, carriage_return, tab |

### 2.2 Conversion
| Feature | Description |
|---------|-------------|
| to_regex | Build regex |
| to_regex_with_options | Build with options |
| pattern | Get pattern string |
| reset | Clear and restart |

## 3. SIMPLE_REGEX_PATTERNS Features

### 3.1 Pattern Categories
| Category | Patterns |
|----------|----------|
| Email/Web | email, url, domain |
| Network | ipv4, ipv6, mac_address |
| Phone | phone_us, phone_international |
| Date | date_iso, date_us, date_eu, datetime_iso |
| Time | time_24h, time_12h |
| Financial | credit_card, currency |
| Identifiers | uuid, hex_color, username, slug |
| Security | password_strong, password_medium |
| Markup | html_tag, html_comment |
| Files | file_extension, windows_path, unix_path |
| US-Specific | zip_code_us, ssn |
| Numbers | integer, decimal, scientific_notation, hex_number |
| Text | alphanumeric, alphabetic, whitespace_only |
