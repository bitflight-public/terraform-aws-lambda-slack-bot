# Brownfield Modernization Orchestrator

## Description

Orchestrate concurrent agents through a comprehensive brownfield modernization checklist. This skill coordinates multiple specialist agents to analyze, validate, and document codebase improvements while maintaining checkpoint state for resumable sessions.

## Usage

```
/modernize              # Start or resume modernization workflow
/modernize --init       # Initialize a new modernization project
/modernize --resume     # Resume from last checkpoint
/modernize --status     # View current progress
/modernize --agents <list>  # Run specific agents (e.g., --agents architecture,security)
```

## Overview

This skill implements a Chain-of-Verification (CoVe) approach to brownfield modernization where:
1. AI generates initial analysis
2. Verification questions are generated
3. Questions are answered against ground truth (tests, linting, type checks)
4. Final verified output is produced with self-corrections

## Workflow Phases

### Phase 1: Initialize Checkpoint

When starting a new modernization (`--init`):

1. Create `MODERNIZATION_CHECKPOINT.md` from template
2. Run initial repository scan
3. Establish baseline metrics (test coverage, linting errors, type check status)
4. Populate checkpoint with initial state

```bash
# Initialize checkpoint
bash .claude/skills/modernize/scripts/init-checkpoint.sh
```

### Phase 2: Orchestrate Specialist Agents

Deploy specialist agents in parallel where dependencies allow:

**Wave 1 (Independent Analysis)**:
- `architecture-reviewer`: Analyze code structure and design patterns
- `security-auditor`: Review security vulnerabilities and IAM
- `dependency-manager`: Evaluate and audit dependencies

**Wave 2 (Requires Wave 1 findings)**:
- `testing-specialist`: Assess test coverage and quality

**Wave 3 (Synthesis)**:
- Aggregate all findings
- Cross-validate recommendations
- Resolve conflicting guidance

### Phase 3: Validation Harness Execution

For each agent's recommendations, execute validation:

```
┌─────────────────────────────────────────────────────────┐
│                 VALIDATION HARNESS                       │
├─────────────────────────────────────────────────────────┤
│  1. Type Checking    → mypy --strict src/               │
│  2. Linting          → pylint src/ --exit-zero          │
│  3. Security Scan    → bandit -r src/ -f json           │
│  4. Test Execution   → pytest tests/ --cov=src          │
│  5. Terraform Valid  → terraform validate               │
│  6. Terraform Plan   → terraform plan -input=false      │
└─────────────────────────────────────────────────────────┘
```

### Phase 4: Checkpoint Update & Reporting

After each agent completes:

1. Update `MODERNIZATION_CHECKPOINT.md` with findings
2. Mark completed tasks
3. Record blockers and dependencies
4. Commit checkpoint to git

```bash
# Update progress
bash .claude/skills/modernize/scripts/update-progress.sh <category> <task> <status> "<notes>"
```

## Agent Orchestration Instructions

When `/modernize` is invoked, follow this execution plan:

### Step 1: Check for Existing Checkpoint

```python
# Pseudo-code for orchestration logic
if exists("MODERNIZATION_CHECKPOINT.md"):
    if "--init" in args:
        confirm_overwrite()
    else:
        load_checkpoint()
        display_status()
        resume_from_last_task()
else:
    initialize_new_checkpoint()
```

### Step 2: Launch Parallel Agents

Use the Task tool to spawn agents concurrently:

```
# Launch Wave 1 agents in parallel
Task(subagent_type="Explore", description="Architecture review", run_in_background=true)
Task(subagent_type="Explore", description="Security audit", run_in_background=true)
Task(subagent_type="Explore", description="Dependency analysis", run_in_background=true)
```

### Step 3: Collect and Validate Results

For each agent result:
1. Parse findings
2. Run validation harness against recommendations
3. Self-correct any hallucinations detected
4. Update checkpoint

### Step 4: Generate Summary Report

After all agents complete:
1. Aggregate findings by priority
2. Identify cross-cutting concerns
3. Generate actionable roadmap
4. Save final checkpoint state

## Hallucination Detection Protocol

Apply these checks to all AI-generated content:

### Verification Gates

| Claim Type | Verification Method | Action on Failure |
|------------|---------------------|-------------------|
| File exists | `ls -la <path>` | Remove claim |
| Function signature | `grep -n "def <name>" <file>` | Correct signature |
| Dependency version | `grep <pkg> requirements.txt` | Update version |
| Test coverage | `pytest --cov` | Correct percentage |
| Config value | `grep <key> <config_file>` | Fix value |

### Self-Correction Loop

```
┌──────────────────────────────────────────────────────────┐
│                    SELF-CORRECTION LOOP                   │
├──────────────────────────────────────────────────────────┤
│  1. Generate initial analysis/recommendation             │
│  2. Extract verifiable claims                            │
│  3. For each claim:                                      │
│     a. Generate verification command                     │
│     b. Execute verification                              │
│     c. Compare result to claim                           │
│     d. If mismatch: correct claim, document correction   │
│  4. Output verified analysis with corrections noted      │
└──────────────────────────────────────────────────────────┘
```

## Checkpoint Schema

The `MODERNIZATION_CHECKPOINT.md` tracks:

```yaml
session:
  id: <unique-session-id>
  started: <ISO-8601-timestamp>
  last_updated: <ISO-8601-timestamp>

baseline:
  test_coverage: <percentage>
  lint_errors: <count>
  type_errors: <count>
  security_findings: <count>

agents:
  architecture-reviewer:
    status: pending|in_progress|completed|blocked
    started: <timestamp>
    completed: <timestamp>
    findings_count: <number>

tasks:
  - id: <task-id>
    category: architecture|security|testing|dependencies|documentation
    description: <text>
    status: pending|in_progress|completed|blocked
    agent: <agent-name>
    started: <timestamp>
    completed: <timestamp>
    notes: <text>
    verification:
      command: <verification-command>
      expected: <expected-result>
      actual: <actual-result>
      passed: true|false

findings:
  critical: []
  high: []
  medium: []
  low: []

next_steps: []
```

## Resuming Interrupted Sessions

If a session is interrupted:

1. **Automatic**: Claude's built-in checkpointing preserves state
2. **Manual**: Load `MODERNIZATION_CHECKPOINT.md` to see last known state
3. **Agent Resume**: Use agent IDs to continue specific agent work

```
# Resume specific agent
Task(resume="<agent-id>", description="Continue architecture review")
```

## Integration with CI/CD

The skill can generate CI/CD configurations based on findings:

1. **Pre-commit hooks**: Enforce validation gates locally
2. **GitHub Actions**: Automated validation pipeline
3. **Docker**: Containerized build/test environment

## Output Artifacts

The skill produces:

1. `MODERNIZATION_CHECKPOINT.md` - Progress tracking document
2. `docs/ARCHITECTURE.md` - Architecture documentation
3. `docs/SECURITY_AUDIT.md` - Security findings report
4. `docs/TESTING_STRATEGY.md` - Test improvement roadmap
5. `docs/DEPENDENCY_REPORT.md` - Dependency analysis
6. `.github/workflows/modernization-ci.yml` - CI pipeline (optional)

## Example Invocation

```
User: /modernize --init

Claude: 🚀 Initializing Brownfield Modernization Workflow

📋 Creating checkpoint document...
✅ MODERNIZATION_CHECKPOINT.md created

📊 Establishing baseline metrics...
- Test coverage: 0% (no tests found)
- Lint errors: 47
- Type errors: N/A (no type hints)
- Security findings: 3 (bandit scan)

🤖 Launching specialist agents...

[Agent 1: architecture-reviewer] Starting in background...
[Agent 2: security-auditor] Starting in background...
[Agent 3: dependency-manager] Starting in background...

⏳ Waiting for Wave 1 agents to complete...

[Agent 1: architecture-reviewer] ✅ Complete - 12 findings
[Agent 2: security-auditor] ✅ Complete - 8 findings
[Agent 3: dependency-manager] ✅ Complete - 5 findings

🤖 Launching Wave 2 agents...
[Agent 4: testing-specialist] Starting...

📝 Updating checkpoint with findings...
✅ Checkpoint saved

📊 Summary:
- Critical: 2 issues (Python 3.6 EOL, SQL injection risk)
- High: 5 issues
- Medium: 12 issues
- Low: 6 issues

📋 Next steps saved to checkpoint. Run /modernize --status to review.
```

## References

- [Brownfield Modernization Checklist](.claude/skills/modernize/CHECKLIST.md)
- [Checkpoint Template](.claude/skills/modernize/checkpoint-template.md)
- [Architecture Reviewer Agent](.claude/agents/architecture-reviewer.md)
- [Security Auditor Agent](.claude/agents/security-auditor.md)
- [Testing Specialist Agent](.claude/agents/testing-specialist.md)
- [Dependency Manager Agent](.claude/agents/dependency-manager.md)
