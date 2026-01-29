# DataValidator - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_regex | Pattern matching and validation | Core validation engine |
| simple_cli | Argument parsing and command routing | CLI interface |
| simple_json | JSON file parsing and report output | File reader, reporter |
| simple_csv | CSV file parsing | File reader |
| simple_config | YAML/JSON configuration loading | Ruleset loading |
| simple_file | File I/O operations | File reading, report writing |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_logger | Structured logging | Verbose mode, debugging |
| simple_yaml | YAML ruleset parsing | When using YAML rulesets |
| simple_xml | XML file validation | When validating XML files |
| simple_hash | Pattern hashing for cache keys | Performance optimization |

## Integration Patterns

### simple_regex Integration

**Purpose:** Core pattern matching for all validation rules

**Usage:**

```eiffel
class RULE_COMPILER
feature
    compile_rule (a_pattern: STRING): SIMPLE_REGEX
        local
            l_regex: SIMPLE_REGEX
            l_quick: SIMPLE_REGEX_QUICK
        do
            -- Check for ReDoS risk first
            create l_quick.make
            if l_quick.regex.pattern_complexity (a_pattern) >= 7 then
                log_warning ("High complexity pattern detected: " + a_pattern)
            end

            -- Compile pattern
            create l_regex.make_from_pattern (a_pattern)
            if l_regex.is_compiled then
                Result := l_regex
                pattern_cache.put (Result, a_pattern)
            else
                report_error ("Invalid pattern: " + l_regex.last_error)
            end
        end

    validate_field (a_value: STRING; a_rule: VALIDATION_RULE): VALIDATION_RESULT
        do
            if attached a_rule.compiled_pattern as l_pattern then
                if l_pattern.match (a_value).is_matched then
                    create Result.make_valid (a_rule, a_value)
                else
                    create Result.make_invalid (a_rule, a_value, a_rule.message)
                end
            end
        end
end
```

**Data flow:** Rule YAML -> Pattern string -> SIMPLE_REGEX -> Match result

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing

**Usage:**

```eiffel
class DATA_VALIDATOR_CLI
inherit
    SIMPLE_CLI_APPLICATION
feature
    define_commands
        do
            add_command ("validate", agent do_validate)
            add_command ("check", agent do_check)
            add_command ("test", agent do_test)
            add_command ("report", agent do_report)

            add_option ("rules", "r", "Ruleset file", True)
            add_option ("pack", "p", "Pre-built rule pack", False)
            add_option ("format", "f", "Input format", False)
            add_option ("output", "o", "Output file", False)
            add_flag ("quiet", "q", "Quiet mode")
            add_flag ("verbose", "v", "Verbose mode")
        end

    do_validate
        local
            l_engine: DATA_VALIDATOR_ENGINE
        do
            create l_engine.make (current_options)
            across positional_args as f loop
                l_engine.validate_file (f.item)
            end
            print_report (l_engine.report)
        end
end
```

### simple_csv Integration

**Purpose:** Parse CSV files for field-by-field validation

**Usage:**

```eiffel
class CSV_FILE_VALIDATOR
feature
    validate_csv (a_path: STRING; a_ruleset: VALIDATION_RULESET): VALIDATION_REPORT
        local
            l_csv: SIMPLE_CSV
            l_row: INTEGER
        do
            create Result.make
            create l_csv.make_from_file (a_path)

            from l_row := 1
            until l_csv.after
            loop
                validate_row (l_csv.current_record, a_ruleset, l_row, Result)
                l_csv.forth
                l_row := l_row + 1
            end
        end

    validate_row (a_record: CSV_RECORD; a_ruleset: VALIDATION_RULESET;
                  a_line: INTEGER; a_report: VALIDATION_REPORT)
        do
            across a_ruleset.rules as r loop
                if attached a_record.field (r.item.field_name) as l_value then
                    a_report.add_result (
                        r.item.validate (l_value, a_line)
                    )
                end
            end
        end
end
```

### simple_json Integration

**Purpose:** Parse JSON files and generate JSON reports

**Usage:**

```eiffel
class JSON_FILE_VALIDATOR
feature
    validate_json (a_path: STRING; a_ruleset: VALIDATION_RULESET): VALIDATION_REPORT
        local
            l_json: SIMPLE_JSON
            l_object: JSON_OBJECT
        do
            create Result.make
            create l_json.make

            if attached l_json.parse_file (a_path) as l_root then
                if l_root.is_array then
                    validate_array (l_root.as_array, a_ruleset, Result)
                else
                    validate_object (l_root.as_object, a_ruleset, 1, Result)
                end
            else
                Result.add_error ("Failed to parse JSON: " + l_json.last_error)
            end
        end

    report_to_json (a_report: VALIDATION_REPORT): STRING
        local
            l_json: SIMPLE_JSON
        do
            create l_json.make
            l_json.start_object
            l_json.add_boolean ("valid", a_report.is_valid)
            l_json.add_integer ("error_count", a_report.error_count)
            l_json.add_integer ("warning_count", a_report.warning_count)
            l_json.start_array ("errors")
            across a_report.errors as e loop
                l_json.start_object
                l_json.add_string ("field", e.item.field)
                l_json.add_integer ("line", e.item.line)
                l_json.add_string ("message", e.item.message)
                l_json.end_object
            end
            l_json.end_array
            l_json.end_object
            Result := l_json.to_string
        end
end
```

### simple_config Integration

**Purpose:** Load ruleset configuration files

**Usage:**

```eiffel
class RULESET_LOADER
feature
    load_ruleset (a_path: STRING): VALIDATION_RULESET
        local
            l_config: SIMPLE_CONFIG
        do
            create l_config.make
            l_config.load_file (a_path)

            create Result.make (l_config.string ("name"))
            Result.set_version (l_config.string ("version"))

            across l_config.array ("rules") as r loop
                Result.add_rule (parse_rule (r.item))
            end
        end

    parse_rule (a_config: SIMPLE_CONFIG_SECTION): VALIDATION_RULE
        do
            create Result.make (
                a_config.string ("name"),
                a_config.string ("field"),
                a_config.string ("pattern")
            )
            Result.set_message (a_config.string_or_default ("message", "Validation failed"))
            Result.set_severity (parse_severity (a_config.string_or_default ("severity", "error")))
        end
end
```

## Dependency Graph

```
data_validator
    |
    +-- simple_regex (required)
    |       Core pattern matching
    |
    +-- simple_cli (required)
    |       CLI argument parsing
    |
    +-- simple_json (required)
    |       JSON parsing/output
    |
    +-- simple_csv (required)
    |       CSV file parsing
    |
    +-- simple_config (required)
    |       Ruleset configuration
    |
    +-- simple_file (required)
    |       File I/O
    |
    +-- simple_logger (optional)
    |       Structured logging
    |
    +-- simple_yaml (optional)
    |       YAML ruleset support
    |
    +-- ISE base (required)
            Core data structures
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="data_validator" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0">
    <description>Enterprise-grade CLI for batch data validation</description>

    <target name="data_validator">
        <root class="DATA_VALIDATOR_CLI" feature="make"/>
        <option warning="warning" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="concurrency" value="none"/>

        <!-- simple_* dependencies -->
        <library name="simple_regex" location="$SIMPLE_EIFFEL/simple_regex/simple_regex.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>

        <!-- Optional dependencies -->
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>

        <!-- ISE dependencies (only when no simple_* alternative) -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
    </target>

    <target name="data_validator_tests" extends="data_validator">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="testing" location=".\testing\"/>
    </target>
</system>
```
