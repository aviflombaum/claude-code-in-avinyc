---
name: worktree
description: This skill should be used when the user asks to "create a worktree", "new worktree", "worktree for feature", "git worktree", or needs to work on a feature branch in isolation. Handles Rails credential symlinking automatically.
user-invocable: true
argument-hint: "<feature-description>"
---

# Git Worktree for Rails

Create isolated git worktrees for feature development with automatic Rails credential symlinking.

## When to Use

- Starting work on a new feature that needs isolation
- Working on multiple features simultaneously
- Need a clean environment without stashing changes

## Worktree Location

Worktrees are created in a sibling directory to keep the project root clean:

```
parent/
  project/              # main repo
  project-worktrees/    # worktree container
    25-01-22-feature/   # individual worktree
```

The container directory is `../<project-name>-worktrees/` relative to the project root.

## Branch Naming Convention

Format: `YY-MM-DD-feature-description`

Examples:
- `25-01-22-add-password-reset`
- `25-01-22-fix-api-timeout`
- `25-01-22-refactor-auth-module`

## Workflow

### Step 1: Get Feature Name

If no feature name provided, ask:

```
What feature are you working on? (e.g., "add password reset", "fix checkout bug")
```

### Step 2: Create Worktree

```bash
# Get project info
PROJECT_ROOT=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
WORKTREES_DIR="../${PROJECT_NAME}-worktrees"

# Format branch name: YY-MM-DD-feature-description
DATE=$(date +%y-%m-%d)
BRANCH_NAME="${DATE}-<feature-slug>"

# Create worktrees directory if needed
mkdir -p "$WORKTREES_DIR"

# Create worktree with new branch
git worktree add "$WORKTREES_DIR/$BRANCH_NAME" -b "$BRANCH_NAME"
```

### Step 3: Symlink Rails Credentials

Rails credentials must be symlinked so the worktree can decrypt secrets:

```bash
WORKTREE_PATH="$WORKTREES_DIR/$BRANCH_NAME"

# master.key
ln -sf "$PROJECT_ROOT/config/master.key" "$WORKTREE_PATH/config/master.key"

# development.key (if exists)
if [ -f "$PROJECT_ROOT/config/credentials/development.key" ]; then
  mkdir -p "$WORKTREE_PATH/config/credentials"
  ln -sf "$PROJECT_ROOT/config/credentials/development.key" "$WORKTREE_PATH/config/credentials/development.key"
fi

# test.key (if exists)
if [ -f "$PROJECT_ROOT/config/credentials/test.key" ]; then
  mkdir -p "$WORKTREE_PATH/config/credentials"
  ln -sf "$PROJECT_ROOT/config/credentials/test.key" "$WORKTREE_PATH/config/credentials/test.key"
fi
```

Use full absolute paths for symlinks.

### Step 4: Report Success

```
Worktree created:
  Branch: 25-01-22-add-password-reset
  Location: ../project-worktrees/25-01-22-add-password-reset

Rails credentials symlinked:
  - config/master.key
  - config/credentials/development.key
  - config/credentials/test.key

To start working:
  cd ../project-worktrees/25-01-22-add-password-reset
```

## Managing Worktrees

**List worktrees:**
```bash
git worktree list
```

**Remove worktree:**
```bash
git worktree remove ../project-worktrees/25-01-22-feature-name
```

**Prune stale worktrees:**
```bash
git worktree prune
```

## Example Session

```
User: create a worktree for adding stripe webhooks

Creating worktree...
  Project: vc-matcher-app
  Feature: adding stripe webhooks
  Branch: 25-01-22-add-stripe-webhooks

$ mkdir -p ../vc-matcher-app-worktrees
$ git worktree add ../vc-matcher-app-worktrees/25-01-22-add-stripe-webhooks -b 25-01-22-add-stripe-webhooks

Symlinking Rails credentials...
$ ln -sf /Users/avi/Development/code/project/config/master.key ../vc-matcher-app-worktrees/25-01-22-add-stripe-webhooks/config/master.key
[additional symlinks...]

Done! Worktree ready at:
  ../vc-matcher-app-worktrees/25-01-22-add-stripe-webhooks
```

## Notes

- Always use absolute paths for credential symlinks
- The worktree shares git history with main repo
- Commits in worktree are visible from main repo
- Delete the branch separately after removing worktree if needed
- Run `bundle install` in new worktree if Gemfile differs
