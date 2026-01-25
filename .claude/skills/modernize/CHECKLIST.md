# AI-Assisted Brownfield Modernization Checklist

> A comprehensive checklist incorporating Chain-of-Verification (CoVe), self-correction loops, and validation harnesses for systematic, validated AI-assisted modernization of brownfield projects.

---

## Table of Contents

1. [Phase 1: Repository Analysis & Baseline Establishment](#phase-1-repository-analysis--baseline-establishment)
2. [Phase 2: Validation Harness Setup](#phase-2-validation-harness-setup)
3. [Phase 3: Architecture Documentation with Verification](#phase-3-architecture-documentation-with-verification)
4. [Phase 4: Modernization Planning with Validation](#phase-4-modernization-planning-with-validation)
5. [Phase 5: CI/CD Pipeline Development](#phase-5-cicd-pipeline-development-with-validation)
6. [Phase 6: Review Cycles & Hallucination Detection](#phase-6-review-cycles--hallucination-detection)
7. [Phase 7: Comprehensive Documentation Generation](#phase-7-comprehensive-documentation-generation)
8. [Phase 8: Continuous Validation Loop](#phase-8-continuous-validation-loop)

---

## Phase 1: Repository Analysis & Baseline Establishment

### 1.1 Initial Codebase Inventory with Verification Loop

**Best Practice:** Use AST parsing to catalog all code entities, then verify completeness through cross-referencing.

**Checklist:**

- [ ] Parse repository with language-appropriate AST tools
- [ ] Generate inventory of functions, classes, modules
- [ ] Verify file counts match directory traversal
- [ ] Identify dynamic imports/requires not captured by static analysis
- [ ] Exclude generated/build files from analysis
- [ ] Document any files requiring manual review

**Example Verification Loop:**

```
Step 1 (Analysis): Parse repository with tree-sitter/AST tools
- Generate inventory: 247 functions, 89 classes, 34 modules

Step 2 (Verification Questions):
- Are there any dynamic imports not captured by static AST?
- Do file counts match directory traversal results?
- Are generated/build files excluded from analysis?

Step 3 (Verification Execution):
- Run: find . -name "*.py" | wc -l → Compare with AST file count
- Check import statements for exec() or __import__() patterns
- Validate .gitignore exclusions applied

Step 4 (Corrected Output):
- Actual inventory: 247 functions, 89 classes, 34 modules, 12 dynamic imports flagged for manual review
```

### 1.2 Dependency Graph Construction with Validation

**Best Practice:** Build dependency graph, then validate against actual runtime behavior.

**Checklist:**

- [ ] Create static dependency map from import analysis
- [ ] Identify circular dependencies
- [ ] Flag runtime dependencies (reflection, dynamic loading)
- [ ] Verify external dependency versions match lock files
- [ ] Document dependency relationships in graph format

**Example Verification Loop:**

```
Step 1 (Initial Graph): Create dependency map using import analysis
Module A → Module B → Module C

Step 2 (Verification):
- grep for dynamic imports: getattr, __import__, importlib
- Check for circular import patterns
- Cross-reference with package manager lock file

Step 3 (Self-Correction):
- Discovery: Module A has runtime dependency on Module D via getattr()
- Updated graph: Module A → [Module B, Module D*] → Module C
- Flag D* as runtime dependency requiring integration testing
```

### 1.3 Security & Quality Baseline with Fact-Checking

**Best Practice:** Run security scans, verify findings against false-positive patterns.

**Checklist:**

- [ ] Run static security analysis (bandit, CodeQL, semgrep)
- [ ] Categorize findings by severity
- [ ] Verify each critical/high finding manually
- [ ] Document false positives with reasoning
- [ ] Establish security baseline metrics
- [ ] Create remediation priority list

**Example Verification Loop:**

```
Step 1 (Scan): bandit -r src/ -f json
- Result: 23 potential security issues detected

Step 2 (Verification Loop):
- For each finding, check if mitigation exists
- Cross-reference with framework security features
- Test: Attempt exploitation in isolated environment

Step 3 (Validated Output):
- 23 findings → 8 true positives, 15 false positives (framework-protected)
- Document: "8 security issues require remediation in auth.py:45, users.py:123..."
```

### 1.4 Terraform/IaC Analysis (Project-Specific)

**Best Practice:** Validate infrastructure code against cloud provider state.

**Checklist:**

- [ ] Run `terraform validate` to check syntax
- [ ] Run `terraform plan` to detect drift
- [ ] Review IAM policies for least-privilege violations
- [ ] Check for hardcoded secrets in IaC files
- [ ] Verify resource naming conventions
- [ ] Document infrastructure dependencies

**Example Verification Loop:**

```
Step 1 (Analysis): terraform validate && terraform plan
- Parse all .tf files for resource definitions

Step 2 (Verification):
- Compare plan output with documented architecture
- Check IAM policy resources for "*" permissions
- Grep for potential secrets: grep -r "password\|secret\|key" *.tf

Step 3 (Findings):
- IAM policy in iam.tf:23 uses resources: "*" for SSM
- Recommendation: Scope to specific SSM parameter paths
```

---

## Phase 2: Validation Harness Setup

### 2.1 Type Checking Infrastructure with Self-Correction

**Best Practice:** Implement strict type checking, use failures as ground truth for AI corrections.

**Checklist:**

- [ ] Install type checker (mypy, pyright for Python; tsc for TypeScript)
- [ ] Configure strict mode settings
- [ ] Add type stubs for untyped dependencies
- [ ] Run initial type check to establish baseline
- [ ] Document type errors requiring manual resolution

**Example Verification Loop:**

```
Step 1 (Setup): Add mypy with strict configuration
[mypy]
strict = true
warn_return_any = true
disallow_untyped_defs = true

Step 2 (AI Adds Types): AI suggests type annotations
def process_data(data):  # Before
def process_data(data: List[Dict[str, Any]]) -> pd.DataFrame:  # After

Step 3 (Validation Loop):
- Run: mypy src/
- Error: "Argument 1 has incompatible type List[Dict[str, str]]"
- AI Self-Correction: Analyze actual data flow
- Corrected: def process_data(data: List[Dict[str, Union[str, int]]]) -> pd.DataFrame:

Step 4 (Verify): mypy passes → Accept change
```

### 2.2 Linting Rules as Validation Gates

**Best Practice:** Configure linters as automatic hallucination detectors.

**Checklist:**

- [ ] Install language-appropriate linters (pylint, eslint, tflint)
- [ ] Configure project-specific rules
- [ ] Enable all warnings initially, then tune
- [ ] Set up pre-commit hooks for linting
- [ ] Document intentional rule suppressions

**Example Verification Loop:**

```
Step 1 (Configure): .pylintrc with project-specific rules
[MESSAGES CONTROL]
enable=all

Step 2 (AI Refactors Code):
# AI suggests:
def calculate_total(items):
    sum = 0  # Shadows built-in
    for item in items:
        sum += item.price
    return sum

Step 3 (Linting Catches Error):
pylint src/calculator.py
→ W0622: Redefining built-in 'sum'

Step 4 (AI Self-Correction):
def calculate_total(items):
    total = 0
    for item in items:
        total += item.price
    return total
```

### 2.3 Test Harness as Ground Truth

**Best Practice:** Existing tests must pass; new code requires tests before acceptance.

**Checklist:**

- [ ] Verify test framework is installed and configured
- [ ] Run existing test suite, document failures
- [ ] Measure baseline code coverage
- [ ] Configure coverage thresholds
- [ ] Set up test isolation (fixtures, mocks)
- [ ] Document untestable code requiring refactoring

**Example Verification Loop:**

```
Step 1 (Baseline): Run existing test suite
pytest tests/ --cov=src
→ 156 passed, 12 failed, 67% coverage

Step 2 (AI Refactors Module):
# AI modernizes authentication.py

Step 3 (Validation Gate):
pytest tests/test_authentication.py
→ 8 passed, 4 failed

Step 4 (Self-Correction Loop):
- AI analyzes failures: "Expected bcrypt, code uses argon2"
- AI checks git history: "Migration to argon2 in commit abc123"
- AI corrects refactoring to preserve argon2
- Rerun: 12 passed, 0 failed → Accept change

Step 5 (New Test Requirement):
- AI adds new feature: rate limiting
- Validation gate: "No tests found for rate_limiter.py"
- AI generates tests before feature accepted
```

### 2.4 Terraform Validation Harness

**Best Practice:** Use terraform validate and plan as infrastructure validation gates.

**Checklist:**

- [ ] Set up terraform init with backend configuration
- [ ] Configure terraform validate in CI
- [ ] Run terraform plan with -detailed-exitcode
- [ ] Set up tflint for additional validation
- [ ] Configure checkov/tfsec for security scanning

**Example Verification Loop:**

```
Step 1 (Validate): terraform validate
→ Success! The configuration is valid.

Step 2 (Plan): terraform plan -detailed-exitcode
→ Exit code 2: Changes detected

Step 3 (Security Scan): tfsec .
→ 3 issues found: AWS004, AWS017, AWS019

Step 4 (Self-Correction):
- AI reviews each finding
- Corrects IAM policy scope
- Re-runs: tfsec passes → Accept change
```

---

## Phase 3: Architecture Documentation with Verification

### 3.1 System Architecture Mapping with Cross-Validation

**Best Practice:** Generate architecture diagrams, validate against actual runtime behavior.

**Checklist:**

- [ ] Analyze imports and class relationships
- [ ] Generate component diagram
- [ ] Identify architectural layers
- [ ] Validate static analysis against runtime traces
- [ ] Document architectural violations
- [ ] Create architecture decision records (ADRs)

**Example Verification Loop:**

```
Step 1 (Static Analysis): AI analyzes imports and class relationships
Generated architecture:
[Web Layer] → [Service Layer] → [Data Layer]

Step 2 (Verification Questions):
- Does runtime behavior match static structure?
- Are there circular dependencies?
- Do deployment boundaries align with logical boundaries?

Step 3 (Runtime Validation):
- Add logging to trace actual call paths
- Run integration tests with call graph profiling
- Result: Service Layer directly calls Database in 3 locations

Step 4 (Corrected Architecture):
[Web Layer] → [Service Layer] ⇄ [Data Layer]
                ↓ (3 legacy paths - marked for refactoring)
            [Database]
```

### 3.2 Component Relationship Documentation with Fact-Checking

**Best Practice:** Document each component's purpose, validate against actual usage.

**Checklist:**

- [ ] Document purpose of each module/package
- [ ] Identify component responsibilities
- [ ] Verify documentation against grep/usage analysis
- [ ] Document public APIs and contracts
- [ ] Identify coupling and cohesion issues

**Example Verification Loop:**

```
Step 1 (AI Documentation):
"UserService: Handles user authentication and profile management"

Step 2 (Verification):
- grep -r "UserService" --include="*.py"
- Find actual usage: Also handles notifications, password resets

Step 3 (Self-Correction):
"UserService: Manages user lifecycle including authentication,
profile management, session handling, password resets, and
user-related notifications.
Note: Email functionality should be extracted (see issue #234)"

Step 4 (Cross-Reference):
- Verify issue #234 exists in tracker
- Documentation now matches reality + planned improvements
```

### 3.3 Data Flow Documentation

**Best Practice:** Map data flows, validate against actual data paths.

**Checklist:**

- [ ] Identify data entry points (APIs, events, files)
- [ ] Trace data transformation steps
- [ ] Document data storage locations
- [ ] Identify sensitive data flows
- [ ] Validate flows against logs/traces

---

## Phase 4: Modernization Planning with Validation

### 4.1 Task Breakdown with Dependency Validation

**Best Practice:** Generate task list, validate dependencies through build simulation.

**Checklist:**

- [ ] Break down modernization into discrete tasks
- [ ] Identify task dependencies
- [ ] Validate dependency order through simulation
- [ ] Create rollback plans for each task
- [ ] Define acceptance criteria with automated tests

**Example Verification Loop:**

```
Step 1 (AI Task Generation):
Task 1: Upgrade Python 3.6 → 3.11
Task 2: Migrate unittest → pytest
Task 3: Add type hints
Task 4: Update dependencies

Step 2 (Dependency Verification):
- Question: Can we upgrade Python before updating dependencies?
- Simulate: Create test branch, attempt Python upgrade
- Result: 12 dependencies incompatible with Python 3.11

Step 3 (Corrected Task Order):
Task 1: Audit dependencies for Python 3.11 compatibility
Task 2: Update/replace incompatible dependencies
Task 3: Upgrade Python 3.6 → 3.11
Task 4: Migrate unittest → pytest
Task 5: Add type hints

Step 4 (Validation):
- Each task includes rollback plan
- Each task has acceptance criteria with automated tests
```

### 4.2 Risk Assessment with Historical Validation

**Best Practice:** Identify high-risk changes, validate risk level against history.

**Checklist:**

- [ ] Categorize tasks by risk level
- [ ] Review git history for similar past changes
- [ ] Assess test coverage for affected areas
- [ ] Identify dependent systems
- [ ] Plan mitigation strategies

**Example Verification Loop:**

```
Step 1 (AI Risk Assessment):
"Refactoring authentication system: Medium Risk"

Step 2 (Verification Questions):
- What was the impact of previous auth changes?
- How many systems depend on current auth implementation?
- What is test coverage for auth module?

Step 3 (Historical Analysis):
- Git log: Last auth change caused production issues
- Dependency scan: 47 modules import authentication
- Coverage: 34% (below project average)

Step 4 (Corrected Risk Assessment):
"Refactoring authentication system: HIGH RISK
- Previous auth changes caused production issues
- 47 dependent modules require regression testing
- Test coverage must increase to 90% before refactoring
- Requires feature flag for gradual rollout"
```

### 4.3 Incremental Migration Strategy

**Best Practice:** Plan incremental changes, validate each increment independently.

**Checklist:**

- [ ] Define migration increments
- [ ] Ensure each increment is deployable
- [ ] Create feature flags for gradual rollout
- [ ] Plan monitoring for each increment
- [ ] Define rollback triggers

---

## Phase 5: CI/CD Pipeline Development with Validation

### 5.1 Pipeline Design with Failure Simulation

**Best Practice:** Design pipeline stages, validate by simulating failure scenarios.

**Checklist:**

- [ ] Define pipeline stages (lint, test, security, build, deploy)
- [ ] Configure blocking vs. non-blocking stages
- [ ] Simulate failure scenarios for each stage
- [ ] Configure retry logic for flaky operations
- [ ] Set up notifications for failures

**Example Verification Loop:**

```
Step 1 (AI Pipeline Design):
stages:
  - lint
  - test
  - build
  - deploy

Step 2 (Verification Questions):
- What happens if linting fails but tests pass?
- Can we deploy if build succeeds but tests are skipped?
- How do we handle flaky tests?

Step 3 (Failure Simulation):
- Introduce intentional lint error → Pipeline should stop
- Skip test stage → Pipeline should fail
- Flaky test fails → Entire deployment blocked

Step 4 (Corrected Pipeline):
stages:
  - lint (blocking)
  - security-scan (blocking)
  - unit-tests (blocking, retry 3x)
  - integration-tests (blocking)
  - build (blocking)
  - deploy-staging (manual approval)
  - deploy-production (manual approval + review)

validation:
  - All stages must explicitly pass (no skips)
  - Flaky tests isolated and tracked separately
```

### 5.2 Docker Build Optimization with Validation

**Best Practice:** Create Docker images, validate build reproducibility and caching.

**Checklist:**

- [ ] Create multi-stage Dockerfile
- [ ] Verify build reproducibility (same hash)
- [ ] Optimize layer caching
- [ ] Minimize image size
- [ ] Scan for vulnerabilities

**Example Verification Loop:**

```
Step 1 (AI Dockerfile):
FROM python:3.11
COPY . /app
RUN pip install -r requirements.txt

Step 2 (Verification):
- Build twice: Compare image hashes
- Result: Different hashes (non-reproducible)
- Check: pip installs latest versions, not pinned

Step 3 (Self-Correction):
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /usr/local/lib/python3.11/site-packages ...
COPY . /app

Step 4 (Validation):
- Build twice: Hashes match ✓
- Layer caching works ✓
- Image size reduced ✓
```

### 5.3 GitHub Actions Workflow

**Best Practice:** Create comprehensive CI workflow with all validation gates.

**Checklist:**

- [ ] Configure workflow triggers (push, PR, schedule)
- [ ] Set up job dependencies
- [ ] Configure caching for dependencies
- [ ] Add security scanning step
- [ ] Configure deployment stages

---

## Phase 6: Review Cycles & Hallucination Detection

### 6.1 Code Review with Fact-Checking Protocol

**Best Practice:** AI-generated code must pass multi-stage verification before human review.

**Checklist:**

- [ ] Run linting on all generated code
- [ ] Run type checking on all generated code
- [ ] Run security scan on all generated code
- [ ] Execute relevant tests
- [ ] Verify all claims in comments/docstrings

**Example Verification Loop:**

```
Step 1 (AI Generates Code):
def fetch_user_data(user_id: int) -> Dict:
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query).fetchone()

Step 2 (Automated Verification Gates):
Gate 1 - Linting: ✓ Passes
Gate 2 - Type Checking: ✓ Passes
Gate 3 - Security Scan: ✗ FAILS (SQL injection)

Step 3 (AI Self-Correction):
def fetch_user_data(user_id: int) -> Optional[Dict[str, Any]]:
    query = "SELECT * FROM users WHERE id = ?"
    result = db.execute(query, (user_id,)).fetchone()
    return dict(result) if result else None

Step 4 (Re-verification):
All gates pass → Ready for human review
```

### 6.2 Documentation Accuracy Validation

**Best Practice:** Cross-reference documentation claims against actual code.

**Checklist:**

- [ ] Verify file/function references exist
- [ ] Verify version numbers match reality
- [ ] Verify configuration values match code
- [ ] Verify API signatures match implementation
- [ ] Test code examples for correctness

**Example Verification Loop:**

```
Step 1 (AI Documentation):
"The caching layer uses Redis with a 1-hour TTL for all queries."

Step 2 (Verification Protocol):
- grep for Redis config: grep -r "REDIS" config/
- Check TTL settings: grep -r "ttl\|expire" src/cache/
- Find actual values: TTL varies (5min to 24hrs)

Step 3 (Self-Correction):
"The caching layer uses Redis with variable TTL:
- User profiles: 1 hour (3600s)
- Preferences: 24 hours (86400s)
- Sessions: 5 minutes (300s)
Config: config/cache_settings.py:15-23"

Step 4 (Validation):
- Code references verified ✓
- TTL values match code ✓
```

### 6.3 Hallucination Detection Checklist

**Best Practice:** Apply systematic checks for common AI hallucination patterns.

**Checklist:**

- [ ] Verify all file paths exist
- [ ] Verify all function/class names exist
- [ ] Verify all version numbers are accurate
- [ ] Verify all configuration values match
- [ ] Verify all performance claims with benchmarks
- [ ] Verify all dependency claims against lock files

**Verification Commands:**

```bash
# Dependency claims
grep "package_name" requirements.txt package.json

# Version claims
python --version
terraform --version
grep "version" package.json

# File existence
ls -la path/to/claimed/file

# Function existence
grep -n "def function_name" src/

# Config values
grep "CONFIG_KEY" .env config/*.py

# Coverage claims
pytest --cov=src --cov-report=term
```

---

## Phase 7: Comprehensive Documentation Generation

### 7.1 Per-Directory README with Validation

**Best Practice:** Generate contextual README for each directory, validate against contents.

**Checklist:**

- [ ] List all files in directory
- [ ] Document purpose of each file
- [ ] Verify file descriptions against code
- [ ] Include usage examples (tested)
- [ ] Cross-reference with related directories

**Example Verification Loop:**

```
Step 1 (AI Generates): src/services/README.md
"# Services Layer
Contains business logic services.
## Files:
- user_service.py: User management
- auth_service.py: Authentication"

Step 2 (Verification):
- ls src/services/
  → user_service.py, auth_service.py, email_service.py, payment_service.py

Step 3 (Self-Correction):
Add missing files, expand descriptions with verified details

Step 4 (Validation):
- File count matches ✓
- Import statements verified ✓
- Test commands work ✓
```

### 7.2 API Documentation with Testing

**Best Practice:** Generate API docs, validate with actual API calls.

**Checklist:**

- [ ] Document all endpoints/functions
- [ ] Include request/response examples
- [ ] Test all examples for correctness
- [ ] Document error responses
- [ ] Verify authentication requirements

### 7.3 Architecture Decision Records

**Best Practice:** Document architectural decisions with context and validation.

**Checklist:**

- [ ] Document decision context
- [ ] List options considered
- [ ] Explain chosen approach
- [ ] Document consequences
- [ ] Link to related code/docs

---

## Phase 8: Continuous Validation Loop

### 8.1 Pre-Commit Validation Harness

**Best Practice:** Implement automated validation before any code is committed.

**Configuration (.pre-commit-config.yaml):**

```yaml
repos:
  - repo: local
    hooks:
      - id: type-check
        name: Type Checking
        entry: mypy src/
        language: system
        pass_filenames: false

      - id: lint
        name: Linting
        entry: pylint src/
        language: system
        pass_filenames: false

      - id: security-scan
        name: Security Scan
        entry: bandit -r src/
        language: system
        pass_filenames: false

      - id: terraform-validate
        name: Terraform Validate
        entry: terraform validate
        language: system
        files: \.tf$

      - id: tests
        name: Run Tests
        entry: pytest tests/ -x
        language: system
        pass_filenames: false
```

### 8.2 Documentation Drift Detection

**Best Practice:** Automatically detect when code changes make documentation inaccurate.

**Checklist:**

- [ ] Monitor function signature changes
- [ ] Track configuration value changes
- [ ] Alert on undocumented public API changes
- [ ] Flag outdated code examples
- [ ] Schedule periodic documentation audits

### 8.3 Continuous Improvement Metrics

**Best Practice:** Track modernization progress with metrics.

**Metrics to Track:**

- [ ] Test coverage percentage
- [ ] Lint error count
- [ ] Type coverage percentage
- [ ] Security finding count
- [ ] Documentation coverage
- [ ] Dependency freshness

---

## Quick Reference: Verification Commands

```bash
# Python type checking
mypy src/ --strict

# Python linting
pylint src/ --exit-zero

# Python security
bandit -r src/ -f json

# Python tests
pytest tests/ --cov=src --cov-report=term

# Terraform validation
terraform validate
terraform plan -detailed-exitcode

# Terraform security
tflint .
tfsec .
checkov -d .

# Dependency audit
pip-audit
npm audit
safety check

# File existence verification
ls -la <path>

# Code search
grep -rn "pattern" src/

# Git history
git log --oneline -20
git log -p -- <file>
```

---

## Summary: The Self-Correction Loop

Every AI action follows this pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    CHAIN OF VERIFICATION                     │
├─────────────────────────────────────────────────────────────┤
│  1. GENERATE: AI produces initial output                    │
│  2. QUESTION: AI generates verification questions           │
│  3. VERIFY: Execute verification commands                   │
│  4. CORRECT: AI self-corrects based on verification         │
│  5. VALIDATE: Run through validation harness                │
│  6. ACCEPT: Only accept if all validations pass             │
└─────────────────────────────────────────────────────────────┘
```

This ensures accuracy, eliminates hallucinations, and produces reliable modernization artifacts that human developers can trust.
