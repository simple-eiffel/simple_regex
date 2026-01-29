# PII-Sentinel - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                         PII-Sentinel                              |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing (scan, mask, report, audit)                  |
|    - Output formatting (text, json, csv)                          |
+------------------------------------------------------------------+
|  Detection Engine Layer                                           |
|    - Pattern library (SSN, CC, email, phone, etc.)                |
|    - Custom pattern support                                       |
|    - Context validation (reduce false positives)                  |
+------------------------------------------------------------------+
|  Masking Engine Layer                                             |
|    - Redaction (replace with ***REDACTED***)                      |
|    - Partial masking (keep first/last N chars)                    |
|    - Hashing (SHA-256 one-way)                                    |
|    - Encryption (reversible with key)                             |
|    - Tokenization (lookup table)                                  |
+------------------------------------------------------------------+
|  Audit Layer                                                      |
|    - Detection logging (what, where, when)                        |
|    - Action logging (how it was handled)                          |
|    - Compliance report generation                                 |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - File I/O (simple_file)                                       |
|    - JSON/CSV parsing (simple_json, simple_csv)                   |
|    - Encryption (simple_encryption)                               |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| `PII_SENTINEL_CLI` | Command-line interface | parse_args, route_command, format_output |
| `PII_DETECTION_ENGINE` | Core detection orchestrator | scan_text, scan_file, scan_field |
| `PII_PATTERN` | Single detection pattern | pattern, type, validation_rules |
| `PII_PATTERN_LIBRARY` | Collection of patterns | load_patterns, detect_all, add_custom |
| `PII_FINDING` | Single detection result | type, value, location, confidence |
| `MASKING_ENGINE` | Apply masking strategies | redact, partial_mask, hash, encrypt, tokenize |
| `MASKING_STRATEGY` | Strategy configuration | strategy_type, options, apply |
| `AUDIT_LOGGER` | Detection and action logging | log_finding, log_action, generate_report |
| `COMPLIANCE_REPORT` | Regulatory report generation | gdpr_report, hipaa_report, pci_report |

### Command Structure

```bash
pii-sentinel <command> [options] [files...]

Commands:
  scan        Detect PII in files (default, report only)
  mask        Detect and mask PII, output sanitized files
  report      Generate compliance report from scan/mask results
  audit       Show audit trail for previous operations
  patterns    List or describe available patterns

Detection Options:
  -p, --patterns LIST     PII types to detect (ssn,cc,email,phone,...)
  --all                   Detect all known PII types
  --custom FILE           Load custom patterns from file
  --min-confidence N      Minimum confidence threshold (0-100)
  --context-validation    Enable context-aware validation

Masking Options:
  -s, --strategy NAME     Masking strategy (redact, partial, hash, encrypt)
  --keep-first N          Keep first N characters (for partial)
  --keep-last N           Keep last N characters (for partial)
  --key FILE              Encryption key file (for encrypt strategy)
  --token-map FILE        Token mapping file (for tokenize strategy)

Output Options:
  -o, --output DIR        Output directory for masked files
  --output-format FMT     Report format (text, json, csv)
  --in-place              Modify files in place (CAUTION)
  --suffix SUFFIX         Suffix for output files (default: .masked)

Audit Options:
  --audit-log FILE        Audit log file path
  --audit-level LEVEL     Audit detail (minimal, standard, detailed)
  --no-audit              Disable audit logging

Global Options:
  --config FILE           Configuration file
  --quiet                 Only output findings count
  --verbose               Include detection details
  --help                  Show help
  --version               Show version
```

### PII Pattern Categories

```
PERSONAL IDENTIFIERS
  - SSN (Social Security Number)
  - Passport Number
  - Driver's License
  - National ID (various countries)

FINANCIAL DATA
  - Credit Card Numbers (Visa, MC, Amex, Discover)
  - Bank Account Numbers
  - Routing Numbers
  - IBAN

CONTACT INFORMATION
  - Email Addresses
  - Phone Numbers (US, international)
  - Mailing Addresses

HEALTHCARE (PHI)
  - Medical Record Numbers
  - Health Plan IDs
  - DEA Numbers
  - NPI Numbers
  - ICD-10 Codes

AUTHENTICATION
  - Passwords (common patterns)
  - API Keys (common formats)
  - Bearer Tokens
  - Private Keys (PEM headers)
```

### Data Flow

```
Input Files         Pattern Library        Audit Log
     |                    |                   ^
     v                    v                   |
[File Reader] -----> [Detector] -----------> [Audit Logger]
     |                    |                   |
     |                    v                   |
     |              [Validator]               |
     |              (context check)           |
     |                    |                   |
     |                    v                   |
     |              [PII_FINDING]             |
     |                    |                   |
     |                    v                   |
     +------------> [Masker] --------------> [Report]
                          |
                          v
                   [Output Writer]
                          |
                          v
                   Sanitized Files
```

### Configuration Schema

**Pattern Configuration:**

```yaml
# pii-patterns.yaml
patterns:
  ssn:
    name: "Social Security Number"
    regex: '\b(?!000|666|9\d{2})\d{3}-(?!00)\d{2}-(?!0000)\d{4}\b'
    type: personal
    confidence: 95
    validation:
      - no_sequential
      - no_repeated
    context_hints:
      - ssn
      - social security
      - tax id

  credit_card:
    name: "Credit Card Number"
    patterns:
      visa: '\b4[0-9]{12}(?:[0-9]{3})?\b'
      mastercard: '\b5[1-5][0-9]{14}\b'
      amex: '\b3[47][0-9]{13}\b'
    type: financial
    confidence: 90
    validation:
      - luhn_checksum
    context_hints:
      - card
      - credit
      - payment

  email:
    name: "Email Address"
    regex: '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    type: contact
    confidence: 98
```

**Application Config:**

```json
{
  "pii_sentinel": {
    "default_strategy": "redact",
    "default_patterns": ["ssn", "credit_card", "email", "phone"],
    "audit_enabled": true,
    "audit_level": "standard",
    "min_confidence": 80,
    "context_validation": true
  }
}
```

### Masking Strategies

| Strategy | Description | Example Input | Example Output |
|----------|-------------|---------------|----------------|
| `redact` | Replace with marker | `123-45-6789` | `***REDACTED-SSN***` |
| `partial` | Keep first/last N | `123-45-6789` | `***-**-6789` |
| `hash` | One-way SHA-256 | `123-45-6789` | `a7f5d2...` (first 12 chars) |
| `encrypt` | Reversible AES | `123-45-6789` | `ENC:base64data==` |
| `tokenize` | Lookup replacement | `123-45-6789` | `TOK:SSN-00001` |

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Invalid pattern | Skip pattern, warn | "Invalid pattern '{name}': {error}" |
| File not found | Skip file, report | "File not found: {path}" |
| Permission denied | Skip file, report | "Cannot read file: {path}" |
| Encryption key missing | Fail fast | "Encryption requires --key option" |
| Invalid strategy | Fail fast | "Unknown strategy: {name}" |
| Audit write failure | Warn, continue | "Could not write audit log: {error}" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Interactive Review TUI** - Review findings, approve/reject, adjust masking
2. **Pattern Builder GUI** - Visual pattern testing with sample data
3. **Compliance Dashboard** - PII inventory, trends, risk assessment

**Shared components between CLI/GUI:**
- `PII_PATTERN_LIBRARY` - Pattern storage and detection
- `PII_DETECTION_ENGINE` - Core detection logic
- `MASKING_ENGINE` - Masking strategy application
- `AUDIT_LOGGER` - Audit trail management

**CLI-specific components:**
- `PII_SENTINEL_CLI` - Argument parsing, console output
- Progress indicators, color formatting

**GUI-specific components (future):**
- Finding review interface
- Pattern editor with live testing
- Compliance report viewer
- Audit trail browser
