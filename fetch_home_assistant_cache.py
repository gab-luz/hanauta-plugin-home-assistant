#!/usr/bin/env python3
"""Fetch Home Assistant /api/states and write the service cache JSON.

This script is invoked by hanauta-service via the plugin manifest
(hanauta-service-plugin.json). It reads the HA URL and long-lived
token from Hanauta settings, fetches entity states, and writes a
unified cache file at the standard service state path so that the
home_assistant_widget popup can pick it up with zero extra
configuration.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

SETTINGS_FILE = Path.home() / ".local" / "state" / "hanauta" / "notification-center" / "settings.json"
STATE_DIR = Path.home() / ".local" / "state" / "hanauta" / "service"


def _ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def _load_settings() -> dict:
    try:
        payload = json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
    except Exception:
        return {}
    if not isinstance(payload, dict):
        return {}
    return payload


def _service_enabled(settings: dict) -> bool:
    services = settings.get("services", {})
    if not isinstance(services, dict):
        return False
    for service_key in ("home_assistant_widget", "home_assistant"):
        service = services.get(service_key, {})
        if isinstance(service, dict) and "enabled" in service:
            return bool(service.get("enabled", True))
    return False


def _ha_config(settings: dict) -> tuple[str, str]:
    ha = settings.get("home_assistant", {})
    if not isinstance(ha, dict):
        return "", ""
    url = str(ha.get("url", "")).strip().rstrip("/")
    token = str(ha.get("token", "")).strip()
    return url, token


def _cache_path(url: str) -> Path:
    url_tag = hashlib.sha256(url.encode()).hexdigest()[:12]
    return STATE_DIR / f"home_assistant_cache_{url_tag}.json"


def main() -> int:
    settings = _load_settings()

    if not _service_enabled(settings):
        return 0

    url, token = _ha_config(settings)
    if not url or not token:
        return 0

    _ensure_dir(STATE_DIR)

    target_url = f"{url}/api/states"
    auth_header = f"Authorization: Bearer {token}"

    try:
        result = subprocess.run(
            [
                "curl",
                "-fsSL",
                "-H", auth_header,
                "-H", "Content-Type: application/json",
                "-H", "User-Agent: HanautaService/1.0",
                "--connect-timeout", "10",
                "--max-time", "20",
                target_url,
            ],
            capture_output=True,
            text=True,
            timeout=24,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError) as exc:
        print(f"Home Assistant fetch failed: {exc}", file=sys.stderr)
        return 1

    if result.returncode != 0 or not result.stdout.strip():
        return 1

    updated_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%z")

    cache_doc = {
        "source": "home_assistant",
        "updated_at": updated_at,
        "url": url,
        "payload": json.loads(result.stdout),
    }

    cache_path = _cache_path(url)
    _ensure_dir(cache_path.parent)
    cache_path.write_text(json.dumps(cache_doc, indent=2), encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
