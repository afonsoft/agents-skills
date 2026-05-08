# Technical Debt Tracker

This document tracks technical debt across the agents-skills repository.

## Debt Categories

### Documentation Debt

| ID | Area | Description | Severity | Estimated Effort | Status | Priority |
|----|------|-------------|----------|------------------|--------|----------|
| DOC-001 | Knowledge | Reorganize knowledge/ to follow OpenAI structure | High | 4 hours | In Progress | High |
| DOC-002 | Skills | Add harness engineering skills | High | 2 days | Planned | High |
| DOC-003 | Rules | Add architecture rules | High | 1 day | Planned | High |

### Test Debt

| ID | Area | Description | Severity | Estimated Effort | Status | Priority |
|----|------|-------------|----------|------------------|--------|----------|
| TEST-001 | Skills | Add agent execution tests | Medium | 3 days | Planned | Medium |
| TEST-002 | Rules | Add cross-platform tests | Medium | 2 days | Planned | Medium |

### Architecture Debt

| ID | Area | Description | Severity | Estimated Effort | Status | Priority |
|----|------|-------------|----------|------------------|--------|----------|
| ARCH-001 | Repository | Implement rigid layer architecture | High | 1 week | Planned | High |
| ARCH-002 | Skills | Add dependency validation | Medium | 2 days | Planned | Medium |

### Performance Debt

| ID | Area | Description | Severity | Estimated Effort | Status | Priority |
|----|------|-------------|----------|------------------|--------|----------|
| PERF-001 | Installation | Optimize install.sh performance | Low | 4 hours | Planned | Low |

## Debt Management Strategy

### Prioritization

**Priority Levels:**
- **High**: Blocks agent execution or cross-platform compatibility
- **Medium**: Affects quality or maintainability
- **Low**: Nice to have improvements

### Paydown Strategy

- **Continuous**: Address high-priority items weekly
- **Sprint**: Dedicate 20% of time to debt monthly
- **Quarterly**: Comprehensive debt review and cleanup

### Prevention

- Add quality gates to prevent new debt
- Review PRs for debt introduction
- Monitor debt metrics
- Educate contributors on debt avoidance

## Debt Metrics

### Total Debt

- **High Priority**: 3 items
- **Medium Priority**: 3 items
- **Low Priority**: 1 item
- **Total Estimated Effort**: ~2 weeks

### Debt Trends

- **New Debt This Month**: 7 items
- **Debt Resolved This Month**: 0 items
- **Net Change**: +7 items

### Debt by Category

- Documentation: 3 items
- Testing: 2 items
- Architecture: 2 items
- Performance: 1 item

## Debt Paydown Schedule

### This Week

- [x] DOC-001: Reorganize knowledge/ structure
- [ ] DOC-002: Add harness engineering skills
- [ ] DOC-003: Add architecture rules

### This Month

- [ ] TEST-001: Add agent execution tests
- [ ] TEST-002: Add cross-platform tests
- [ ] ARCH-001: Implement rigid layer architecture

### This Quarter

- [ ] ARCH-002: Add dependency validation
- [ ] PERF-001: Optimize install.sh performance

## Debt Prevention Checklist

Before adding new code/skills/rules:

- [ ] Documentation is complete
- [ ] Tests are added
- [ ] Architecture follows patterns
- [ ] Performance is acceptable
- [ ] No new technical debt introduced

## Debt Review Process

### Weekly Review

- Review new debt items
- Update priorities
- Schedule paydown tasks
- Track progress

### Monthly Review

- Comprehensive debt assessment
- Update debt metrics
- Adjust paydown strategy
- Report to community

### Quarterly Review

- Strategic debt planning
- Architecture debt assessment
- Long-term debt prevention
- Community debt feedback
