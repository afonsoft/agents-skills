# Quality Score

This document defines quality metrics and scoring for the agents-skills repository.

## Quality Dimensions

### 1. Agent Readability (Score: 0-100)

**Criteria:**
- Instructions are unambiguous (25 points)
- Context is self-contained (25 points)
- Structure is predictable (25 points)
- No external dependencies (25 points)

**Measurement:**
- Automated linter checks
- Agent execution success rate
- Human review of ambiguous sections

### 2. Cross-Platform Compatibility (Score: 0-100)

**Criteria:**
- Works on all supported platforms (20 points per platform)
- No platform-specific code (20 points)
- Consistent behavior across platforms (20 points)

**Supported Platforms:**
- VS Code (GitHub Copilot)
- Windsurf (Cascade)
- Cursor
- Devin CLI
- Claude Code
- Gemini CLI

**Measurement:**
- Automated testing on each platform
- Community feedback on compatibility
- Issue reports for platform-specific problems

### 3. Documentation Quality (Score: 0-100)

**Criteria:**
- Complete description (20 points)
- Clear examples (20 points)
- Usage instructions (20 points)
- Troubleshooting guide (20 points)
- Up-to-date (20 points)

**Measurement:**
- Documentation completeness check
- Example validation
- Link checking
- Freshness check (last updated)

### 4. Test Coverage (Score: 0-100)

**Criteria:**
- Unit tests present (30 points)
- Integration tests present (30 points)
- E2E tests for critical paths (20 points)
- Test success rate > 95% (20 points)

**Measurement:**
- Automated test execution
- Coverage reports
- Test failure analysis

### 5. Maintenance Status (Score: 0-100)

**Criteria:**
- Active maintainer (30 points)
- Regular updates (20 points)
- Responsive to issues (20 points)
- Security updates applied (15 points)
- Dependencies up-to-date (15 points)

**Measurement:**
- Commit frequency
- Issue resolution time
- Dependency audit
- Security scan results

## Overall Quality Score

**Calculation:**
```
Overall Score = (Agent Readability × 0.25) +
                (Cross-Platform Compatibility × 0.25) +
                (Documentation Quality × 0.20) +
                (Test Coverage × 0.15) +
                (Maintenance Status × 0.15)
```

**Score Interpretation:**
- **90-100**: Excellent - Production ready
- **80-89**: Good - Minor improvements needed
- **70-79**: Acceptable - Some improvements needed
- **60-69**: Fair - Significant improvements needed
- **< 60**: Poor - Not recommended for use

## Domain Quality Tracking

Track quality scores by domain and architectural layer:

### Framework Domains

| Domain | Agent Readability | Cross-Platform | Documentation | Tests | Maintenance | Overall |
|--------|-------------------|----------------|---------------|-------|-------------|---------|
| ABP.IO | 85 | 90 | 80 | 70 | 85 | 82 |
| Angular | 90 | 95 | 85 | 75 | 90 | 87 |
| .NET | 88 | 92 | 82 | 72 | 88 | 85 |

### Architectural Layers

| Layer | Agent Readability | Cross-Platform | Documentation | Tests | Maintenance | Overall |
|-------|-------------------|----------------|---------------|-------|-------------|---------|
| Skills | 90 | 88 | 85 | 70 | 85 | 84 |
| Rules | 85 | 90 | 80 | 65 | 80 | 80 |
| Knowledge | 88 | 95 | 90 | 60 | 88 | 85 |

## Quality Gates

### Before Merge

- Agent Readability ≥ 70
- Cross-Platform Compatibility ≥ 80
- Documentation Quality ≥ 70
- Test Coverage ≥ 60 (for code)
- Maintenance Status ≥ 70

### Before Release

- Overall Score ≥ 80
- All dimensions ≥ 70
- No critical security issues
- All tests passing

## Quality Improvement Process

### Continuous Monitoring

- Automated quality scans daily
- Score updates on each commit
- Trend analysis over time
- Alert on score drops > 10 points

### Improvement Planning

- Identify lowest-scoring dimensions
- Create improvement plans in exec-plans/
- Track progress with quality scores
- Celebrate improvements

### Community Feedback

- Collect quality feedback from issues
- Incorporate into quality calculations
- Address systematic quality issues
- Share quality reports with community

## Quality Report Template

```markdown
# Quality Report - [Date]

## Overall Score: [Score]/100

## Dimension Scores
- Agent Readability: [Score]/100
- Cross-Platform Compatibility: [Score]/100
- Documentation Quality: [Score]/100
- Test Coverage: [Score]/100
- Maintenance Status: [Score]/100

## Top Issues
1. [Issue description]
2. [Issue description]
3. [Issue description]

## Improvements Made
- [Improvement 1]
- [Improvement 2]

## Next Steps
- [Action 1]
- [Action 2]
```
