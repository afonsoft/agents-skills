# Product Sense Principles

This document outlines product principles and decision-making frameworks for the agents-skills repository.

## Mission

Provide a community-driven collection of AI agent skills, rules, and knowledge that enhance development experiences across multiple IDEs and frameworks.

## Product Principles

### 1. Agent-First Experience

Every design decision prioritizes agent usability over human convenience. If agents can't use it effectively, it doesn't belong here.

**Implications:**
- Documentation must be machine-parseable
- Instructions must be unambiguous
- Context must be self-contained
- No external dependencies for understanding

### 2. Cross-Platform Compatibility

Skills and rules must work across all supported IDEs/CLIs without modification.

**Supported Platforms:**
- VS Code (GitHub Copilot)
- Windsurf (Cascade)
- Cursor
- Devin CLI
- Claude Code
- Gemini CLI

### 3. Progressive Enhancement

Start with simple, focused skills. Add complexity only when justified by use cases.

**Approach:**
- Minimum viable skill first
- Add references for depth
- Expand based on community needs
- Avoid over-engineering

### 4. Community-Driven

The repository exists to serve the community. Community contributions and feedback shape direction.

**Mechanisms:**
- Open contribution process
- Issue-driven development
- Regular community surveys
- Transparent roadmap

### 5. Quality Over Quantity

Better to have fewer, high-quality skills than many low-quality ones.

**Quality Criteria:**
- Agent-tested and validated
- Cross-platform compatible
- Well-documented
- Actively maintained
- Clear use case

## User Personas

### Primary: AI Agents

Autonomous agents that use skills to perform development tasks.

**Needs:**
- Clear, unambiguous instructions
- Self-contained context
- Mechanical validation
- Predictable structure

### Secondary: Human Developers

Developers who maintain and contribute to the repository.

**Needs:**
- Easy contribution process
- Clear documentation
- Good examples
- Active community

### Tertiary: Development Teams

Teams that adopt agents-skills for their projects.

**Needs:**
- Reliability
- Compatibility
- Support
- Updates

## Product Metrics

### Adoption Metrics

- Number of IDEs/CLIs supported
- Number of skills installed
- Number of active contributors
- GitHub stars and forks

### Quality Metrics

- Skill success rate (agent execution)
- Cross-platform compatibility rate
- Documentation completeness
- Bug fix time

### Community Metrics

- Contribution rate
- Issue resolution time
- Community satisfaction
- Retention rate

## Decision Framework

### When to Add a New Skill

**Add when:**
- Clear use case from community
- No existing skill addresses need
- Can be tested and validated
- Maintainer available
- Cross-platform compatible

**Don't add when:**
- Duplicate of existing skill
- Unclear use case
- Cannot be tested
- No maintainer
- Platform-specific only

### When to Deprecate a Skill

**Deprecate when:**
- No longer maintained
- Better alternative exists
- Platform no longer supported
- Security vulnerabilities
- Community consensus

### When to Update Documentation

**Update when:**
- New patterns emerge
- Best practices change
- Community feedback indicates confusion
- Platform updates require changes
- Security considerations change

## Roadmap Principles

### Short-term (0-3 months)

- Fill critical gaps in coverage
- Improve existing skills
- Enhance documentation
- Fix bugs

### Medium-term (3-6 months)

- Add harness engineering skills
- Improve automation
- Expand testing
- Community features

### Long-term (6-12 months)

- Agent autonomy features
- Advanced orchestration
- Performance optimization
- Ecosystem integration

## Success Criteria

The repository is successful when:

1. **Agents can reliably use skills** across all supported platforms
2. **Community actively contributes** and maintains skills
3. **Documentation is comprehensive** and up-to-date
4. **Quality is high** and consistent
5. **Adoption is growing** across development teams
