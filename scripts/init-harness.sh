#!/bin/bash
# Initialize .harness/ workspace for harness-builder skill
set -e

mkdir -p .harness/contracts

cat > .harness/history.md << 'EOF'
# Harness Build History

Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# Replace the date placeholder with actual date
sed -i '' "s/\$(date -u +%Y-%m-%dT%H:%M:%SZ)/$(date -u +%Y-%m-%dT%H:%M:%SZ)/" .harness/history.md 2>/dev/null || \
sed -i "s/\$(date -u +%Y-%m-%dT%H:%M:%SZ)/$(date -u +%Y-%m-%dT%H:%M:%SZ)/" .harness/history.md

echo "Initialized .harness/ workspace"
echo "  .harness/"
echo "  .harness/contracts/"
echo "  .harness/history.md"
