# LogSurgeon - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                          LogSurgeon                               |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing (parse, stream, extract, patterns)           |
|    - Output formatting (json, csv, text, table)                   |
+------------------------------------------------------------------+
|  Pattern Engine Layer                                             |
|    - Grok pattern compilation                                     |
|    - Pattern library management                                   |
|    - Custom pattern definition                                    |
+------------------------------------------------------------------+
|  Parsing Layer                                                    |
|    - Line parsing with field extraction                           |
|    - Multi-line log handling                                      |
|    - Format auto-detection                                        |
+------------------------------------------------------------------+
|  Output Layer                                                     |
|    - JSON serialization (simple_json)                             |
|    - CSV generation (simple_csv)                                  |
|    - Table formatting                                             |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - File I/O (simple_file)                                       |
|    - Stream processing (stdin/stdout)                             |
|    - Datetime parsing (simple_datetime)                           |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `LOG_SURGEON_CLI` | Command-line interface | parse_args, route_command, format_output |
| `LOG_SURGEON_ENGINE` | Core parsing orchestrator | parse_file, parse_stream, parse_line |
| `GROK_PATTERN` | Single Grok pattern | compile, match, extract_fields |
| `GROK_PATTERN_LIBRARY` | Collection of patterns | load_patterns, get_pattern, add_custom |
| `PARSED_LOG_LINE` | Extracted fields from log | fields, timestamp, raw_line, format |
| `LOG_PARSER` | Format-specific parsing | apache_parser, nginx_parser, syslog_parser |
| `MULTILINE_HANDLER` | Multi-line log aggregation | detect_continuation, aggregate_lines |
| `OUTPUT_FORMATTER` | Format conversion | to_json, to_csv, to_table |

### Command Structure

```bash
log-surgeon <command> [options] [files...]

Commands:
  parse       Parse log files with specified pattern (default)
  stream      Real-time streaming parse (reads stdin)
  extract     Extract specific fields only
  patterns    List or describe available patterns
  test        Test pattern against sample lines

Parsing Options:
  -p, --pattern NAME      Use named pattern (apache, nginx, syslog, etc.)
  -g, --grok PATTERN      Use custom Grok pattern string
  -f, --format FORMAT     Specify log format explicitly
  --auto-detect           Auto-detect log format
  --multiline PATTERN     Multi-line continuation pattern

Field Options:
  --fields FIELDS         Extract only specified fields
  --timestamp FIELD       Field to use as timestamp
  --timestamp-format FMT  Timestamp parsing format

Output Options:
  -o, --output FILE       Output to file
  --output-format FMT     Output format (json, jsonl, csv, table, text)
  --pretty                Pretty-print JSON output
  --no-header             Omit CSV header

Stream Options:
  --buffer SIZE           Stream buffer size
  --flush-interval MS     Flush interval for streaming

Global Options:
  --config FILE           Configuration file
  --quiet                 Only output parsed data
  --verbose               Include parse statistics
  --help                  Show help
  --version               Show version
```

### Grok Pattern Syntax

LogSurgeon uses Grok-compatible pattern syntax:

```
%{PATTERN_NAME:field_name}
%{PATTERN_NAME:field_name:type}
```

**Example Patterns:**

```grok
# Apache Combined Log Format
%{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATH:path}(?:%{URIPARAM:params})? HTTP/%{NUMBER:http_version}" %{NUMBER:status} %{NUMBER:bytes}

# Syslog
%{SYSLOGTIMESTAMP:timestamp} %{SYSLOGHOST:host} %{DATA:program}(?:\[%{POSINT:pid}\])?: %{GREEDYDATA:message}

# nginx Error Log
%{DATESTAMP:timestamp} \[%{LOGLEVEL:level}\] %{POSINT:pid}#%{NUMBER:tid}: %{GREEDYDATA:message}
```

### Data Flow

```
Log File/Stream      Pattern Library        Output
      |                    |                  |
      v                    v                  |
[Line Reader] -----> [Pattern Matcher] ----> [Formatter]
      |                    |                  |
      |                    v                  |
      |            [SIMPLE_REGEX]             |
      |             Match Groups              |
      |                    |                  |
      v                    v                  v
   Raw Lines         Field Map          JSON/CSV/Table
```

### Configuration Schema

**Pattern Library YAML:**

```yaml
# patterns/apache.yaml
name: apache
description: Apache HTTP Server Logs
patterns:
  combined:
    grok: '%{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATH:path}(?:%{URIPARAM:params})? HTTP/%{NUMBER:http_version}" %{NUMBER:status} %{NUMBER:bytes} "%{DATA:referrer}" "%{DATA:user_agent}"'
    timestamp_field: timestamp
    timestamp_format: "%d/%b/%Y:%H:%M:%S %z"
  common:
    grok: '%{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATH:path} HTTP/%{NUMBER:http_version}" %{NUMBER:status} %{NUMBER:bytes}'
  error:
    grok: '\[%{APACHE_ERROR_TIME:timestamp}\] \[%{LOGLEVEL:level}\] %{GREEDYDATA:message}'
```

**Base Patterns YAML:**

```yaml
# patterns/base.yaml
IPORHOST: '(?:%{IP}|%{HOSTNAME})'
IP: '(?:%{IPV4}|%{IPV6})'
IPV4: '(?:[0-9]{1,3}\.){3}[0-9]{1,3}'
HOSTNAME: '\b[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\b'
USER: '[a-zA-Z0-9._-]+'
HTTPDATE: '%{MONTHDAY}/%{MONTH}/%{YEAR}:%{TIME} %{INT}'
WORD: '\b\w+\b'
NUMBER: '(?:[+-]?(?:[0-9]+(?:\.[0-9]+)?))'
GREEDYDATA: '.*'
LOGLEVEL: '(?:debug|info|notice|warn|warning|error|crit|critical|alert|emerg|emergency)'
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Pattern not found | Fail fast | "Unknown pattern: {name}. Use 'patterns' to list available." |
| Invalid Grok syntax | Fail fast | "Invalid Grok pattern: {error at position N}" |
| Parse failure | Skip line, warn | "Line {N}: No match for pattern" (in verbose mode) |
| File not found | Skip file, report | "File not found: {path}" |
| Stream error | Retry, fail gracefully | "Stream interrupted, {N} lines processed" |
| Invalid timestamp | Keep original, warn | "Line {N}: Could not parse timestamp" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Pattern Builder TUI** - Interactive Grok pattern testing with live preview
2. **Log Viewer GUI** - Parsed log display with filtering and search
3. **Dashboard** - Real-time log metrics and visualizations

**Shared components between CLI/GUI:**
- `GROK_PATTERN` - Pattern compilation and matching
- `LOG_SURGEON_ENGINE` - Core parsing logic
- `GROK_PATTERN_LIBRARY` - Pattern storage and lookup

**CLI-specific components:**
- `LOG_SURGEON_CLI` - Argument parsing, console output
- Stream processing, progress indicators

**GUI-specific components (future):**
- Log file browser
- Pattern editor with syntax highlighting
- Field filter UI
- Real-time streaming display
