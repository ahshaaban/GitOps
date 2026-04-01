#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Checkov IaC Security Scanner
# ─────────────────────────────────────────────────────────────────────────────
# Runs Checkov against the infra/ directory to catch security misconfigurations
# BEFORE deployment. This is "Shift-Left" security in action.
#
# Interview talking point: "Checkov evaluates our Terraform against 750+
# built-in policies covering CIS benchmarks, SOC2, and Azure best practices.
# For example, it flags storage accounts without HTTPS enforcement or
# Key Vaults without purge protection — both of which we've addressed."
#
# Usage:
#   ./scripts/checkov_scan.sh          # scan all infra
#   ./scripts/checkov_scan.sh --compact-json  # machine-readable output
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "═══════════════════════════════════════════════════"
echo "  Checkov IaC Security Scan"
echo "  Target: ${REPO_ROOT}/infra"
echo "═══════════════════════════════════════════════════"

# Check if checkov is installed
if ! command -v checkov &> /dev/null; then
  echo "❌ Checkov not found. Install with: pip install checkov"
  exit 1
fi

checkov \
  -d "${REPO_ROOT}/infra" \
  --framework terraform \
  --download-external-modules true \
  --compact \
  "$@"

echo ""
echo "✅ Checkov scan complete."
