# Contributing to agents-skills

Thank you for your interest in contributing to the agents-skills repository! We welcome contributions from the community to help expand our collection of skills (and session-start hooks) for AI development experiences.

## Table of Contents

- [What We Accept](#what-we-accept)
- [What We Don't Accept](#what-we-dont-accept)
- [Quality Guidelines](#quality-guidelines)
- [How to Contribute](#how-to-contribute)
  - [Adding Skills](#adding-skills)
  - [Adding Agentic Workflows](#adding-agentic-workflows)
- [Submitting Your Contribution](#submitting-your-contribution)
- [Contributor Recognition](#contributor-recognition)
  - [Contribution Types](#contribution-types)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

## What We Accept

We welcome contributions covering any technology, framework, or development practice that helps developers work more effectively with AI agents and development tools. This includes:

- Programming languages and frameworks
- Development methodologies and best practices
- Architecture patterns and design principles
- Testing strategies and quality assurance
- DevOps and deployment practices
- Accessibility and inclusive design
- Performance optimization techniques

If you are planning to contribute content that involves paid services, please review our [Guidance for submissions involving paid services](https://github.com/github/awesome-copilot/discussions/968).

## What We Don't Accept

To maintain a safe, responsible, and high-signal collection, we will **not accept** contributions that:

- **Violate Responsible AI Principles**: Content that attempts to circumvent Microsoft/GitHub's Responsible AI guidelines or promotes harmful AI usage
- **Compromise Security**: Instructions designed to bypass security policies, exploit vulnerabilities, or weaken system security
- **Enable Malicious Activities**: Content intended to harm other systems, users, or organizations
- **Exploit Weaknesses**: Instructions that take advantage of vulnerabilities in other platforms or services
- **Promote Harmful Content**: Guidance that could lead to the creation of harmful, discriminatory, or inappropriate content
- **Circumvent Platform Policies**: Attempts to work around GitHub, Microsoft, or other platform terms of service
- **Duplicate Existing Model Strengths Without Meaningful Uplift**: Submissions that mainly tell AI agents to do work frontier models already handle well without addressing a clear gap, specialized workflow, or domain-specific constraint
- **Remote Resources from Unverified Sources**: While the design allows us to support resources from other GitHub repos or Git endpoints, we are not accepting contributions that simply add resources from external sources without proper verification

## Quality Guidelines

- **Be specific**: Generic instructions are less helpful than specific, actionable guidance
- **Test your content**: Ensure your instructions, skills, or agents work well with AI development tools
- **Follow conventions**: Use consistent formatting and naming
- **Keep it focused**: Each file should address a specific technology, framework, or use case
- **Write clearly**: Use simple, direct language
- **Promote best practices**: Encourage secure, maintainable, and ethical development practices

## How to Contribute

### Adding Skills

Skills are self-contained folders in the `skills/` directory that include a `SKILL.md` file (with front matter) and optional bundled assets. The `writing-skills` skill is a good companion guide.

1. **Create a new skill folder**: Add `skills/<skill-name>/SKILL.md` (lowercase, hyphenated, max 64 chars)
2. **Edit `SKILL.md`**: Ensure the `name` in the front matter matches the folder name and the `description` is clear and non-empty
3. **Add optional assets**: Keep bundled assets reasonably sized (under 5MB each) and reference them from `SKILL.md`
4. **Validate**: Run `shellcheck install.sh` and `./install.sh --devin --dry-run` to confirm the catalog still installs cleanly

#### Example `SKILL.md` front matter

```markdown
---
name: my-skill
description: "What this skill does and when the agent should use it."
---

# My Skill

## Overview
[What this skill covers]

## Instructions
[Step-by-step guidance for the agent]
```

### Adding Agentic Workflows

[Agentic Workflows](https://github.github.com/gh-aw) are AI-powered repository automations that run coding agents in GitHub Actions. Defined in markdown with natural language instructions, they enable scheduled and event-triggered automation with built-in guardrails.

1. **Create your workflow file** with a new `.md` file in the `workflows/` directory (e.g., [`daily-issues-report.md`](./workflows/daily-issues-report.md))
2. **Include frontmatter** with `name` and `description`, followed by agentic workflow frontmatter (`on`, `permissions`, `safe-outputs`) and natural language instructions
3. **Test locally** with `gh aw compile --validate --no-emit daily-issues-report.md` to verify it's valid

> **Note:** Only `.md` files are accepted — do not include compiled `.lock.yml` or `.yml` files. CI will block them.

#### Workflow file example

```markdown
---
name: "Daily Issues Report"
description: "Generates a daily summary of open issues and recent activity as a GitHub issue"
on:
  schedule: daily on weekdays
permissions:
  contents: read
  issues: read
safe-outputs:
  create-issue:
    title-prefix: "[daily-report] "
    labels: [report]
---

## Daily Issues Report

Create a daily summary of open issues for the team.

## What to Include

- New issues opened in the last 24 hours
- Issues closed or resolved
- Stale issues that need attention
```

#### Workflow Guidelines

- **Security first**: Use least-privilege permissions and safe outputs instead of direct write access
- **Clear instructions**: Write clear natural language instructions in the workflow body
- **Descriptive names**: Use lowercase filenames with hyphens (e.g., `daily-issues-report.md`)
- **Test locally**: Use `gh aw compile --validate` to verify your workflow compiles
- **No compiled files**: Only submit the `.md` source — `.lock.yml` and `.yml` files are not accepted
- Learn more at the [Agentic Workflows documentation](https://github.github.com/gh-aw)

## Submitting Your Contribution

1. **Fork this repository**
2. **Create a feature branch** for your contribution
3. **Add your skill or workflow** following the guidelines above
4. **Validate locally**: run `shellcheck install.sh` and `./install.sh --devin --dry-run`
5. **Submit a pull request** with:
   - A clear title describing your contribution
   - A brief description of what your skill/workflow does
   - Any relevant context or usage notes

## Contributor Recognition

We use [all-contributors](https://github.com/all-contributors/all-contributors) to recognize **all types of contributions** to this project.

To add yourself, leave a comment on a relevant issue or pull request using your GitHub username and the appropriate contribution type(s):

```markdown
@all-contributors add @username for contributionType1, contributionType2
```

The contributors list is updated automatically every Sunday at **3:00 AM UTC**. When the next run completes, your name will appear in the [README Contributors](./README.md#contributors-) section.

### Contribution Types

We welcome many kinds of contributions, including the custom categories below:

| Category         | Description                                                | Emoji |
| ---------------- | ---------------------------------------------------------- | :---: |
| **Skills**       | Specialized knowledge of a task for AI agents             |  🧰   |
| **Hooks**        | Session-start hooks that inject the skills catalog         |  🪝   |
| **Workflows**    | Agentic Workflows for AI-powered repository automation     |  ⚡   |

In addition, all standard contribution types supported by [All Contributors](https://allcontributors.org/emoji-key/) are recognized.

> Every contribution matters. Thanks for helping improve this resource for the GitHub Copilot community.

## Code of Conduct

Please note that this project is maintained with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

By contributing to this repository, you agree that your contributions will be licensed under the MIT License.
