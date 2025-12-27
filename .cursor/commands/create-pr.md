# Create Pull Request

Generate a comprehensive PR description using GitHub CLI.

## PR Template:

### What Changed
[Brief description of changes]

### Why
[Reason for the change]

### Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Edge cases considered

### Checklist
- [ ] Code follows project conventions
- [ ] Documentation updated if needed
- [ ] No console.logs or debug code
- [ ] TypeScript errors resolved

Use conventional commit format for the title.
Run `gh pr create` with the generated description.
Include relevant issue numbers with "Closes #123" format.