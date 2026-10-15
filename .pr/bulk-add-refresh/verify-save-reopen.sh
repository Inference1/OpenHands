#!/usr/bin/env bash
set -euo pipefail
export PATH="/tmp/openhands-bulk-proof-tools/node-v24.11.1-linux-x64/bin:/home/kws/.local/bin:$PATH"
export OH_VERIFY_RUN=/tmp/openhands-verify/bulk-fix-verified
cd /tmp/openhands-bulk-proof-repo
c() { node .agents/skills/verify-openhands/scripts/control-openhands.mjs "$@"; }
c browser record resume
c browser tab 0
c browser value 'testid=add-models-connection'
c browser click 'testid=add-models-submit'
c browser wait 'testid=add-models-modal' --state detached
c browser wait 'testid=profile-row'
c browser screenshot --feature F10.add-models --name saved-keyless-profile
c api GET /api/profiles
c api GET /api/profiles/deepseek-chat --pick config.provider_connection_id
c browser reload
c browser wait 'testid=profile-row'
c browser screenshot --feature F10.add-models --name saved-profile-after-reload
c browser click 'testid=provider-connection-menu-trigger'
c browser click 'testid=provider-connection-add-models'
c browser wait 'testid=add-models-select-all'
c browser value 'testid=add-models-connection'
c browser screenshot --feature F10.add-models --name row-reopened-defaults
c browser click 'role=dialog[name="Add models as profiles"] >> role=button[name="Cancel"]'
c browser click 'testid=add-models-from-provider'
c browser value 'testid=add-models-provider'
c browser screenshot --feature F10.add-models --name chooser-reopened-empty
c browser click 'role=dialog[name="Add models as profiles"] >> role=button[name="Cancel"]'
c browser viewport phone
c browser click 'testid=add-models-from-provider'
c browser select 'testid=add-models-provider' deepseek
c browser wait 'testid=add-models-select-all'
c browser select 'testid=add-models-connection' ''
c browser screenshot --feature F10.add-models --name phone-keyless
c browser bbox 'testid=add-models-modal'
c browser viewport desktop
c browser record stop --gif
