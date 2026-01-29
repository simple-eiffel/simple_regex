# PII-Sentinel - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI - basic scan and redact | 3-4 days | simple_regex, simple_cli, simple_file |
| Phase 2 | Full CLI - all strategies, formats | 5-6 days | Phase 1 + simple_json, simple_csv, simple_hash, simple_encryption |
| Phase 3 | Polish - audit, compliance, patterns | 4-5 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Demonstrate core PII detection: scan text files for common PII types (SSN, email, credit card), apply basic redaction masking.

### Deliverables

1. **PII_SENTINEL_CLI** - Basic argument parsing for `scan` and `mask` commands
2. **PII_PATTERN** - Single detection pattern with regex
3. **PII_PATTERN_LIBRARY** - Collection of basic patterns
4. **PII_FINDING** - Detection result with location
5. **REDACT_MASKING_STRATEGY** - Basic redaction
6. **TEXT_FILE_SCANNER** - Line-by-line text scanning

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with simple_regex, simple_cli, simple_file |
| T1.2 | Implement PII_PATTERN | Holds regex, type, compiles pattern |
| T1.3 | Implement SSN pattern | Detects XXX-XX-XXXX format |
| T1.4 | Implement email pattern | Detects standard email format |
| T1.5 | Implement credit card patterns | Visa, MasterCard, Amex |
| T1.6 | Implement PII_FINDING | Stores type, value, position |
| T1.7 | Implement REDACT_MASKING_STRATEGY | Replaces with ***REDACTED*** |
| T1.8 | Implement basic scan command | Reports findings to console |
| T1.9 | Implement basic mask command | Outputs redacted content |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| SSN detection | "SSN: 123-45-6789" | Finding: SSN at position 5 |
| Email detection | "contact@example.com" | Finding: EMAIL at position 0 |
| Credit card | "4111-1111-1111-1111" | Finding: CREDIT_CARD at position 0 |
| No PII | "Hello world" | Empty findings list |
| Multiple PII | Text with SSN and email | Two findings |
| Redaction | "SSN: 123-45-6789" | "SSN: ***REDACTED-SSN***" |

### MVP CLI Interface

```bash
# MVP scan command
pii-sentinel scan customer_notes.txt
# Output:
# Found 3 PII items in customer_notes.txt:
#   Line 5: SSN (123-45-6789)
#   Line 12: EMAIL (john@example.com)
#   Line 23: CREDIT_CARD (4111111111111111)

# MVP mask command
pii-sentinel mask customer_notes.txt -o sanitized/
# Output:
# Masked 3 PII items, output written to sanitized/customer_notes.txt
```

---

## Phase 2: Full Implementation

### Objective

Support all masking strategies (redact, partial, hash, encrypt, tokenize), JSON/CSV file formats, custom patterns, context validation.

### Deliverables

1. **PARTIAL_MASKING_STRATEGY** - Keep first/last N characters
2. **HASH_MASKING_STRATEGY** - SHA-256 one-way masking
3. **ENCRYPT_MASKING_STRATEGY** - AES reversible encryption
4. **TOKENIZE_MASKING_STRATEGY** - Lookup table tokenization
5. **JSON_FILE_SCANNER** - JSON file PII detection
6. **CSV_FILE_SCANNER** - CSV file PII detection
7. **CONTEXT_VALIDATOR** - Reduce false positives
8. **Full pattern library** - 25+ PII types

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement PARTIAL_MASKING_STRATEGY | Keeps first/last N chars |
| T2.2 | Implement HASH_MASKING_STRATEGY | SHA-256 with optional truncation |
| T2.3 | Implement ENCRYPT_MASKING_STRATEGY | AES encryption, reversible |
| T2.4 | Implement TOKENIZE_MASKING_STRATEGY | Token lookup, consistent |
| T2.5 | Implement JSON_FILE_SCANNER | Traverses JSON, reports paths |
| T2.6 | Implement CSV_FILE_SCANNER | Field-aware scanning |
| T2.7 | Implement CONTEXT_VALIDATOR | Checks surrounding text |
| T2.8 | Add phone number patterns | US, international formats |
| T2.9 | Add healthcare patterns | NPI, DEA, MRN |
| T2.10 | Add financial patterns | IBAN, routing numbers |
| T2.11 | Add authentication patterns | API keys, tokens |
| T2.12 | Add custom pattern support | Load from YAML |
| T2.13 | Implement confidence scoring | 0-100 confidence values |
| T2.14 | Add `patterns` command | List available patterns |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Partial masking | SSN with keep-last 4 | "***-**-6789" |
| Hash masking | SSN | Consistent SHA-256 hash |
| Encrypt/decrypt | SSN with key | Reversible encryption |
| Tokenize | Same SSN twice | Same token both times |
| JSON scan | Nested JSON with email | Finding with JSON path |
| CSV scan | CSV with SSN column | Finding with row/column |
| Context validation | "ID: 123-45-6789" | Higher confidence with "ID" context |
| Custom pattern | Employee ID pattern | Detects custom format |

### Full Pattern Library

```yaml
# Personal Identifiers
ssn: Social Security Number (XXX-XX-XXXX)
passport_us: US Passport Number
drivers_license: State Driver's License
national_id: National ID (various)

# Financial
credit_card_visa: Visa Card
credit_card_mc: MasterCard
credit_card_amex: American Express
credit_card_discover: Discover Card
bank_account: Bank Account Number
routing_number: ABA Routing Number
iban: International Bank Account Number

# Contact
email: Email Address
phone_us: US Phone Number
phone_intl: International Phone
address_us: US Mailing Address
ip_address: IP Address (v4/v6)

# Healthcare (PHI)
npi: National Provider Identifier
dea: DEA Number
mrn: Medical Record Number
health_plan_id: Health Plan Beneficiary Number
icd10: ICD-10 Diagnosis Code

# Authentication
api_key_generic: Generic API Key
aws_key: AWS Access Key
bearer_token: Bearer Token
private_key_pem: PEM Private Key Header
```

---

## Phase 3: Production Polish

### Objective

Comprehensive audit logging, compliance reporting (GDPR, HIPAA, PCI-DSS), performance optimization, documentation.

### Deliverables

1. **AUDIT_LOGGER** - Detailed audit trail
2. **COMPLIANCE_REPORT** - Regulatory report generation
3. **Performance optimizations** - Pattern caching, parallel scanning
4. **Documentation** - README, compliance guide
5. **CI integration** - GitHub Actions workflow

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement AUDIT_LOGGER | Logs findings, actions, timestamps |
| T3.2 | Implement audit report command | Shows historical operations |
| T3.3 | Implement GDPR report | Article 30 record format |
| T3.4 | Implement HIPAA report | PHI inventory format |
| T3.5 | Implement PCI-DSS report | Cardholder data inventory |
| T3.6 | Implement pattern caching | Compiled patterns cached |
| T3.7 | Implement parallel scanning | Multi-file concurrent processing |
| T3.8 | Add progress indicator | Shows % complete |
| T3.9 | Harden error handling | Graceful degradation |
| T3.10 | Write README | Installation, quick start |
| T3.11 | Write compliance guide | Regulatory mapping |
| T3.12 | Add GitHub Actions | Build, test, release |

### Audit Log Format

```json
{
  "timestamp": "2026-01-24T15:30:00Z",
  "operation": "scan",
  "file": "/data/customers.csv",
  "findings": [
    {
      "type": "SSN",
      "location": "row 42, column 'tax_id'",
      "confidence": 95,
      "action": "detected"
    }
  ],
  "user": "system",
  "duration_ms": 1234
}
```

### Compliance Report Example (GDPR)

```markdown
# GDPR Article 30 - Record of Processing Activities

**Generated:** 2026-01-24
**Scan Period:** 2026-01-01 to 2026-01-24

## Personal Data Inventory

| Category | Count | Files Containing | Remediation |
|----------|-------|------------------|-------------|
| Email Addresses | 1,234 | 45 files | Masked |
| Phone Numbers | 567 | 23 files | Masked |
| National IDs | 89 | 5 files | Encrypted |

## Data Subject Categories
- Customers: 1,456 records
- Employees: 234 records
- Partners: 45 records

## Retention Assessment
...
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="pii_sentinel">
    <root all_classes="true"/>
    <option warning="warning">
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="simple_regex" location="$SIMPLE_EIFFEL/simple_regex/simple_regex.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="simple_config" location="$SIMPLE_EIFFEL/simple_config/simple_config.ecf"/>
    <library name="simple_encryption" location="$SIMPLE_EIFFEL/simple_encryption/simple_encryption.ecf"/>
    <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location=".\src\"/>
    <cluster name="patterns" location=".\patterns\"/>
    <cluster name="strategies" location=".\strategies\"/>
</target>

<!-- CLI executable target -->
<target name="pii_sentinel_cli" extends="pii_sentinel">
    <root class="PII_SENTINEL_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="pii_sentinel_tests" extends="pii_sentinel">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="testing" location=".\testing\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config pii_sentinel.ecf -target pii_sentinel_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config pii_sentinel.ecf -target pii_sentinel_tests -c_compile
./EIFGENs/pii_sentinel_tests/W_code/pii_sentinel.exe

# Compile for release (finalized)
/d/prod/ec.sh -batch -config pii_sentinel.ecf -target pii_sentinel_cli -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| CLI works | All commands functional | Verified |
| Detection accuracy | True positive rate | >99% |
| False positive rate | Clean data test | <2% |
| Pattern coverage | PII types supported | 25+ |
| Documentation | README + compliance guide | Complete |
