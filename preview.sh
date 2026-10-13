#!/bin/sh
# Local preview of the docs on http://localhost:3333 with the work-in-progress navigation
# groups from docs.wip.json merged in. Mintlify deploys the committed docs.json, so a group
# listed in docs.wip.json shows in local previews only. Restart the preview after editing
# either file (page edits hot-reload). Needs Docker; the Mintlify CLI wants Node 20.17+.
set -e
cd "$(dirname "$0")"
mkdir -p .preview
python3 - <<'PY'
import json
docs = json.load(open("docs.json"))
wip = json.load(open("docs.wip.json"))
docs["navigation"]["products"][0]["anchors"][0]["pages"].extend(wip["groups"])
json.dump(docs, open(".preview/docs.json", "w"), indent=2)
PY
docker rm -f mint-preview >/dev/null 2>&1 || true
exec docker run --rm --name mint-preview --network host \
  -v "$PWD":/docs -v "$PWD/.preview/docs.json":/docs/docs.json:ro -w /docs -e HOME=/tmp \
  node:22 npx --yes mint@latest dev --port 3333
