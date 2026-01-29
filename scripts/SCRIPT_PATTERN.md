# Script Pattern Guide

To ensure consistency across the `arch-bootstrap` project, all new scripts (especially those in `scripts/run-once/`) should follow this pattern.

## Template

```bash
#!/bin/bash

# 1. Source common utilities
#    Adjust relative path as needed:
#    - Root directory scripts: "$SCRIPT_DIR/scripts/common.sh"
#    - Subdirectory scripts:   "$SCRIPT_DIR/../../scripts/common.sh"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh" # Example for scripts/run-once/

if [ -f "$COMMON_SCRIPT" ]; then
    source "$COMMON_SCRIPT"
else
    # Fallback minimal definitions
    GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; RESET='\033[0m';
    title_screen() { echo "=== $1 ==="; }
    fake_loading() { sleep 1; }
fi

# 2. Display Title and Loading Screen
title_screen "Script Title Here"
fake_loading

# 3. Use Colorized Output for logic
echo -e "${BLUE}Starting task...${RESET}"

if some_command; then
    echo -e "${GREEN}Task succeeded.${RESET}"
else
    echo -e "${RED}Task failed.${RESET}"
    # Optional: exit 1
fi
```

## Naming Convention
- **Run-Once Scripts**: `scripts/run-once/XX-description.sh` (where XX is a sequential number).
- **Utility Scripts**: `scripts/name.sh`.
- **Root Scripts**: `name.sh` (keep these minimal).

## Available Colors
- `${RED}`
- `${GREEN}`
- `${YELLOW}`
- `${BLUE}`
- `${MAGENTA}`
- `${CYAN}`
- `${RESET}`
- `${BOLD}`
