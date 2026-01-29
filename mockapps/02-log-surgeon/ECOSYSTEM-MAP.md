# LogSurgeon - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_regex | Pattern matching and field extraction | Core parsing engine |
| simple_cli | Argument parsing and command routing | CLI interface |
| simple_json | JSON output generation | Output formatter |
| simple_file | File I/O operations | Log file reading |
| simple_datetime | Timestamp parsing and formatting | Log timestamp handling |
| simple_config | Pattern library configuration | Pattern loading |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_csv | CSV output generation | When using CSV output format |
| simple_logger | Structured logging | Debug mode, verbose output |
| simple_yaml | YAML pattern file parsing | When loading YAML patterns |
| simple_hash | Pattern caching | Performance optimization |

## Integration Patterns

### simple_regex Integration

**Purpose:** Core pattern matching for all log parsing

**Usage:**

```eiffel
class GROK_PATTERN
feature
    compile (a_grok: STRING)
            -- Compile Grok pattern to regex
        local
            l_regex_pattern: STRING
        do
            -- Expand Grok pattern to regex
            l_regex_pattern := expand_grok_to_regex (a_grok)

            -- Compile using simple_regex
            create regex.make_from_pattern (l_regex_pattern)
            is_compiled := regex.is_compiled

            if not is_compiled then
                last_error := regex.last_error
            end
        end

    extract_fields (a_line: STRING): HASH_TABLE [STRING, STRING]
            -- Extract named fields from log line
        local
            l_match: SIMPLE_REGEX_MATCH
        do
            create Result.make (field_names.count)

            l_match := regex.match (a_line)
            if l_match.is_matched then
                across field_names as f loop
                    if attached l_match.group (f.cursor_index) as g then
                        Result.put (g, f.item)
                    end
                end
            end
        end

feature {NONE}
    expand_grok_to_regex (a_grok: STRING): STRING
            -- Convert %{PATTERN:name} to regex with groups
        local
            l_expander: GROK_EXPANDER
        do
            create l_expander.make (pattern_library)
            Result := l_expander.expand (a_grok)
            field_names := l_expander.field_names
        end

    regex: SIMPLE_REGEX
    field_names: ARRAYED_LIST [STRING]
end
```

**Data flow:** Grok pattern -> Regex expansion -> SIMPLE_REGEX -> Match groups -> Field map

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing

**Usage:**

```eiffel
class LOG_SURGEON_CLI
inherit
    SIMPLE_CLI_APPLICATION
feature
    define_commands
        do
            add_command ("parse", agent do_parse)
            add_command ("stream", agent do_stream)
            add_command ("extract", agent do_extract)
            add_command ("patterns", agent do_patterns)
            add_command ("test", agent do_test)

            add_option ("pattern", "p", "Named pattern", False)
            add_option ("grok", "g", "Custom Grok pattern", False)
            add_option ("output", "o", "Output file", False)
            add_option ("output-format", Void, "Output format", False)
            add_flag ("auto-detect", Void, "Auto-detect format")
            add_flag ("pretty", Void, "Pretty-print JSON")
            add_flag ("verbose", "v", "Verbose output")
        end

    do_parse
        local
            l_engine: LOG_SURGEON_ENGINE
            l_pattern: GROK_PATTERN
        do
            l_pattern := resolve_pattern
            create l_engine.make (l_pattern)

            across positional_args as f loop
                l_engine.parse_file (f.item)
            end

            output_results (l_engine.results)
        end

    do_stream
        local
            l_engine: LOG_SURGEON_ENGINE
            l_pattern: GROK_PATTERN
        do
            l_pattern := resolve_pattern
            create l_engine.make (l_pattern)

            l_engine.parse_stream (io.input)
            -- Results output as they're parsed
        end
end
```

### simple_datetime Integration

**Purpose:** Parse and normalize log timestamps

**Usage:**

```eiffel
class LOG_TIMESTAMP_PARSER
feature
    parse_timestamp (a_raw: STRING; a_format: STRING): detachable SIMPLE_DATETIME
            -- Parse timestamp from log line
        local
            l_parser: SIMPLE_DATETIME
        do
            create l_parser.make_now
            if l_parser.parse (a_raw, a_format) then
                Result := l_parser
            end
        end

    normalize_timestamp (a_parsed: PARSED_LOG_LINE): STRING
            -- Convert to ISO 8601 format
        do
            if attached a_parsed.timestamp as ts then
                Result := ts.to_iso_8601
            else
                Result := a_parsed.raw_timestamp
            end
        end

    common_formats: ARRAYED_LIST [STRING]
            -- Common timestamp formats to try
        once
            create Result.make (10)
            Result.extend ("%d/%b/%Y:%H:%M:%S %z")  -- Apache
            Result.extend ("%b %d %H:%M:%S")         -- Syslog
            Result.extend ("%Y-%m-%d %H:%M:%S")      -- ISO-like
            Result.extend ("%Y-%m-%dT%H:%M:%S%z")    -- ISO 8601
            Result.extend ("%Y/%m/%d %H:%M:%S")      -- Common variant
        end
end
```

### simple_json Integration

**Purpose:** Generate JSON output from parsed logs

**Usage:**

```eiffel
class JSON_OUTPUT_FORMATTER
feature
    format_line (a_parsed: PARSED_LOG_LINE): STRING
            -- Format single parsed line as JSON
        local
            l_json: SIMPLE_JSON
        do
            create l_json.make
            l_json.start_object

            across a_parsed.fields as f loop
                l_json.add_string (f.key, f.item)
            end

            l_json.end_object
            Result := l_json.to_string
        end

    format_lines_pretty (a_lines: LIST [PARSED_LOG_LINE]): STRING
            -- Format all lines as pretty-printed JSON array
        local
            l_json: SIMPLE_JSON
        do
            create l_json.make
            l_json.start_array

            across a_lines as line loop
                l_json.start_object
                across line.item.fields as f loop
                    l_json.add_string (f.key, f.item)
                end
                l_json.end_object
            end

            l_json.end_array
            Result := l_json.to_pretty_string
        end

    format_jsonl (a_lines: LIST [PARSED_LOG_LINE]): STRING
            -- Format as JSON Lines (one object per line)
        do
            create Result.make (a_lines.count * 200)
            across a_lines as line loop
                Result.append (format_line (line.item))
                Result.append_character ('%N')
            end
        end
end
```

### simple_file Integration

**Purpose:** Read log files efficiently

**Usage:**

```eiffel
class LOG_FILE_READER
feature
    read_file (a_path: STRING; a_callback: PROCEDURE [STRING])
            -- Read file line by line, calling callback for each
        local
            l_file: SIMPLE_FILE
            l_line: STRING
        do
            create l_file.make_open_read (a_path)
            if l_file.is_open then
                from
                until l_file.end_of_file
                loop
                    l_file.read_line
                    l_line := l_file.last_string
                    a_callback.call ([l_line])
                    lines_read := lines_read + 1
                end
                l_file.close
            else
                report_error ("Cannot open file: " + a_path)
            end
        end

    read_file_with_multiline (a_path: STRING; a_continuation: STRING;
                              a_callback: PROCEDURE [STRING])
            -- Read file, aggregating multi-line entries
        local
            l_buffer: STRING
            l_continuation_regex: SIMPLE_REGEX
        do
            create l_continuation_regex.make_from_pattern (a_continuation)
            create l_buffer.make_empty

            read_file (a_path, agent (line: STRING)
                do
                    if l_continuation_regex.match (line).is_matched then
                        l_buffer.append (line)
                    else
                        if not l_buffer.is_empty then
                            a_callback.call ([l_buffer])
                        end
                        l_buffer := line.twin
                    end
                end)

            -- Don't forget last entry
            if not l_buffer.is_empty then
                a_callback.call ([l_buffer])
            end
        end
end
```

## Dependency Graph

```
log_surgeon
    |
    +-- simple_regex (required)
    |       Core pattern matching
    |
    +-- simple_cli (required)
    |       CLI argument parsing
    |
    +-- simple_json (required)
    |       JSON output generation
    |
    +-- simple_file (required)
    |       File I/O
    |
    +-- simple_datetime (required)
    |       Timestamp parsing
    |
    +-- simple_config (required)
    |       Pattern configuration
    |
    +-- simple_csv (optional)
    |       CSV output
    |
    +-- simple_logger (optional)
    |       Structured logging
    |
    +-- ISE base (required)
            Core data structures
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="log_surgeon" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0">
    <description>High-performance log parsing CLI with Grok-compatible patterns</description>

    <target name="log_surgeon">
        <root class="LOG_SURGEON_CLI" feature="make"/>
        <option warning="warning" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="concurrency" value="none"/>

        <!-- simple_* dependencies -->
        <library name="simple_regex" location="$SIMPLE_EIFFEL/simple_regex/simple_regex.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>

        <!-- Optional dependencies -->
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>

        <!-- ISE dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
        <cluster name="patterns" location=".\patterns\" recursive="true"/>
    </target>

    <target name="log_surgeon_tests" extends="log_surgeon">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="testing" location=".\testing\"/>
    </target>
</system>
```
