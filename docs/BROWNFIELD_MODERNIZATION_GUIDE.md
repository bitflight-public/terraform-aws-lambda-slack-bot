# Brownfield Modernization Guide

This repository includes a comprehensive AI-assisted brownfield modernization skill that orchestrates concurrent agents to analyze, validate, and document codebase improvements.

## Quick Start

### Start a New Modernization Project

```
/modernize --init
```

This will:
1. Create a checkpoint document (`MODERNIZATION_CHECKPOINT.md`)
2. Establish baseline metrics
3. Launch specialist agents to analyze the codebase
4. Update the checkpoint with findings

### Resume Previous Progress

```
/modernize --resume
```

If your session was interrupted, this will load the last checkpoint and continue where you left off.

### Check Status

```
/modernize --status
```

View current progress and next steps.

## How It Works

### Agent Orchestra

The `/modernize` skill coordinates four specialist agents that can run concurrently:

| Agent | Purpose | Focus Areas |
|-------|---------|-------------|
| `architecture-reviewer` | Analyze code structure | Module organization, dependencies, design patterns |
| `security-auditor` | Review security posture | Secrets, IAM, vulnerabilities, compliance |
| `testing-specialist` | Assess test coverage | Test quality, gaps, infrastructure |
| `dependency-manager` | Evaluate dependencies | Versions, vulnerabilities, upgrades |

### Validation Harness

Every AI-generated finding passes through a validation harness:

```
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION HARNESS                        │
├─────────────────────────────────────────────────────────────┤
│  1. Type Checking    → mypy --strict src/                   │
│  2. Linting          → pylint src/                          │
│  3. Security Scan    → bandit -r src/ -f json               │
│  4. Terraform Valid  → terraform validate                   │
│  5. Terraform Plan   → terraform plan                       │
└─────────────────────────────────────────────────────────────┘
```

### Self-Correction Loop

The skill implements Chain-of-Verification (CoVe):

1. **Generate**: AI produces initial analysis
2. **Question**: AI generates verification questions
3. **Verify**: Execute verification commands
4. **Correct**: AI self-corrects based on results
5. **Validate**: Run through validation harness
6. **Accept**: Only accept if all validations pass

### Checkpoint Persistence

Progress is automatically saved to `MODERNIZATION_CHECKPOINT.md`:
- Task status (pending, in_progress, completed, blocked)
- Agent findings and timestamps
- Self-correction log
- Next steps

If a session is interrupted, you can resume from the last checkpoint.

## File Structure

```
.claude/
├── settings.json                    # Hooks and permissions
├── skills/
│   └── modernize/
│       ├── SKILL.md                 # Main skill definition
│       ├── CHECKLIST.md             # Comprehensive checklist
│       ├── checkpoint-template.md   # Progress tracking template
│       └── scripts/
│           ├── init-checkpoint.sh   # Initialize checkpoint
│           ├── update-progress.sh   # Update task progress
│           └── git-checkpoint-save.sh # Auto-save on session end
└── agents/
    ├── architecture-reviewer.md     # Architecture analysis agent
    ├── security-auditor.md          # Security audit agent
    ├── testing-specialist.md        # Testing assessment agent
    └── dependency-manager.md        # Dependency analysis agent
```

## The Checklist

The full modernization checklist covers 8 phases:

1. **Repository Analysis & Baseline** - AST parsing, dependency graphs, security baseline
2. **Validation Harness Setup** - Type checking, linting, test harness
3. **Architecture Documentation** - System mapping, component relationships
4. **Modernization Planning** - Task breakdown, risk assessment
5. **CI/CD Pipeline Development** - Pipeline design, Docker optimization
6. **Review Cycles & Hallucination Detection** - Fact-checking, verification
7. **Documentation Generation** - Per-directory READMEs, API docs
8. **Continuous Validation Loop** - Pre-commit hooks, drift detection

See [CHECKLIST.md](../.claude/skills/modernize/CHECKLIST.md) for the complete checklist with examples.

## Example Session

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
- Terraform validation: ✓ valid

🤖 Launching specialist agents...

[Agent 1: architecture-reviewer] Starting in background...
[Agent 2: security-auditor] Starting in background...
[Agent 3: dependency-manager] Starting in background...

⏳ Waiting for Wave 1 agents to complete...

[architecture-reviewer] ✅ Complete - 12 findings
  - 6 modules identified
  - 2 circular dependency risks
  - Python 3.6 runtime (EOL)

[security-auditor] ✅ Complete - 8 findings
  - 1 critical: IAM policy too permissive
  - 2 high: Hardcoded URLs
  - 5 medium: Various improvements

[dependency-manager] ✅ Complete - 5 findings
  - Python 3.6 EOL (critical)
  - boto3 outdated
  - No dependency pinning

🤖 Launching Wave 2 agents...
[testing-specialist] Starting...

[testing-specialist] ✅ Complete - 3 findings
  - 0% test coverage
  - No test framework configured
  - test-event.json exists (manual testing only)

📝 Updating checkpoint with findings...
✅ Checkpoint saved

📊 Summary:
- Critical: 2 issues (Python 3.6 EOL, IAM scope)
- High: 3 issues
- Medium: 10 issues
- Low: 5 issues

📋 Next steps saved to checkpoint.
```

## Integration with Git

The skill automatically saves checkpoints to git when sessions end (via the Stop hook). You can also manually commit progress:

```bash
git add MODERNIZATION_CHECKPOINT.md
git commit -m "Update modernization checkpoint"
```

## Customization

### Adding Custom Agents

Create a new agent definition in `.claude/agents/`:

```markdown
# My Custom Agent

## Description
[What this agent does]

## Instructions
[Detailed instructions for the agent]

### Analysis Process
[Step-by-step process]

### Output Format
[Expected output structure]
```

### Modifying the Checklist

Edit `.claude/skills/modernize/CHECKLIST.md` to add or remove tasks specific to your project.

### Adjusting Validation Gates

Modify the validation harness in the SKILL.md to match your project's tooling.

## Troubleshooting

### Checkpoint Not Found

Run `/modernize --init` to create a new checkpoint.

### Agent Not Completing

Check the agent's progress by reviewing the checkpoint. If an agent is stuck, you can resume it with its agent ID.

### Validation Failures

The self-correction loop should handle most validation failures. If a finding persists after correction, it may require manual review.

## References

- [Full Checklist](.claude/skills/modernize/CHECKLIST.md)
- [Skill Definition](.claude/skills/modernize/SKILL.md)
- [Architecture Reviewer Agent](.claude/agents/architecture-reviewer.md)
- [Security Auditor Agent](.claude/agents/security-auditor.md)
- [Testing Specialist Agent](.claude/agents/testing-specialist.md)
- [Dependency Manager Agent](.claude/agents/dependency-manager.md)
