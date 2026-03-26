#!/usr/bin/env bash
# Usage: ./scripts/release.sh <version> "<summary>"
# Example: ./scripts/release.sh 1.1.0 "Added session hooks and improved evaluator prompts"
#
# This script:
#   1. Bumps version in plugin.json, marketplace.json, package.json
#   2. Commits with "Release v<version>: <summary>"
#   3. Creates a git tag v<version>
#   4. Pushes commit + tag
#   5. Creates a GitHub Release from RELEASE-NOTES.md (latest entry)
#
# Before running:
#   - Update CHANGELOG.md with new entry
#   - Update RELEASE-NOTES.md with new entry at the top

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./scripts/release.sh <version> \"<summary>\""
  echo "Example: ./scripts/release.sh 1.1.0 \"Added session hooks\""
  exit 1
fi

VERSION="$1"
SUMMARY="$2"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Validate semver format
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: Version must be semver (e.g., 1.1.0)"
  exit 1
fi

# Check RELEASE-NOTES.md has the version entry
if ! grep -q "## v$VERSION" RELEASE-NOTES.md; then
  echo "Error: RELEASE-NOTES.md missing entry for v$VERSION"
  echo "Add a '## v$VERSION' section before running this script."
  exit 1
fi

# Check CHANGELOG.md has the version entry
if ! grep -q "$VERSION" CHANGELOG.md; then
  echo "Error: CHANGELOG.md missing entry for $VERSION"
  echo "Add an entry before running this script."
  exit 1
fi

echo "Releasing v$VERSION: $SUMMARY"
echo ""

# Bump version in all 3 files
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" .claude-plugin/plugin.json
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" .claude-plugin/marketplace.json
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" package.json
else
  sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" .claude-plugin/plugin.json
  sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" .claude-plugin/marketplace.json
  sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" package.json
fi
echo "  Bumped version in plugin.json, marketplace.json, package.json"

# Extract release notes for this version (everything between ## vX.Y.Z and next ## v)
NOTES=$(awk "/^## v$VERSION/{found=1; next} /^## v[0-9]/{if(found) exit} found" RELEASE-NOTES.md)

if [ -z "$NOTES" ]; then
  echo "Warning: Could not extract release notes for v$VERSION"
  NOTES="Release v$VERSION: $SUMMARY"
fi

# Commit, tag, push
git add -A
git commit -m "Release v$VERSION: $SUMMARY"
git tag "v$VERSION"
git push
git push --tags

# Create GitHub release
gh release create "v$VERSION" \
  --title "v$VERSION" \
  --notes "$NOTES"

echo ""
echo "Released v$VERSION"
echo "  GitHub: $(gh repo view --json url --jq .url)/releases/tag/v$VERSION"
