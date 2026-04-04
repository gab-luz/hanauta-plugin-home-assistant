#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QCursor
from PyQt6.QtWidgets import QLabel, QLineEdit, QPushButton, QVBoxLayout, QWidget

PLUGIN_ROOT = Path(__file__).resolve().parent
HOME_ASSISTANT_POPUP = PLUGIN_ROOT / "home_assistant_widget.py"
SETTINGS_FILE = (
    Path.home()
    / ".local"
    / "state"
    / "hanauta"
    / "notification-center"
    / "settings.json"
)
SERVICE_KEY = "home_assistant_widget"

DEFAULT_SERVICE = {
    "enabled": True,
    "show_in_notification_center": False,
    "show_in_bar": True,
}


def _save_settings(window) -> None:
    module = sys.modules.get(window.__class__.__module__)
    save_function = (
        getattr(module, "save_settings_state", None) if module is not None else None
    )
    if callable(save_function):
        save_function(window.settings_state)
        return
    callback = getattr(window, "_save_settings", None)
    if callable(callback):
        callback()


def _service_state(window) -> dict[str, object]:
    services = window.settings_state.setdefault("services", {})
    service = services.setdefault(SERVICE_KEY, dict(DEFAULT_SERVICE))
    if not isinstance(service, dict):
        service = dict(DEFAULT_SERVICE)
        services[SERVICE_KEY] = service
    for key, value in DEFAULT_SERVICE.items():
        service.setdefault(key, value)
    return service


def _ha_state(window) -> dict[str, object]:
    current = window.settings_state.setdefault("home_assistant", {})
    if not isinstance(current, dict):
        current = {}
        window.settings_state["home_assistant"] = current
    current.setdefault("url", "")
    current.setdefault("token", "")
    current.setdefault("pinned_entities", [])
    return current


def _persist_home_assistant_state(url: str, token: str) -> None:
    try:
        payload = json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
    except Exception:
        payload = {}
    if not isinstance(payload, dict):
        payload = {}
    current = payload.get("home_assistant", {})
    if not isinstance(current, dict):
        current = {}
    current["url"] = str(url).strip()
    current["token"] = str(token).strip()
    current.setdefault("pinned_entities", [])
    payload["home_assistant"] = current
    try:
        SETTINGS_FILE.parent.mkdir(parents=True, exist_ok=True)
        SETTINGS_FILE.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    except Exception:
        pass


def _launch_popup(window, api: dict[str, object]) -> None:
    if not HOME_ASSISTANT_POPUP.exists():
        status = getattr(window, "home_assistant_plugin_status", None)
        if isinstance(status, QLabel):
            status.setText("home_assistant_widget.py not found in plugin folder.")
        return

    entry_command = api.get("entry_command")
    run_bg = api.get("run_bg")
    command: list[str] = []
    if callable(entry_command):
        try:
            command = list(entry_command(HOME_ASSISTANT_POPUP))
        except Exception:
            command = []
    if not command:
        command = ["python3", str(HOME_ASSISTANT_POPUP)]

    if callable(run_bg):
        try:
            run_bg(command)
        except Exception:
            pass

    status = getattr(window, "home_assistant_plugin_status", None)
    if isinstance(status, QLabel):
        status.setText("Home Assistant popup launched.")


def build_home_assistant_service_section(window, api: dict[str, object]) -> QWidget:
    SettingsRow = api["SettingsRow"]
    SwitchButton = api["SwitchButton"]
    ExpandableServiceSection = api["ExpandableServiceSection"]
    material_icon = api["material_icon"]
    icon_path = str(api.get("plugin_icon_path", "")).strip()

    service = _service_state(window)
    ha = _ha_state(window)

    content = QWidget()
    layout = QVBoxLayout(content)
    layout.setContentsMargins(0, 0, 0, 0)
    layout.setSpacing(10)

    display_switch = SwitchButton(bool(service.get("show_in_notification_center", False)))
    display_switch.toggledValue.connect(
        lambda enabled: window._set_service_notification_visibility(SERVICE_KEY, enabled)
    )
    window.service_display_switches[SERVICE_KEY] = display_switch
    layout.addWidget(
        SettingsRow(
            material_icon("widgets"),
            "Show in notification center",
            "Expose Home Assistant controls in the notification center service list.",
            window.icon_font,
            window.ui_font,
            display_switch,
        )
    )

    bar_switch = SwitchButton(bool(service.get("show_in_bar", True)))
    bar_switch.toggledValue.connect(
        lambda enabled: window._set_service_bar_visibility(SERVICE_KEY, enabled)
    )
    layout.addWidget(
        SettingsRow(
            material_icon("home"),
            "Show on bar",
            "Show the Home Assistant launcher icon in the bar.",
            window.icon_font,
            window.ui_font,
            bar_switch,
        )
    )

    url_input = QLineEdit(str(ha.get("url", "")))
    url_input.setPlaceholderText("http://homeassistant.local:8123")
    layout.addWidget(
        SettingsRow(
            material_icon("link"),
            "Base URL",
            "Home Assistant server URL used by the popup and background cache.",
            window.icon_font,
            window.ui_font,
            url_input,
        )
    )

    token_input = QLineEdit(str(ha.get("token", "")))
    token_input.setEchoMode(QLineEdit.EchoMode.Password)
    token_input.setPlaceholderText("Long-lived access token")
    layout.addWidget(
        SettingsRow(
            material_icon("key"),
            "Access token",
            "Long-lived access token from Home Assistant profile security page.",
            window.icon_font,
            window.ui_font,
            token_input,
        )
    )

    status_label = QLabel("Home Assistant plugin ready.")
    status_label.setWordWrap(True)
    status_label.setStyleSheet("color: rgba(246,235,247,0.72);")

    save_button = QPushButton("Save credentials")
    save_button.setObjectName("secondaryButton")
    save_button.setCursor(QCursor(Qt.CursorShape.PointingHandCursor))

    def _save_credentials() -> None:
        ha_state = _ha_state(window)
        ha_state["url"] = url_input.text().strip()
        ha_state["token"] = token_input.text().strip()
        ha_state.setdefault("pinned_entities", [])
        _persist_home_assistant_state(ha_state["url"], ha_state["token"])
        _save_settings(window)
        status_label.setText("Home Assistant credentials saved.")

    save_button.clicked.connect(_save_credentials)
    layout.addWidget(
        SettingsRow(
            material_icon("save"),
            "Save",
            "Persist URL/token to Hanauta settings.",
            window.icon_font,
            window.ui_font,
            save_button,
        )
    )

    open_button = QPushButton("Open Home Assistant popup")
    open_button.setObjectName("secondaryButton")
    open_button.setCursor(QCursor(Qt.CursorShape.PointingHandCursor))
    open_button.clicked.connect(lambda: _launch_popup(window, api))
    layout.addWidget(
        SettingsRow(
            material_icon("open_in_new"),
            "Open popup",
            "Launch the Home Assistant popup window.",
            window.icon_font,
            window.ui_font,
            open_button,
        )
    )

    layout.addWidget(status_label)
    window.home_assistant_plugin_status = status_label

    section = ExpandableServiceSection(
        SERVICE_KEY,
        "Home Assistant Plugin",
        "Entity status popup with quick actions and pinned controls.",
        "?",
        window.icon_font,
        window.ui_font,
        content,
        window._service_enabled(SERVICE_KEY),
        lambda enabled: window._set_service_enabled(SERVICE_KEY, enabled),
        icon_path=icon_path,
    )
    window.service_sections[SERVICE_KEY] = section
    return section


def register_hanauta_plugin() -> dict[str, object]:
    return {
        "id": SERVICE_KEY,
        "name": "Home Assistant Plugin",
        "api_min_version": 1,
        "service_sections": [
            {
                "key": SERVICE_KEY,
                "builder": build_home_assistant_service_section,
                "supports_show_on_bar": True,
            }
        ],
    }
