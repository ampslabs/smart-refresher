#!/bin/bash
# Pre-commit hook to run gitleaks
# To install: ln -s ../../scripts/pre-commit.sh .git/hooks/pre-commit

if command -v gitleaks &> /dev/null
then
    gitleaks protect --staged --verbose
    if [ $? -ne 0 ]; then
        echo "Error: Gitleaks detected potential secrets in your staged changes."
        echo "Please remove the secrets or update .gitleaks.toml if this is a false positive."
        exit 1
    fi
else
    echo "Warning: gitleaks is not installed. Skipping secret scan."
fi
