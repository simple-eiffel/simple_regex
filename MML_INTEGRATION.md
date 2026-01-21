# MML Integration - simple_regex

## Overview
Applied X03 Contract Assault with simple_mml on 2025-01-21.

## MML Classes Used
- `MML_SEQUENCE [SIMPLE_REGEX_MATCH]` - Models ordered match results
- `MML_SEQUENCE [detachable STRING_32]` - Models captured groups

## Model Queries Added
- `SIMPLE_REGEX_MATCH_LIST.model: MML_SEQUENCE [SIMPLE_REGEX_MATCH]` - Match sequence
- `SIMPLE_REGEX_MATCH.groups_model: MML_SEQUENCE [detachable STRING_32]` - Groups

## Model-Based Postconditions
| Feature | Postcondition | Purpose |
|---------|---------------|---------|
| `make` | `model_empty` | Starts empty |
| `count` | `model_consistent: Result = model.count` | Count via model |
| `item` | `model_consistent: Result = model[i]` | Access via model |
| `first` | `model_consistent: Result = model.first` | First via model |
| `last` | `model_consistent: Result = model.last` | Last via model |
| `is_empty` | `model_consistent: Result = model.is_empty` | Empty via model |
| `has_matches` | `model_consistent: Result = not model.is_empty` | Has matches |
| `extend` | `model_extended` | Match appended |
| `groups` | `model_consistent: Result.count = groups_model.count` | Group count |

## Invariants Added
- `count_non_negative` - Match count >= 0
- `length_non_negative` - Match length >= 0 when matched

## Bugs Found
None (55+ redundant preconditions removed)

## Test Results
- Compilation: SUCCESS
- Tests: 127/127 PASS
