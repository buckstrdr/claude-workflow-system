#!/bin/bash
# Initialize message board directory structure

mkdir -p messages/{orchestrator,librarian,planner,architect,dev-a,dev-b,qa-a,qa-b,docs}/{inbox,outbox}

# Initialize write lock (unlocked)
cat > messages/write-lock.json <<EOF
{
  "locked": false,
  "holder": null,
  "operation": null,
  "timestamp": null,
  "timeout_at": null,
  "queue": []
}
EOF

echo "✅ Message board initialized"
