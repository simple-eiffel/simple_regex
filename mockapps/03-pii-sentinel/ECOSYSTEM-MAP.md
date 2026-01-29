# PII-Sentinel - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_regex | Pattern matching for PII detection | Core detection engine |
| simple_cli | Argument parsing and command routing | CLI interface |
| simple_json | JSON file scanning and report output | File scanner, reporter |
| simple_csv | CSV file scanning | File scanner |
| simple_file | File I/O operations | File reading, masked output |
| simple_config | Configuration loading | Pattern and app config |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_encryption | AES encryption for encrypt strategy | Encrypt masking strategy |
| simple_hash | SHA-256 hashing for hash strategy | Hash masking strategy |
| simple_logger | Structured logging and audit | Audit logging |
| simple_uuid | Token generation | Tokenize masking strategy |

## Integration Patterns

### simple_regex Integration

**Purpose:** Core pattern matching for PII detection

**Usage:**

```eiffel
class PII_DETECTION_ENGINE
feature
    detect_in_text (a_text: STRING): ARRAYED_LIST [PII_FINDING]
            -- Detect all PII in text
        local
            l_finding: PII_FINDING
        do
            create Result.make (10)

            across pattern_library.active_patterns as p loop
                across detect_pattern (a_text, p.item) as f loop
                    if f.item.confidence >= min_confidence then
                        if context_validation_enabled implies validate_context (f.item, a_text) then
                            Result.extend (f.item)
                        end
                    end
                end
            end

            -- Remove overlapping findings (keep highest confidence)
            remove_overlaps (Result)
        end

    detect_pattern (a_text: STRING; a_pattern: PII_PATTERN): ARRAYED_LIST [PII_FINDING]
            -- Detect single pattern in text
        local
            l_regex: SIMPLE_REGEX
            l_matches: SIMPLE_REGEX_MATCH_LIST
            l_finding: PII_FINDING
        do
            create Result.make (5)
            l_regex := a_pattern.compiled_regex

            l_matches := l_regex.match_all (a_text)
            across l_matches as m loop
                create l_finding.make (
                    a_pattern.pii_type,
                    m.item.value,
                    m.item.start_position,
                    m.item.end_position,
                    calculate_confidence (m.item, a_pattern)
                )
                Result.extend (l_finding)
            end
        end

feature {NONE}
    validate_context (a_finding: PII_FINDING; a_text: STRING): BOOLEAN
            -- Check if context suggests this is real PII
        local
            l_context: STRING
            l_regex: SIMPLE_REGEX_QUICK
        do
            -- Extract surrounding context
            l_context := extract_context (a_text, a_finding.start_pos, a_finding.end_pos, 50)
            l_context := l_context.as_lower

            -- Check for context hints
            create l_regex.make
            across a_finding.pattern.context_hints as hint loop
                if l_regex.matches (hint.item, l_context) then
                    Result := True
                end
            end

            -- If no hints found but high base confidence, accept
            if not Result and a_finding.confidence >= 95 then
                Result := True
            end
        end
end
```

**Data flow:** Text -> Pattern library -> SIMPLE_REGEX -> Match list -> Findings

### simple_cli Integration

**Purpose:** Command-line argument parsing and routing

**Usage:**

```eiffel
class PII_SENTINEL_CLI
inherit
    SIMPLE_CLI_APPLICATION
feature
    define_commands
        do
            add_command ("scan", agent do_scan)
            add_command ("mask", agent do_mask)
            add_command ("report", agent do_report)
            add_command ("audit", agent do_audit)
            add_command ("patterns", agent do_patterns)

            add_option ("patterns", "p", "PII types to detect", False)
            add_option ("strategy", "s", "Masking strategy", False)
            add_option ("output", "o", "Output directory", False)
            add_option ("audit-log", Void, "Audit log file", False)
            add_flag ("all", Void, "Detect all PII types")
            add_flag ("in-place", Void, "Modify in place")
            add_flag ("verbose", "v", "Verbose output")
        end

    do_scan
            -- Scan files for PII, report findings
        local
            l_engine: PII_DETECTION_ENGINE
            l_findings: ARRAYED_LIST [PII_FINDING]
        do
            create l_engine.make (current_options)

            across positional_args as f loop
                l_findings := l_engine.scan_file (f.item)
                report_findings (f.item, l_findings)
                audit_logger.log_scan (f.item, l_findings)
            end

            print_summary
        end

    do_mask
            -- Scan and mask PII, output sanitized files
        local
            l_engine: PII_DETECTION_ENGINE
            l_masker: MASKING_ENGINE
            l_findings: ARRAYED_LIST [PII_FINDING]
            l_content, l_masked: STRING
        do
            create l_engine.make (current_options)
            create l_masker.make (current_strategy)

            across positional_args as f loop
                l_content := read_file (f.item)
                l_findings := l_engine.scan_text (l_content)
                l_masked := l_masker.apply_all (l_content, l_findings)

                write_output (f.item, l_masked)
                audit_logger.log_mask (f.item, l_findings, current_strategy)
            end

            print_summary
        end
end
```

### simple_encryption Integration

**Purpose:** Reversible encryption for encrypt masking strategy

**Usage:**

```eiffel
class ENCRYPT_MASKING_STRATEGY
inherit
    MASKING_STRATEGY
feature
    make (a_key_file: STRING)
            -- Initialize with encryption key
        local
            l_crypto: SIMPLE_ENCRYPTION
        do
            create l_crypto.make
            l_crypto.load_key_file (a_key_file)
            encryption_engine := l_crypto
        end

    apply (a_value: STRING): STRING
            -- Encrypt the PII value
        do
            Result := "ENC:" + encryption_engine.encrypt_base64 (a_value)
        ensure
            prefixed: Result.starts_with ("ENC:")
            reversible: encryption_engine.decrypt_base64 (Result.substring (5, Result.count)).same_string (a_value)
        end

    reverse (a_masked: STRING): STRING
            -- Decrypt an encrypted value
        require
            is_encrypted: a_masked.starts_with ("ENC:")
        do
            Result := encryption_engine.decrypt_base64 (a_masked.substring (5, a_masked.count))
        end

feature {NONE}
    encryption_engine: SIMPLE_ENCRYPTION
end
```

### simple_hash Integration

**Purpose:** One-way hashing for hash masking strategy

**Usage:**

```eiffel
class HASH_MASKING_STRATEGY
inherit
    MASKING_STRATEGY
feature
    make (a_truncate_length: INTEGER)
            -- Initialize with optional truncation
        do
            truncate_length := a_truncate_length
        end

    apply (a_value: STRING): STRING
            -- Hash the PII value (non-reversible)
        local
            l_hasher: SIMPLE_HASH
            l_full_hash: STRING
        do
            create l_hasher.make
            l_full_hash := l_hasher.sha256_hex (a_value)

            if truncate_length > 0 then
                Result := l_full_hash.substring (1, truncate_length.min (l_full_hash.count))
            else
                Result := l_full_hash
            end
        ensure
            non_reversible: True  -- Cannot recover original
            consistent: apply (a_value).same_string (Result)  -- Same input = same output
        end

feature {NONE}
    truncate_length: INTEGER
end
```

### simple_json / simple_csv Integration

**Purpose:** Scan structured data files for PII

**Usage:**

```eiffel
class JSON_FILE_SCANNER
feature
    scan_json_file (a_path: STRING): ARRAYED_LIST [PII_FINDING]
            -- Scan JSON file for PII
        local
            l_json: SIMPLE_JSON
            l_detector: PII_DETECTION_ENGINE
        do
            create Result.make (20)
            create l_json.make
            create l_detector.make (detection_options)

            if attached l_json.parse_file (a_path) as l_root then
                scan_json_value (l_root, "", l_detector, Result)
            end
        end

    scan_json_value (a_value: JSON_VALUE; a_path: STRING;
                     a_detector: PII_DETECTION_ENGINE;
                     a_results: ARRAYED_LIST [PII_FINDING])
            -- Recursively scan JSON structure
        do
            if a_value.is_string then
                across a_detector.detect_in_text (a_value.as_string) as f loop
                    f.item.set_json_path (a_path)
                    a_results.extend (f.item)
                end
            elseif a_value.is_object then
                across a_value.as_object as kv loop
                    scan_json_value (kv.item, a_path + "." + kv.key, a_detector, a_results)
                end
            elseif a_value.is_array then
                across a_value.as_array as el loop
                    scan_json_value (el.item, a_path + "[" + el.cursor_index.out + "]", a_detector, a_results)
                end
            end
        end

class CSV_FILE_SCANNER
feature
    scan_csv_file (a_path: STRING): ARRAYED_LIST [PII_FINDING]
            -- Scan CSV file for PII
        local
            l_csv: SIMPLE_CSV
            l_detector: PII_DETECTION_ENGINE
            l_row: INTEGER
        do
            create Result.make (20)
            create l_csv.make_from_file (a_path)
            create l_detector.make (detection_options)

            from l_row := 1
            until l_csv.after
            loop
                scan_csv_row (l_csv.current_record, l_row, l_detector, Result)
                l_csv.forth
                l_row := l_row + 1
            end
        end
end
```

## Dependency Graph

```
pii_sentinel
    |
    +-- simple_regex (required)
    |       Core pattern matching
    |
    +-- simple_cli (required)
    |       CLI argument parsing
    |
    +-- simple_json (required)
    |       JSON scanning/output
    |
    +-- simple_csv (required)
    |       CSV scanning
    |
    +-- simple_file (required)
    |       File I/O
    |
    +-- simple_config (required)
    |       Configuration
    |
    +-- simple_encryption (optional)
    |       Encrypt masking strategy
    |
    +-- simple_hash (optional)
    |       Hash masking strategy
    |
    +-- simple_uuid (optional)
    |       Token generation
    |
    +-- simple_logger (optional)
    |       Audit logging
    |
    +-- ISE base (required)
            Core data structures
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="pii_sentinel" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0">
    <description>CLI tool for PII detection, masking, and compliance</description>

    <target name="pii_sentinel">
        <root class="PII_SENTINEL_CLI" feature="make"/>
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
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>

        <!-- Optional dependencies -->
        <library name="simple_encryption" location="$SIMPLE_EIFFEL/simple_encryption/simple_encryption.ecf"/>
        <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_uuid" location="$SIMPLE_EIFFEL/simple_uuid/simple_uuid.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>

        <!-- ISE dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
        <cluster name="patterns" location=".\patterns\" recursive="true"/>
        <cluster name="strategies" location=".\strategies\" recursive="true"/>
    </target>

    <target name="pii_sentinel_tests" extends="pii_sentinel">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="testing" location=".\testing\"/>
    </target>
</system>
```
