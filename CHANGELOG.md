# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Add SCOOP concurrency capability
- Migrate to simple_testing library
- Fix README.md encoding (was UTF-16, now UTF-8)
- Complete simple_regex library implementation
- first commit

## [1.0.1] - 2026-09-02

### Fixed
- **`SIMPLE_REGEX.split` (and its aliases `tokenize` / `divide`) and
  `SIMPLE_REGEX.split_by_pattern` raised a precondition violation inside the
  library when handed a non-8-bit subject.** Both features advertise a
  `READABLE_STRING_GENERAL` subject, but they forwarded it unchanged to Gobo's
  `RX_REGULAR_EXPRESSION.split`, whose `subject_is_string` precondition requires
  an 8-bit `STRING`. Any caller passing a `STRING_32` - including a plain ASCII
  `STRING_32` - got `subject_is_string` from inside `simple_regex` rather than a
  result. The public signature promised more than the backend delivered.

  Found 2026-09-02 while onboarding `simple_bnf`, whose choice productions split
  on `|` and raised on every rule; that consumer worked around it with
  `match_all`, which was never affected.

  Affected: `split`, `tokenize`, `divide`, `split_by_pattern`, and anything
  layered on them (`SIMPLE_REGEX_QUICK.split` was safe only because its own
  signature is `STRING`-typed). Matching (`match`, `match_all`, `first_match_for`,
  `all_matches_for`, `all_matches_with_details`) and replacement (`replace`,
  `replace_all`, `replace_first_match`, `replace_all_matches`) were never
  affected - they already routed through Gobo's `unicode_*` counterparts, which
  carry no `subject_is_string` clause. That asymmetry is why `split` failed where
  `match_all` succeeded on the same subject.

  Fix: both split features now normalize the subject to `STRING_32` and call
  Gobo's `unicode_split`, the Unicode counterpart the matching and replacement
  features were already using. Pieces are code-point-for-code-point substrings of
  the caller's subject, and `split` now agrees with `match_all` on every subject.
  Behavior for 8-bit subjects is unchanged.

### Added
- Vector regression tests (`SIMPLE_REGEX_UNICODE_TEST`) driving a `STRING_32`
  subject containing Hebrew (U+05E9 U+05DC U+05D5 U+05DD), an astral-plane emoji
  (U+1F916, above U+FFFF) and Greek (U+03A7 ... U+03C2) through both `split` and
  `match_all` and requiring the two to agree, plus a plain-ASCII `STRING_32`
  vector that would have caught this defect on its own.

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_regex/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/simple-eiffel/simple_regex/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/simple-eiffel/simple_regex/releases/tag/v1.0.0
