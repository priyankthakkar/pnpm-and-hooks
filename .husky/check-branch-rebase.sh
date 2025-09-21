#!/bin/bash
# pre-push hook to ensure branches are up-to-date with develop
echo "Begin pre-push checks..."
protected_branch='develop'
# current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
current_branch=$(git symbolic-ref HEAD | sed -e 's,refs/heads/,,')

# Skip check for develop and main branches
if [[ "$current_branch" == "develop" ]] || [[ "$current_branch" == "main" ]]; then
  exit 0
fi

# Check if branch matches any of the conventional commit prefixes
if [[ "$current_branch" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)/ ]]; then
  # Fetch latest
  echo "Checking if branch is up-to-date with develop..."
  git fetch origin develop --quiet

  # Check if we have all commits from develop
  behind_count=$(git rev-list --count HEAD..origin/develop)

  if [ "$behind_count" -gt 0 ]; then
    echo "❌ ERROR: Your branch is $behind_count commits behind develop"
    echo ""
    echo "Please rebase first:"
    echo "  git rebase origin/develop"
    echo "  git push --force-with-lease origin $current_branch"
    echo ""
    echo "To push anyway (NOT RECOMMENDED):"
    echo "  git push --no-verify"
    exit 1
  fi

  echo "✅ Branch is up-to-date with develop"
fi

exit 0
