# GitHub Branch Protection Guide

This document explains how to set up branch protection rules in GitHub and the fundamental concepts behind secure Git workflows.

## What are Branch Protection Rules?

Branch protection rules are GitHub settings that enforce certain conditions before changes can be merged into important branches. They help maintain code quality, ensure proper review processes, and prevent accidental or unauthorized changes to critical branches like `main` and `develop`.

## Why Use Branch Protection?

1. **Code Quality**: Ensures code meets quality standards before merging
2. **Accountability**: Creates a record of who approved changes
3. **Knowledge Sharing**: Forces team members to review each other's code
4. **Stability**: Prevents breaking changes in production branches
5. **Security**: Restricts who can push to important branches
6. **Process Enforcement**: Makes sure your team follows agreed-upon workflows

## Setting Up Branch Protection Rules

### Step 1: Access Repository Settings

1. Navigate to your GitHub repository
2. Click on "Settings" in the top navigation bar
3. In the left sidebar, click on "Branches"

### Step 2: Add Branch Protection Rule

1. Under "Branch protection rules", click "Add rule"
2. In the "Branch name pattern" field, enter the branch name pattern (e.g., `main` or `develop`)
3. Configure the desired protection settings (explained below)
4. Click "Create" or "Save changes"

### Step 3: Configure Protection Settings

#### Essential Settings

These settings are highly recommended for any serious project:

- **Require a pull request before merging**
  - Prevents direct commits to protected branches
  - Enforces code review process
  
- **Require approvals**
  - Set minimum number of required approvals (recommended: at least 1)
  - Ensures someone other than the author reviews the code
  
- **Dismiss stale pull request approvals when new commits are pushed**
  - Ensures reviews aren't invalidated by subsequent changes
  
- **Require status checks to pass before merging**
  - Select relevant CI checks (e.g., tests, linters)
  - Prevents merging code that breaks tests or fails quality checks
  
- **Require branches to be up to date before merging**
  - Prevents merge conflicts and ensures testing against latest code

#### Additional Settings to Consider

- **Require conversation resolution before merging**
  - Ensures all comments and discussions are addressed
  
- **Restrict who can push to matching branches**
  - Limits who can push directly to protected branches
  - Usually limited to administrators or release managers
  
- **Allow force pushes**
  - Generally should be disabled for protected branches
  - Force pushes can rewrite history and cause issues

- **Allow deletions**
  - Generally should be disabled for protected branches
  - Prevents accidental deletion of important branches

## Recommended Branch Protection Configurations

### For `main` Branch (Production)

```
Branch name pattern: main
✓ Require a pull request before merging
  ✓ Require approvals: 2
  ✓ Dismiss stale pull request approvals when new commits are pushed
  ✓ Require review from Code Owners
✓ Require status checks to pass before merging
  ✓ Require branches to be up to date before merging
  Status checks: [Select your CI/test workflows]
✓ Require conversation resolution before merging
✓ Restrict who can push to matching branches
  [Select administrators or release managers]
✗ Allow force pushes
✗ Allow deletions
```

### For `develop` Branch (Staging)

```
Branch name pattern: develop
✓ Require a pull request before merging
  ✓ Require approvals: 1
  ✓ Dismiss stale pull request approvals when new commits are pushed
✓ Require status checks to pass before merging
  ✓ Require branches to be up to date before merging
  Status checks: [Select your CI/test workflows]
✓ Require conversation resolution before merging
✗ Allow force pushes
✗ Allow deletions
```

## Core Git Workflow Concepts

Understanding these concepts will help you use branch protection more effectively:

### 1. Git Flow Model

The Git Flow model defines a strict branching structure:

- **`main`**: Production-ready code only
- **`develop`**: Integration branch for features
- **`feature/*`**: New features or changes
- **`release/*`**: Preparing for a new production release
- **`hotfix/*`**: Emergency fixes for production

### 2. Pull Requests (PRs)

Pull requests are essential for code review and collaboration:

- **Creating a PR**: Opens a proposal to merge changes from one branch into another
- **PR Description**: Should clearly explain what changes are being made and why
- **Reviewers**: Team members who examine the code for issues
- **Review Comments**: Feedback on specific lines or overall approach
- **Approval**: Signifies the reviewer believes the code is ready to merge

### 3. Continuous Integration (CI)

CI systems automatically test your code when changes are pushed:

- **Automated Tests**: Unit tests, integration tests, etc.
- **Code Quality Checks**: Linters, style checkers, security scanners
- **Status Checks**: Results from CI systems that can block or allow merging

### 4. Protected Branches

Protected branches have special significance:

- **`main`**: Represents what's in production
- **`develop`**: Represents what will be in the next release
- Changes to these branches should be carefully controlled

## Best Practices for Branch Protection

1. **Always create feature branches for new work**
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/your-feature-name
   ```

2. **Keep pull requests small and focused**
   - One feature or fix per PR
   - Easier to review and less likely to introduce bugs

3. **Write meaningful commit messages**
   ```
   feat: Add user authentication feature
   
   - Implement login form
   - Create authentication service
   - Add session management
   ```

4. **Review code thoroughly**
   - Check for logic errors
   - Verify tests are included
   - Look for security vulnerabilities
   - Ensure code follows project standards

5. **Keep branches up to date**
   ```bash
   # While on your feature branch
   git fetch origin
   git rebase origin/develop
   ```

6. **Use rebasing to maintain a clean history**
   ```bash
   # Clean up commits before creating PR
   git rebase -i origin/develop
   ```

7. **Never force push to protected branches**
   - This can overwrite others' work and break the shared history

8. **Use status checks wisely**
   - Only require checks that are essential
   - Make sure checks are reliable to avoid false negatives

## Common Issues and Solutions

### Issue: "Can't merge PR because status checks are failing"

**Solution**: 
1. Check the details of the failing status check
2. Fix the issues in your code
3. Push the fixes to your branch
4. The checks will run again automatically

### Issue: "Need to make changes after approval"

**Solution**:
1. Make your changes and push them
2. If "dismiss stale approvals" is enabled, you'll need to request reviews again
3. Notify reviewers that changes were made

### Issue: "Emergency fix needed but can't bypass protection"

**Solution**:
1. Create a hotfix branch from main
2. Make the fix and create a PR
3. Use expedited review process (get reviewers to prioritize)
4. If absolutely necessary, administrators can temporarily disable protection

## Setting Up GitHub Actions for Branch Protection

GitHub Actions can be used to enforce additional checks beyond built-in branch protection. Here's an example workflow:

```yaml
# .github/workflows/branch-protection.yml
name: Branch Protection

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  check-branch-rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check commit message format
        run: |
          git log -1 --pretty=%B | grep -E '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?: .{1,50}$' || 
          (echo "Commit message must follow conventional commits format" && exit 1)
          
      - name: Check for sensitive information
        run: |
          git diff --name-only ${{ github.event.pull_request.base.sha }} ${{ github.sha }} |
          xargs grep -l -E '(password|token|key|secret).*[A-Za-z0-9]{8,}' && 
          (echo "Potential secrets found in code" && exit 1) || echo "No secrets found"
```

## Conclusion

Branch protection rules are essential for maintaining a healthy, collaborative development process. By enforcing code reviews, status checks, and proper branch management, you can significantly improve code quality, knowledge sharing, and stability of your WordPress project.

Remember that these rules serve your team and project — adjust them to fit your specific needs while maintaining the core principles of quality control and collaboration. 