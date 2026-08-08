import json
import os
import urllib.request
from datetime import datetime, timezone

WEBHOOK = os.environ["SLACK_WEBHOOK_URL"]
PROJECT = os.environ.get("PROJECT_NAME", "ecs")

COLORS = {"ALARM": "#E53E3E", "OK": "#38A169", "INSUFFICIENT_DATA": "#ED8936"}
EMOJI  = {"ALARM": "🚨",      "OK": "✅",       "INSUFFICIENT_DATA": "⚠️"}

def handler(event, context):
    for record in event.get("Records", []):
        try:
            msg = json.loads(record["Sns"]["Message"])
        except Exception as e:
            print(f"Failed to parse SNS message: {e}")
            continue

        state      = msg.get("NewStateValue", "UNKNOWN")
        prev_state = msg.get("OldStateValue", "")
        alarm      = msg.get("AlarmName", "unknown")
        reason     = msg.get("NewStateReason", "")
        region     = msg.get("Region", "")
        account    = msg.get("AWSAccountId", "")
        timestamp  = msg.get("StateChangeTime", datetime.now(timezone.utc).isoformat())

        trigger    = msg.get("Trigger", {})
        metric     = trigger.get("MetricName", "")
        namespace  = trigger.get("Namespace", "")
        threshold  = trigger.get("Threshold", "")
        dimensions = {d["name"]: d["value"] for d in trigger.get("Dimensions", [])}
        dim_text   = "\n".join(f"• {k}: `{v}`" for k, v in dimensions.items())

        color = COLORS.get(state, "#718096")
        emoji = EMOJI.get(state, "ℹ️")

        # Determine icon based on alarm name
        icon = "📊"
        if "cpu"      in alarm.lower(): icon = "🔥"
        elif "memory" in alarm.lower(): icon = "💾"
        elif "5xx"    in alarm.lower(): icon = "💥"
        elif "task"   in alarm.lower(): icon = "📦"
        elif "response" in alarm.lower(): icon = "⏱️"
        elif "unhealthy" in alarm.lower(): icon = "🏥"

        payload = {
            "attachments": [{
                "color": color,
                "blocks": [
                    {
                        "type": "header",
                        "text": {
                            "type": "plain_text",
                            "text": f"{emoji} {icon} [{PROJECT.upper()}] {alarm}"
                        }
                    },
                    {
                        "type": "section",
                        "fields": [
                            {"type": "mrkdwn", "text": f"*State:*\n{emoji} `{state}`"},
                            {"type": "mrkdwn", "text": f"*Previous:*\n`{prev_state}`"},
                            {"type": "mrkdwn", "text": f"*Metric:*\n`{namespace}/{metric}`"},
                            {"type": "mrkdwn", "text": f"*Threshold:*\n`{threshold}`"},
                        ]
                    },
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": f"*Dimensions:*\n{dim_text or '_none_'}"
                        }
                    },
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": f"*Reason:*\n{reason}"
                        }
                    },
                    {"type": "divider"},
                    {
                        "type": "context",
                        "elements": [
                            {
                                "type": "mrkdwn",
                                "text": f"🌏 {region}  |  🔑 Account `{account}`  |  🕐 {timestamp}"
                            }
                        ]
                    }
                ]
            }]
        }

        data = json.dumps(payload).encode("utf-8")
        req  = urllib.request.Request(
            WEBHOOK,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=8) as resp:
                print(f"Slack: {resp.status} | alarm={alarm} state={state}")
        except Exception as e:
            print(f"Slack send failed: {e}")

    return {"statusCode": 200}