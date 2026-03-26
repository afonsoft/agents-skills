---
description: Git workflow conventions, branching strategies, commit message standards, and repository management best practices
applyTo:
  - "**/.gitignore"
  - "**/.gitattributes"
  - "**/.github/workflows/**.yml"
  - "**/.github/workflows/**.yaml"
  - "**/PULL_REQUEST_TEMPLATE.md"
  - "**/CONTRIBUTING.md"
  - "**/README.md"
---

# Git Workflow Guidelines

## Overview

This document defines the standards and conventions for Git workflow, branching strategies, commit messages, pull requests, and repository management to ensure consistent collaboration and maintainable version control practices.

## Branching Strategy

### Main Branches

```
main                    # Production-ready code
├── develop             # Integration branch for features
├── feature/user-auth   # Feature branches
├── feature/api-v2
├── feature/dashboard
├── hotfix/security-patch
├── hotfix/critical-bug
└── release/v1.0.0     # Release preparation
```

### Branch Types and Rules

#### Main Branch
- **Purpose**: Production-ready code
- **Protection**: Require pull requests, status checks, and approvals
- **Commits**: Only from release branches or hotfixes
- **Tags**: Semantic versioning (v1.0.0, v1.1.0, v2.0.0)

#### Develop Branch
- **Purpose**: Integration of completed features
- **Protection**: Require pull requests and status checks
- **Commits**: From feature branches
- **Deployment**: To staging/testing environments

#### Feature Branches
- **Naming**: `feature/[feature-name]` or `feature/[ticket-number]-[description]`
- **Source**: From develop branch
- **Target**: Back to develop branch
- **Lifetime**: Short-lived, deleted after merge

#### Release Branches
- **Naming**: `release/v[major].[minor]` (e.g., `release/v1.2.0`)
- **Source**: From develop branch
- **Target**: To main branch and develop branch
- **Purpose**: Final testing, bug fixes, release preparation

#### Hotfix Branches
- **Naming**: `hotfix/[description]` or `hotfix/[ticket-number]-[description]`
- **Source**: From main branch
- **Target**: To main branch and develop branch
- **Purpose**: Critical production fixes

## Commit Message Standards

### Format

```
type(scope): description

[optional body]

[optional footer]
```

### Types

| Type | Purpose | Examples |
|------|---------|----------|
| `feat` | New feature | `feat(api): add user authentication endpoint` |
| `fix` | Bug fix | `fix(auth): resolve JWT token validation issue` |
| `docs` | Documentation | `docs(readme): update installation instructions` |
| `style` | Formatting, style changes | `style(css): fix button alignment` |
| `refactor` | Code refactoring | `refactor(service): simplify user validation logic` |
| `test` | Test additions/changes | `test(user): add unit tests for user service` |
| `chore` | Build process, dependencies | `chore(deps): update Entity Framework to 6.0` |
| `perf` | Performance improvements | `perf(database): optimize query with index` |
| `ci` | CI/CD changes | `ci(github): add automated testing workflow` |
| `build` | Build system changes | `build(msbuild): update solution file structure` |

### Scopes

Common scopes for .NET projects:
- `api` - API controllers and endpoints
- `core` - Domain logic and entities
- `infra` - Infrastructure and data access
- `ui` - User interface components
- `auth` - Authentication and authorization
- `test` - Test projects and fixtures
- `config` - Configuration and settings
- `deps` - Dependencies and packages

### Examples

#### Good Commit Messages
```
feat(api): add user authentication endpoint

- Implement JWT token generation
- Add login and register endpoints
- Include password hashing with BCrypt
- Add unit tests for authentication service

Closes #123

fix(core): resolve null reference exception in user service

- Add null checks in User constructor
- Update validation logic for email addresses
- Add regression tests for edge cases

BREAKING CHANGE: User constructor now requires email parameter

docs(readme): update installation and setup instructions

- Add prerequisites section
- Update configuration examples
- Include troubleshooting guide
- Add Docker setup instructions

perf(database): optimize user query performance

- Add composite index on Email and IsActive
- Use AsNoTracking for read-only operations
- Implement query result caching
- Reduce query execution time by 60%
```

#### Bad Commit Messages
```
fix
update
stuff
temp changes
wip
bug fix
add new feature
```

## Pull Request Guidelines

### Pull Request Template

```markdown
## Description
Brief description of the changes made in this pull request.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance testing completed (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is properly commented
- [ ] Documentation updated
- [ ] No console.log or debug statements
- [ ] Error handling implemented
- [ ] Security considerations addressed

## Related Issues
Closes #(issue number)
Fixes #(issue number)
Related to #(issue number)

## Screenshots (if applicable)
Add screenshots to demonstrate changes.

## Additional Notes
Any additional information or context about the changes.
```

### Pull Request Process

#### 1. Create Feature Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication
```

#### 2. Make Changes
```bash
# Make your changes
git add .
git commit -m "feat(auth): add user authentication endpoint"
git push origin feature/user-authentication
```

#### 3. Create Pull Request
- Target: `develop` branch
- Title: Follow commit message format
- Description: Fill out PR template
- Reviewers: Assign appropriate reviewers
- Labels: Add relevant labels

#### 4. Code Review Process
- Automated checks must pass
- At least one reviewer approval required
- Address all review comments
- Update PR based on feedback

#### 5. Merge
- Squash and merge (preferred)
- Delete feature branch
- Update develop branch

### Code Review Guidelines

#### Reviewer Responsibilities
- **Code Quality**: Check for clean, maintainable code
- **Functionality**: Verify implementation meets requirements
- **Testing**: Ensure adequate test coverage
- **Security**: Check for security vulnerabilities
- **Performance**: Consider performance implications
- **Documentation**: Verify documentation is updated

#### Review Comments Format
```markdown
# Suggestion
Consider using async/await for this I/O operation to improve performance.

# Issue
This code has a potential null reference exception if user is null.

# Question
Why are we using a string concatenation here instead of string interpolation?

# Praise
Great implementation of the repository pattern! Very clean and maintainable.
```

## Repository Structure

### .gitignore

```gitignore
# Visual Studio / VS Code
.vs/
*.user
*.suo
*.userosscache
*.sln.docstates
.vscode/settings.json
.vscode/launch.json
.vscode/extensions.json

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
build/
bld/
[Bb]in/
[Oo]bj/

# NuGet packages
*.nupkg
packages/
*.nuget.targets
*.nuget.props

# User-specific files
*.rsuser
.DS_Store
Thumbs.db

# Test results
TestResults/
*.trx
*.coverage
*.coveragexml

# Logs
logs/
*.log

# Local configuration
appsettings.Local.json
appsettings.Development.local.json
.env
.env.local

# Database
*.db
*.sqlite
*.mdf
*.ldf

# Temporary files
*.tmp
*.temp
*.swp
*~

# IDE files
.idea/
*.iml
*.ipr
*.iws

# Docker
.dockerignore
docker-compose.override.yml

# Node.js (if applicable)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

### .gitattributes

```gitignore
# Auto detect text files and normalize LF to CRLF
* text=auto eol=crlf

# Explicitly declare text files you want to always normalize and convert
*.cs text diff=csharp
*.csx text diff=csharp
*.vb text diff=vb
*.sql text
*.json text
*.xml text
*.yml text
*.yaml text
*.md text
*.txt text
*.config text
*.props text
*.targets text
*.csproj text
*.sln text
*.xaml text

# Declare files that will always have CRLF line endings on checkout
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf

# Declare files that will always have LF line endings on checkout
*.sh text eol=lf
*.dockerfile text eol=lf

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.pdf binary
*.zip binary
*.exe binary
*.dll binary
*.so binary
*.dylib binary

# Large files
*.mp4 binary
*.avi binary
*.mov binary
*.mp3 binary
*.wav binary
```

## GitHub Workflow Configuration

### Main CI/CD Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  DOTNET_VERSION: '8.0.x'
  NODE_VERSION: '18.x'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Cache NuGet packages
        uses: actions/cache@v3
        with:
          path: ~/.nuget/packages
          key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
          restore-keys: |
            ${{ runner.os }}-nuget-

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore --configuration Release

      - name: Run tests
        run: dotnet test --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage"

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./TestResults/*/coverage.xml
          flags: unittests
          name: codecov-umbrella

  security:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run security scan
        uses: securecodewarrior/github-action-add-sarif@v1
        with:
          sarif-file: 'security-scan-results.sarif'

  deploy-staging:
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          # Add deployment commands here

  deploy-production:
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          # Add deployment commands here
```

### Release Workflow

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Generate changelog
        id: changelog
        run: |
          # Generate changelog from commits
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          git log --pretty=format:"- %s" $(git describe --tags --abbrev=0)..HEAD >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            ## Changes
            ${{ steps.changelog.outputs.changelog }}
          draft: false
          prerelease: false
```

## Release Management

### Semantic Versioning

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
1.0.0          # First stable release
1.1.0          # New feature release
1.1.1          # Bug fix release
2.0.0          # Breaking changes
1.2.0-alpha.1  # Alpha release
1.2.0-beta.2   # Beta release
1.2.0-rc.1     # Release candidate
```

### Release Process

#### 1. Prepare Release Branch
```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0
```

#### 2. Final Testing and Fixes
```bash
# Fix any issues found during testing
git add .
git commit -m "fix: resolve critical bug before release"
git push origin release/v1.2.0
```

#### 3. Merge to Main and Tag
```bash
git checkout main
git pull origin main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags
```

#### 4. Merge Back to Develop
```bash
git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop
```

#### 5. Delete Release Branch
```bash
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

## Best Practices

### Do's
- ✅ Follow commit message format consistently
- ✅ Write descriptive commit messages
- ✅ Use feature branches for new development
- ✅ Keep branches short-lived
- ✅ Write comprehensive pull request descriptions
- ✅ Review code thoroughly before merging
- ✅ Use semantic versioning for releases
- ✅ Protect main and develop branches
- ✅ Include tests with all changes
- ✅ Update documentation when needed

### Don'ts
- ❌ Commit directly to main or develop
- ❌ Use vague commit messages
- ❌ Keep feature branches alive too long
- ❌ Merge without proper review
- ❌ Include sensitive data in commits
- ❌ Forget to update documentation
- ❌ Break backward compatibility without notice
- ❌ Ignore automated test failures
- ❌ Commit large binary files
- ❌ Use force push on shared branches

## Troubleshooting

### Common Issues

#### Merge Conflicts
```bash
# Resolve merge conflicts
git checkout feature/branch
git pull origin develop
git merge develop
# Resolve conflicts manually
git add .
git commit -m "resolve: merge conflicts with develop"
git push origin feature/branch
```

#### Accidental Commit to Main
```bash
# Create emergency branch
git checkout -b emergency-fix
git push origin emergency-fix

# Reset main to previous commit
git checkout main
git reset --hard HEAD~1
git push --force-with-lease origin main

# Create proper pull request from emergency-fix
```

#### Large File in History
```bash
# Use BFG to remove large files
java -jar bfg.jar --strip-biggest-repo MY_REPO_DIR.git
cd MY_REPO_DIR.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force-with-lease
```

## Tools and Integration

### Recommended VS Code Extensions
- GitLens - Enhanced Git capabilities
- Git History - Visual Git history
- GitLens - Git blame and annotations
- Git Graph - Visual Git workflow

### Git Hooks
```bash
#!/bin/sh
# pre-commit hook
echo "Running pre-commit checks..."

# Run tests
dotnet test --no-build

# Check for console.log
if git diff --cached --name-only | xargs grep -l "console.log" 2>/dev/null; then
  echo "Error: Found console.log statements in staged files"
  exit 1
fi

# Check for TODO comments
if git diff --cached --name-only | xargs grep -l "TODO\|FIXME" 2>/dev/null; then
  echo "Warning: Found TODO or FIXME comments in staged files"
fi

echo "Pre-commit checks passed"
```

## References

- [Git Workflow Guidelines](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Best Practices](https://sethrobertson.github.io/Git-Best-Practices/)

---

**Follow these guidelines to maintain consistent, collaborative, and maintainable Git workflows.**
