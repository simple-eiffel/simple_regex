# LogSurgeon - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - single pattern parsing | 3-4 days | simple_regex, simple_cli, simple_file |
| Phase 2 | Full CLI - Grok library, formats | 4-5 days | Phase 1 + simple_json, simple_datetime, simple_config |
| Phase 3 | Polish - streaming, patterns | 3-4 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Demonstrate core parsing capability: apply a simple regex pattern to a log file, extract fields, output as text.

### Deliverables

1. **LOG_SURGEON_CLI** - Basic argument parsing for `parse` command
2. **GROK_PATTERN** - Basic pattern with named fields
3. **PARSED_LOG_LINE** - Extracted fields container
4. **LOG_FILE_READER** - Line-by-line file reading
5. **TEXT_OUTPUT_FORMATTER** - Simple text output

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with simple_regex, simple_cli, simple_file |
| T1.2 | Implement GROK_PATTERN (basic) | Can expand %{WORD:name} to regex with group |
| T1.3 | Implement base patterns | WORD, NUMBER, IP, GREEDYDATA work |
| T1.4 | Implement PARSED_LOG_LINE | Holds field map, raw line, line number |
| T1.5 | Implement LOG_FILE_READER | Reads file, yields lines |
| T1.6 | Implement basic parse command | -g pattern and file argument |
| T1.7 | Implement text output | Prints extracted fields per line |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Simple pattern | `%{WORD:name}` on "hello" | `name=hello` |
| IP extraction | `%{IP:addr}` on "192.168.1.1" | `addr=192.168.1.1` |
| Multiple fields | `%{WORD:a} %{WORD:b}` on "foo bar" | `a=foo, b=bar` |
| No match | Pattern that doesn't match | Line skipped, warning in verbose |
| Missing file | Non-existent path | Exit 2, error message |

### MVP CLI Interface

```bash
# MVP command structure
log-surgeon parse -g "%{WORD:method} %{URIPATH:path}" access.log

# MVP output
method=GET path=/api/users
method=POST path=/api/orders
method=GET path=/health

Parsed: 100 lines, 3 matched
```

---

## Phase 2: Full Implementation

### Objective

Full Grok pattern library, pre-built format parsers, JSON/CSV output, timestamp normalization, multi-file processing.

### Deliverables

1. **GROK_PATTERN_LIBRARY** - Complete pattern library with hierarchy
2. **Pre-built parsers** - Apache, nginx, syslog, JSON logs
3. **JSON_OUTPUT_FORMATTER** - JSON and JSON Lines output
4. **CSV_OUTPUT_FORMATTER** - CSV output with headers
5. **LOG_TIMESTAMP_PARSER** - Timestamp extraction and normalization
6. **Enhanced CLI** - All commands and options

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement full Grok expansion | Nested patterns, type hints |
| T2.2 | Create base patterns library | 30+ common patterns |
| T2.3 | Create Apache parser | Combined, common, error formats |
| T2.4 | Create nginx parser | Access, error formats |
| T2.5 | Create syslog parser | RFC 3164, RFC 5424 |
| T2.6 | Implement JSON output | Single objects, arrays, JSONL |
| T2.7 | Implement CSV output | Headers, proper escaping |
| T2.8 | Implement timestamp parsing | Multiple formats, normalization |
| T2.9 | Add `patterns` command | List and describe patterns |
| T2.10 | Add `test` command | Test pattern against sample |
| T2.11 | Add auto-detect | Try patterns, report best match |
| T2.12 | Add field filtering | --fields option |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Apache combined | Real Apache log | All fields extracted |
| nginx access | Real nginx log | All fields extracted |
| Syslog | Syslog line | host, program, message |
| JSON output | Parsed log | Valid JSON |
| CSV output | Parsed log | Valid CSV with headers |
| Timestamp ISO | Various formats | ISO 8601 output |

### Pre-built Pattern Library

**Base Patterns:**
```
WORD, NUMBER, INT, POSINT, NONNEGINT
IP, IPV4, IPV6, IPORHOST, HOSTNAME
USER, USERNAME, EMAILADDRESS
PATH, URIPATH, URIPARAM, URI
MONTHDAY, MONTH, YEAR, HOUR, MINUTE, SECOND
DATE, TIME, DATESTAMP, TIMESTAMP
LOGLEVEL, SYSLOGPRIORITY
QUOTEDSTRING, GREEDYDATA, DATA
```

**Format Patterns:**
```
APACHE_COMBINED, APACHE_COMMON, APACHE_ERROR
NGINX_ACCESS, NGINX_ERROR
SYSLOG, SYSLOG_RFC5424
JAVA_STACKTRACE
JSON_LOG
```

---

## Phase 3: Production Polish

### Objective

Streaming mode, multi-line handling, performance optimization, documentation, and production hardening.

### Deliverables

1. **Streaming mode** - Real-time stdin processing
2. **Multi-line handler** - Stack traces, continued lines
3. **Performance optimizations** - Pattern caching, buffering
4. **Documentation** - README, pattern docs, examples
5. **CI integration** - GitHub Actions workflow

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement streaming mode | Reads stdin, outputs immediately |
| T3.2 | Implement multi-line detection | Configurable continuation pattern |
| T3.3 | Implement Java stack trace handler | Groups exception + stack |
| T3.4 | Implement pattern cache | Compiled patterns cached |
| T3.5 | Implement buffered reading | Configurable buffer size |
| T3.6 | Add progress indicator | Show lines processed for large files |
| T3.7 | Harden error handling | Graceful degradation |
| T3.8 | Write README | Installation, quick start, examples |
| T3.9 | Write pattern docs | Each pattern with examples |
| T3.10 | Create sample log files | For testing and demos |
| T3.11 | Add GitHub Actions | Build, test, release workflow |
| T3.12 | Performance benchmarking | Document lines/second |

### Streaming Example

```bash
# Real-time log monitoring
tail -f /var/log/nginx/access.log | log-surgeon stream -p nginx-access --output-format jsonl

# Pipeline with jq
log-surgeon parse -p apache-combined access.log --output-format jsonl | jq 'select(.status >= 400)'

# Aggregate with other tools
log-surgeon parse -p syslog /var/log/messages --fields timestamp,program,message | sort | uniq -c
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="log_surgeon">
    <root all_classes="true"/>
    <option warning="warning">
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="simple_regex" location="$SIMPLE_EIFFEL/simple_regex/simple_regex.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
    <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location=".\src\"/>
    <cluster name="patterns" location=".\patterns\"/>
</target>

<!-- CLI executable target -->
<target name="log_surgeon_cli" extends="log_surgeon">
    <root class="LOG_SURGEON_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="log_surgeon_tests" extends="log_surgeon">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="testing" location=".\testing\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config log_surgeon.ecf -target log_surgeon_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config log_surgeon.ecf -target log_surgeon_tests -c_compile
./EIFGENs/log_surgeon_tests/W_code/log_surgeon.exe

# Compile for release (finalized)
/d/prod/ec.sh -batch -config log_surgeon.ecf -target log_surgeon_cli -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| CLI works | All commands functional | Verified |
| Performance | Lines per minute | 1M+ |
| Pattern coverage | Pre-built formats | 20+ |
| Documentation | README complete | Yes |
