#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from PyQt6.QtCore import QSize
from PyQt6.QtGui import QIcon

SERVICE_KEY = "home_assistant_widget"
PROCESS_ATTR = "_plugin_home_assistant_popup_process"
SETTINGS_FILE = (
    Path.home()
    / ".local"
    / "state"
    / "hanauta"
    / "notification-center"
    / "settings.json"
)


def _prefer_color_widget_icons() -> bool:
    try:
        payload = json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
    except Exception:
        return False
    bar = payload.get("bar", {}) if isinstance(payload, dict) else {}
    bar = bar if isinstance(bar, dict) else {}
    return bool(bar.get("use_color_widget_icons", False))


def _pick_bar_icon(plugin_dir: Path) -> Path | None:
    use_color = _prefer_color_widget_icons()
    candidates = (
        [
            plugin_dir / "icon_color.svg",
            plugin_dir / "assets" / "icon_color.svg",
            plugin_dir / "icon.svg",
            plugin_dir / "assets" / "icon.svg",
        ]
        if use_color
        else [
            plugin_dir / "icon.svg",
            plugin_dir / "assets" / "icon.svg",
        ]
    )
    for path in candidates:
        if path.exists():
            return path
    return None


def _service_state(load_service_settings):
    services = load_service_settings()
    current = services.get(SERVICE_KEY, {}) if isinstance(services, dict) else {}
    return current if isinstance(current, dict) else {}


def register_hanauta_bar_plugin(bar, api: dict[str, object]) -> None:
    plugin_dir = Path(str(api.get("plugin_dir", ""))).expanduser()
    popup_path = plugin_dir / "home_assistant_widget.py"
    if not popup_path.exists():
        return

    add_status_button = api["add_status_button"]
    toggle_singleton_process = api["toggle_singleton_process"]
    sync_popup_button = api["sync_popup_button"]
    load_service_settings = api["load_service_settings"]
    register_hook = api["register_hook"]
    python_bin_fn = api.get("python_bin")

    def on_click() -> None:
        python_bin = str(python_bin_fn()) if callable(python_bin_fn) else "python3"
        active = bool(
            toggle_singleton_process(
                PROCESS_ATTR,
                popup_path,
                python_bin=python_bin,
            )
        )
        button.setChecked(active)

    button = add_status_button(
        SERVICE_KEY,
        "\ue88a",
        tooltip="Home Assistant",
        checkable=True,
        on_click=on_click,
        font_size=16,
    )

    def _apply_icon() -> None:
        path = _pick_bar_icon(plugin_dir)
        if path is None:
            return
        icon = QIcon(str(path))
        if icon.isNull():
            return
        button.setIcon(icon)
        button.setIconSize(QSize(16, 16))
        button.setText("")

    def _sync_visibility() -> None:
        current = _service_state(load_service_settings)
        enabled = bool(current.get("enabled", True))
        show_in_bar = bool(current.get("show_in_bar", True))
        button.setVisible(enabled and show_in_bar)

    def _sync_popup_state() -> None:
        sync_popup_button(button, PROCESS_ATTR, popup_path, tooltip="Home Assistant")

    def _on_close() -> None:
        process = getattr(bar, PROCESS_ATTR, None)
        if process is not None and process.poll() is None:
            process.terminate()

    register_hook("icons", _apply_icon)
    register_hook("settings_reloaded", _sync_visibility)
    register_hook("settings_reloaded", _apply_icon)
    register_hook("poll", _sync_popup_state)
    register_hook("close", _on_close)

    _sync_visibility()
    _apply_icon()
    _sync_popup_state()
