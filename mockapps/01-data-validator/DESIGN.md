# DataValidator - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                         DataValidator                             |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing (validate, check, test, report)              |
|    - Output formatting (text, json, csv, junit)                   |
+------------------------------------------------------------------+
|  Rule Engine Layer                                                |
|    - Rule loading (YAML/JSON configs)                             |
|    - Rule compilation (simple_regex patterns)                     |
|    - Rule caching (compiled pattern cache)                        |
+------------------------------------------------------------------+
|  Validation Layer                                                 |
|    - File readers (CSV, JSON, text via simple_csv, simple_json)   |
|    - Field extraction and mapping                                 |
|    - Pattern matching (simple_regex core)                         |
+------------------------------------------------------------------+
|  Reporting Layer                                                  |
|    - Error aggregation and deduplication                          |
|    - Report generation (simple_json, simple_csv)                  |
|    - Exit code management                                         |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - File I/O (simple_file)                                       |
|    - Configuration loading (simple_config)                        |
|    - Logging (simple_logger)                                      |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `DATA_VALIDATOR_CLI` | Command-line interface | parse_args, route_command, format_output |
| `DATA_VALIDATOR_ENGINE` | Core validation orchestrator | validate_file, validate_directory, validate_stream |
| `VALIDATION_RULE` | Single validation rule | pattern, field, severity, message_template |
| `VALIDATION_RULESET` | Collection of rules | load_yaml, load_json, compile_all, validate |
| `VALIDATION_RESULT` | Single validation outcome | is_valid, field, value, line_number, error |
| `VALIDATION_REPORT` | Aggregated results | errors, warnings, summary, to_json, to_junit |
| `FILE_VALIDATOR` | File-type-specific validation | csv_validator, json_validator, text_validator |
| `RULE_COMPILER` | Pattern compilation | compile_pattern, validate_pattern, cache_pattern |
| `RULE_PACK` | Pre-built rule collection | financial, healthcare, contact, identifier |

### Command Structure

```bash
data-validator <command> [options] [files...]

Commands:
  validate    Validate files against ruleset (default)
  check       Quick syntax check of ruleset file
  test        Run ruleset against test cases
  report      Generate detailed validation report
  pack        List or describe available rule packs

Validation Options:
  -r, --rules FILE        Ruleset file (YAML or JSON)
  -p, --pack NAME         Use pre-built rule pack
  -f, --format FORMAT     Input format (csv, json, text, auto)
  --field FIELD           Validate specific field only
  --severity LEVEL        Minimum severity (error, warning, info)

Output Options:
  -o, --output FILE       Output report to file
  --output-format FMT     Report format (text, json, csv, junit)
  --quiet                 Only output errors
  --verbose               Include passing validations

Performance Options:
  --parallel N            Process N files in parallel
  --batch SIZE            Process records in batches
  --fail-fast             Stop on first error

Global Options:
  --config FILE           Configuration file
  --no-color              Disable colored output
  --help                  Show help
  --version               Show version
```

### Data Flow

```
Input Files       Ruleset           Output
    |                |                 |
    v                v                 |
[File Reader] --> [Validator] ------> [Reporter]
    |                |                 |
    |                v                 |
    |         [Rule Engine]            |
    |              |                   |
    |              v                   |
    |        [SIMPLE_REGEX]            |
    |         Pattern Match            |
    |              |                   |
    v              v                   v
CSV/JSON/Text   Match Results     Error Report
```

### Configuration Schema

**Ruleset YAML Format:**

```yaml
# data-validator-rules.yaml
name: "Customer Data Validation"
version: "1.0"
description: "Validates customer import files"

defaults:
  severity: error
  stop_on_fail: false

rules:
  - name: email_format
    field: email
    pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    message: "Invalid email format"
    severity: error

  - name: phone_format
    field: phone
    pattern: "^\\+?[1-9]\\d{1,14}$"
    message: "Phone must be E.164 format"
    severity: warning

  - name: zip_code
    field: postal_code
    pattern: "^\\d{5}(-\\d{4})?$"
    message: "Invalid US ZIP code"
    severity: error
    condition: "country == 'US'"

  - name: required_name
    field: name
    pattern: "^.+$"
    message: "Name is required"
    severity: error

custom_patterns:
  account_number: "^[A-Z]{2}\\d{8}$"
  product_sku: "^[A-Z]{3}-\\d{6}$"
```

**Application Config:**

```json
{
  "data_validator": {
    "default_ruleset": "rules/standard.yaml",
    "output_format": "text",
    "parallel_workers": 4,
    "max_errors": 1000,
    "log_level": "info",
    "color_output": true
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Invalid ruleset syntax | Fail fast, show YAML error | "Ruleset parse error at line N: {detail}" |
| Invalid regex pattern | Skip rule, warn | "Invalid pattern in rule '{name}': {error}" |
| File not found | Skip file, report | "File not found: {path}" |
| Unsupported format | Fail fast | "Unsupported file format: {ext}" |
| Validation failure | Collect, report | "{field} in row {line}: {message}" |
| ReDoS risk detected | Warn, optional skip | "Pattern '{name}' has ReDoS risk (score: N)" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Rule Builder TUI** - Interactive pattern testing with live feedback
2. **Validation Dashboard GUI** - Visual file browser, drag-drop validation
3. **Report Viewer** - Sortable, filterable error list with file preview

**Shared components between CLI/GUI:**
- `VALIDATION_RULESET` - Rule loading and compilation
- `DATA_VALIDATOR_ENGINE` - Core validation logic
- `VALIDATION_REPORT` - Report data structures

**CLI-specific components:**
- `DATA_VALIDATOR_CLI` - Argument parsing, console output
- Progress indicators, color formatting

**GUI-specific components (future):**
- File browser widget
- Pattern editor with syntax highlighting
- Interactive report table
