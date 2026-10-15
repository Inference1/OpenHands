#!/usr/bin/env bash
set -euo pipefail
export PATH="/tmp/openhands-bulk-proof-tools/node-v24.11.1-linux-x64/bin:/home/kws/.local/bin:$PATH"
export OH_VERIFY_RUN="$1"
cd "${2:-/tmp/openhands-bulk-proof-repo}"
c() { node .agents/skills/verify-openhands/scripts/control-openhands.mjs "$@"; }
c browser record start --feature F10.add-models --name refresh-comparison --fps 5 --max-seconds 1200
for i in 0 1 2 3; do
  if [ "$i" != 0 ]; then c browser tab new /settings/llm; fi
  if [ "$i" = 2 ] || [ "$i" = 3 ]; then c browser viewport phone; fi
  c browser wait 'testid=add-models-from-provider'
  if [ "$i" = 0 ] || [ "$i" = 2 ]; then
    c browser click 'testid=provider-connection-menu-trigger'
    c browser click 'testid=provider-connection-add-models'
    c browser wait 'testid=add-models-select-all'
    c browser uncheck 'testid=add-models-select-all'
  else
    c browser click 'testid=add-models-from-provider'
    c browser select 'testid=add-models-provider' deepseek
    c browser wait 'testid=add-models-select-all'
  fi
  c browser select 'testid=add-models-connection' ''
  c browser check 'testid=add-models-check-deepseek/deepseek-chat'
  c browser snapshot 'testid=add-models-modal' --max-lines 18 --feature F10.add-models --name "before-refresh-$i"
  c browser screenshot --feature F10.add-models --name "before-refresh-$i"
done
c browser tab new /settings/llm
c browser wait 'testid=provider-connection-menu-trigger'
c browser click 'testid=provider-connection-menu-trigger'
c browser click 'testid=provider-connection-edit'
c browser fill 'testid=provider-connection-name-input' QA_refresh_RENAMED
c browser click 'testid=provider-connection-submit'
c browser wait 'testid=provider-connection-modal' --state detached
c browser screenshot --feature F10.add-models --name renamed-in-second-tab
c browser offline on
c browser record pause
date -u
