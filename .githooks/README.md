# Custom Git Hooks

This directory contains custom git hooks for the project.

## Setup

Git hooks require manual configuration. Run the setup script which handles this automatically:

```bash
bin/setup
```

Or configure manually:

```bash
git config core.hooksPath .githooks
```

## Available Hooks

### pre-commit

Runs before each commit to ensure code quality:

1. **RuboCop** - Ruby code linting and style checking
2. **Brakeman** - Security vulnerability scanning
3. **RSpec** - Full test suite

The commit will be blocked if any check fails.

### Requirements

- Docker must be running
- Containers should be up (`docker compose up -d`)

### Skipping Hooks (Emergency Only)

In rare cases, you can skip the pre-commit hook:

```bash
git commit --no-verify -m "your message"
```

⚠️ **Use sparingly** - this bypasses all quality checks.
