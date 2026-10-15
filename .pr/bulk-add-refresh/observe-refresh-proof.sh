#!/usr/bin/env bash
set -euo pipefail
export PATH="/tmp/openhands-bulk-proof-tools/node-v24.11.1-linux-x64/bin:/home/kws/.local/bin:$PATH"
export OH_VERIFY_RUN="$1"
cd "${2:-/tmp/openhands-bulk-proof-repo}"
c() { node .agents/skills/verify-openhands/scripts/control-openhands.mjs "$@"; }
c browser record resume
c browser offline off
for i in 0 1 2 3; do
  c browser tab "$i"
  c browser wait 'testid=add-models-modal'
  c browser wait 'testid=provider-connection-row >> has-text=QA_refresh_RENAMED' --state attached --timeout 10000
  c browser eval '({provider:document.querySelector("[data-testid=add-models-provider]")?.value,connection:document.querySelector("[data-testid=add-models-connection]")?.value,options:Array.from(document.querySelectorAll("[data-testid=add-models-connection] option")).map(x=>x.textContent),selected:Array.from(document.querySelectorAll("[data-testid^=add-models-check-]:checked")).map(x=>x.dataset.testid),submit:document.querySelector("[data-testid=add-models-submit]")?.textContent})'
  c browser screenshot --feature F10.add-models --name "after-refresh-$i"
  c browser network --filter provider-connections --last 5
done
c browser record pause
date -u
