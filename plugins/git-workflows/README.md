# Git Workflows Plugin

Git workflow automation for Claude Code: intelligent commit grouping with conventional format and Rails worktree management with credential symlinking.

## Installation

Add to your Claude Code settings:

```json
{
  "plugins": ["github:aviflombaum/avi-ai"]
}
```

## Commands

### `/git:commit`

Create logical, well-structured commits using conventional commit format.

**Usage:**
```
/git:commit
/git:commit auth/login.rb auth/signup.rb
```

**Features:**
- Groups related changes into logical commits
- Uses conventional commit format (feat, fix, docs, etc.)
- Never uses `git add .` without approval
- Verifies staging before committing

### `/git:worktree`

Create isolated git worktrees for feature development with automatic Rails credential symlinking.

**Usage:**
```
/git:worktree add stripe webhooks
/git:worktree fix checkout bug
```

**Features:**
- Creates worktree in `../<project>-worktrees/` directory
- Branch naming: `YY-MM-DD-feature-description`
- Automatically symlinks Rails credential files (master.key, development.key, test.key)

## Skills

Both commands also work as auto-triggering skills:
- Ask "commit my changes" and the commit skill activates
- Ask "create a worktree for X" and the worktree skill activates

## License

MIT
