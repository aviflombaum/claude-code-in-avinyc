---
name: commit
description: This skill should be used when the user asks to "commit", "make a commit", "commit my changes", "create commits", "git commit", or wants to commit staged/unstaged changes with logical grouping and conventional commit format.
user-invocable: true
argument-hint: "[files or message]"
---

# Git Commit Assistant

Analyze git changes and create logical, well-structured commits using conventional commit format.

## When to Use

- User asks to commit changes
- Multiple unrelated changes need separate commits
- Changes need conventional commit formatting

## Workflow

### Step 1: Review Current State

Run git status to see all changes:

```bash
git status
```

Review both staged and unstaged changes. Identify modified, added, and deleted files.

### Step 2: Analyze and Plan Commits

Group changes into logical commits based on:

- **Feature boundaries**: Files that implement the same feature together
- **Type of change**: Separate fixes from features from refactors
- **Scope**: Group by component, module, or area of the codebase

Present the commit plan to the user before proceeding:

```
I see the following logical commits:
1. feat(auth): Add password reset - auth/reset.rb, auth/mailer.rb
2. fix(api): Handle null responses - api/client.rb
3. docs: Update README - README.md
```

### Step 3: Execute Commits One by One

For each planned commit:

**Stage specific files only:**
```bash
git add <file1> <file2>
```

**Verify staging:**
```bash
git status
```

**Create commit with conventional format:**
```bash
git commit -m "<type>[scope]: <description>" -m "<body>"
```

**Verify commit succeeded:**
```bash
git status
```

Only proceed to the next commit after verifying the current one completed.

## Conventional Commit Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation only |
| style | Formatting, no code change |
| refactor | Code change, no new feature or fix |
| perf | Performance improvement |
| test | Adding or fixing tests |
| chore | Build process, auxiliary tools |

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

- **Description**: Imperative mood, lowercase, no period ("add feature" not "Added feature.")
- **Body**: Explain what and why, not how
- **Scope**: Component or area affected (auth, api, db, ui)

## Rules

1. **Never mix unrelated changes** in a single commit
2. **Always verify staging** before committing
3. **Always verify success** after committing
4. **Explain the plan** before executing
5. **Never use** `git add .` or `git add -A` without explicit approval
6. **Never include** "Generated with Claude Code" or Co-Authored-By footers

## Example Session

```
$ git status
# Modified: auth/login.rb, auth/signup.rb, README.md, api/client.rb

Plan:
1. feat(auth): Improve login validation - auth/login.rb, auth/signup.rb
2. fix(api): Handle timeout errors - api/client.rb
3. docs: Add authentication guide - README.md

Executing commit 1...
$ git add auth/login.rb auth/signup.rb
$ git status  # verify only auth files staged
$ git commit -m "feat(auth): improve login validation" -m "Add email format check and rate limiting"
$ git status  # verify commit succeeded

Executing commit 2...
[continues...]
```
