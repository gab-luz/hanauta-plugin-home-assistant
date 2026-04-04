#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path


def _resolve_hanauta_src() -> Path:
    script_path = Path(__file__).resolve()
    candidates: list[Path] = []
    env_src = str(os.environ.get("HANAUTA_SRC", "")).strip()
    if env_src:
        candidates.append(Path(env_src).expanduser())
    candidates.extend(
        [
            script_path.parents[2] / "src",
            script_path.parents[1] / "src",
            Path.home() / ".config" / "i3" / "hanauta" / "src",
        ]
    )
    for candidate in candidates:
        if (candidate / "pyqt").exists():
            return candidate
    return script_path.parents[2]


APP_DIR = _resolve_hanauta_src()
if str(APP_DIR) not in sys.path:
    sys.path.append(str(APP_DIR))

from pyqt.shared.home_assistant import load_service_home_assistant_cache, prefetch_entity_icons
from pyqt.shared.theme import load_theme_palette


SETTINGS_FILE = Path.home() / ".local" / "state" / "hanauta" / "notification-center" / "settings.json"


def load_settings_state() -> dict:
    try:
        payload = json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
    except Exception:
        payload = {}
    if not isinstance(payload, dict):
        payload = {}
    services = payload.get("services", {})
    if not isinstance(services, dict):
        services = {}
    payload["services"] = services
    home_assistant = payload.get("home_assistant", {})
    if not isinstance(home_assistant, dict):
        home_assistant = {}
    payload["home_assistant"] = home_assistant
    return payload


def home_assistant_enabled(settings: dict) -> bool:
    services = settings.get("services", {})
    if not isinstance(services, dict):
        return False
    for service_key in ("home_assistant_widget", "home_assistant"):
        service = services.get(service_key, {})
        if isinstance(service, dict) and "enabled" in service:
            return bool(service.get("enabled", True))
    return False


def configured_base_url(settings: dict) -> str:
    home_assistant = settings.get("home_assistant", {})
    if not isinstance(home_assistant, dict):
        return ""
    return str(home_assistant.get("url", "")).strip()


def prefetch_once() -> int:
    settings = load_settings_state()
    if not home_assistant_enabled(settings):
        return 0
    cache = load_service_home_assistant_cache(configured_base_url(settings))
    if not isinstance(cache, dict):
        return 0
    payload = cache.get("payload", [])
    if not isinstance(payload, list):
        return 0
    theme = load_theme_palette()
    entities = [item for item in payload if isinstance(item, dict)]
    prefetch_entity_icons(entities, tint_color=theme.primary, limit=180)
    return len(entities)


def main() -> int:
    if "--once" in sys.argv:
        prefetch_once()
        return 0

    last_stamp = ""
    while True:
        settings = load_settings_state()
        if home_assistant_enabled(settings):
            cache = load_service_home_assistant_cache(configured_base_url(settings))
            stamp = str(cache.get("updated_at", "")).strip() if isinstance(cache, dict) else ""
            if stamp and stamp != last_stamp:
                prefetch_once()
                last_stamp = stamp
        else:
            last_stamp = ""
        time.sleep(45)


if __name__ == "__main__":
    raise SystemExit(main())
