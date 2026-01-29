# DataValidator - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - single file validation | 3-4 days | simple_regex, simple_cli, simple_file |
| Phase 2 | Full CLI - multi-format, rulesets | 4-5 days | Phase 1 + simple_csv, simple_json, simple_config |
| Phase 3 | Polish - rule packs, performance | 3-4 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Demonstrate core validation capability: load a simple ruleset, validate a single text file, output results to console.

### Deliverables

1. **DATA_VALIDATOR_CLI** - Basic argument parsing for `validate` command
2. **VALIDATION_RULE** - Single rule with pattern and field name
3. **VALIDATION_RULESET** - Load rules from simple JSON format
4. **VALIDATION_RESULT** - Pass/fail result with error message
5. **TEXT_FILE_VALIDATOR** - Line-by-line text validation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with simple_regex, simple_cli |
| T1.2 | Implement VALIDATION_RULE | Can hold pattern, field, message; validates string |
| T1.3 | Implement VALIDATION_RULESET | Loads JSON array of rules; compiles all patterns |
| T1.4 | Implement TEXT_FILE_VALIDATOR | Reads file line by line; applies rules |
| T1.5 | Implement VALIDATION_RESULT | Stores pass/fail, line number, error message |
| T1.6 | Implement basic CLI | Accepts -r rules.json and file argument |
| T1.7 | Console output | Prints errors with line numbers |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid file | File with all valid emails | Exit 0, "All validations passed" |
| Invalid file | File with bad email on line 3 | Exit 1, "Line 3: Invalid email format" |
| Missing file | Non-existent path | Exit 2, "File not found: {path}" |
| Bad ruleset | Invalid JSON | Exit 2, "Failed to parse ruleset" |
| Bad pattern | Invalid regex | Exit 2, "Invalid pattern in rule 'x'" |

### MVP CLI Interface

```bash
# MVP command structure
data-validator validate -r rules.json input.txt

# MVP ruleset format (JSON)
[
  {"name": "email", "field": "line", "pattern": "^[^@]+@[^@]+$", "message": "Invalid email"}
]

# MVP output
Validating input.txt against rules.json...
Line 3: Invalid email - "not-an-email"
Line 7: Invalid email - "also@bad"

Validation complete: 2 errors, 0 warnings
```

---

## Phase 2: Full Implementation

### Objective

Support multiple file formats (CSV, JSON, text), YAML rulesets with full options, multiple output formats, parallel processing.

### Deliverables

1. **CSV_FILE_VALIDATOR** - Field-aware CSV validation
2. **JSON_FILE_VALIDATOR** - Path-based JSON validation
3. **VALIDATION_REPORT** - Aggregated results with summary statistics
4. **RULESET_LOADER** - YAML and JSON ruleset parsing
5. **REPORT_FORMATTER** - Text, JSON, CSV, JUnit output formats
6. **Enhanced CLI** - All commands and options

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement CSV_FILE_VALIDATOR | Parses CSV, maps headers to fields, validates |
| T2.2 | Implement JSON_FILE_VALIDATOR | Traverses JSON objects, validates by path |
| T2.3 | Implement RULESET_LOADER | Loads YAML with defaults, custom patterns |
| T2.4 | Implement VALIDATION_REPORT | Aggregates results, calculates stats |
| T2.5 | Implement text formatter | Human-readable output with colors |
| T2.6 | Implement JSON formatter | Machine-readable JSON report |
| T2.7 | Implement JUnit formatter | CI/CD compatible XML output |
| T2.8 | Add `check` command | Validates ruleset syntax |
| T2.9 | Add `test` command | Runs ruleset against test vectors |
| T2.10 | Add parallel processing | Process multiple files concurrently |
| T2.11 | Add fail-fast mode | Stop on first error |
| T2.12 | Add field filtering | Validate specific fields only |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| CSV validation | customers.csv with bad phones | Reports field, row, error |
| JSON validation | orders.json with bad dates | Reports path, index, error |
| YAML ruleset | Complex ruleset with defaults | All rules loaded, defaults applied |
| JUnit output | Failed validation | Valid JUnit XML |
| Parallel mode | 10 files | All processed, combined report |

---

## Phase 3: Production Polish

### Objective

Add pre-built rule packs, performance optimization, comprehensive documentation, and production hardening.

### Deliverables

1. **RULE_PACK** - Pre-built rule collections
2. **Performance optimizations** - Pattern caching, batch processing
3. **Error handling hardening** - Graceful degradation, clear messages
4. **Documentation** - README, examples, rule pack docs
5. **CI integration** - GitHub Actions workflow

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Create financial rule pack | Credit cards, accounts, amounts |
| T3.2 | Create healthcare rule pack | NPI, DEA, medical IDs |
| T3.3 | Create contact rule pack | Email, phone, address |
| T3.4 | Create identifier rule pack | UUID, SKU, codes |
| T3.5 | Implement pattern cache | LRU cache with size limit |
| T3.6 | Add batch processing | Configurable batch size |
| T3.7 | Add progress indicator | Shows % complete for large files |
| T3.8 | Harden error handling | All errors caught, user-friendly |
| T3.9 | Write README | Installation, quick start, examples |
| T3.10 | Write rule pack docs | Each pack documented with patterns |
| T3.11 | Create example rulesets | Real-world examples |
| T3.12 | Add GitHub Actions | Build, test, release workflow |

### Rule Pack Examples

**Financial Pack:**
```yaml
rules:
  - name: credit_card
    pattern: "^[0-9]{4}[\\s-]?[0-9]{4}[\\s-]?[0-9]{4}[\\s-]?[0-9]{4}$"
  - name: iban
    pattern: "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$"
  - name: currency
    pattern: "^-?\\$?[0-9]{1,3}(,[0-9]{3})*(\\.\\d{2})?$"
```

**Healthcare Pack:**
```yaml
rules:
  - name: npi
    pattern: "^[0-9]{10}$"
  - name: dea_number
    pattern: "^[A-Z]{2}[0-9]{7}$"
  - name: icd10
    pattern: "^[A-Z][0-9]{2}(\\.[0-9]{1,4})?$"
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="data_validator">
    <root all_classes="true"/>
    <option warning="warning">
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="simple_regex" location="$SIMPLE_EIFFEL/simple_regex/simple_regex.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
    <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location=".\src\"/>
</target>

<!-- CLI executable target -->
<target name="data_validator_cli" extends="data_validator">
    <root class="DATA_VALIDATOR_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="data_validator_tests" extends="data_validator">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="testing" location=".\testing\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config data_validator.ecf -target data_validator_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config data_validator.ecf -target data_validator_tests -c_compile
./EIFGENs/data_validator_tests/W_code/data_validator.exe

# Compile for release (finalized)
/d/prod/ec.sh -batch -config data_validator.ecf -target data_validator_cli -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| CLI works | All commands functional | Verified |
| Performance | Records per second | 100K+ |
| Documentation | README complete | Yes |
| Rule packs | Pre-built packs | 4+ |
