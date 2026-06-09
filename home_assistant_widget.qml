import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 468
    height: 812
    visible: true
    color: "transparent"
    title: "Hanauta Home Assistant"
    flags: Qt.FramelessWindowHint | Qt.Tool | Qt.WindowStaysOnTopHint

    function glyph(name) {
        return backend.materialIcon(name)
    }

    property var domainChips: [
        { label: "Lights",   icon: "lightbulb",  query: "light." },
        { label: "Switches", icon: "toggle_on",  query: "switch." },
        { label: "Sensors",  icon: "sensors",    query: "sensor." },
        { label: "Climate",  icon: "thermostat", query: "climate." },
        { label: "Covers",   icon: "blinds",     query: "cover." },
        { label: "Locks",    icon: "lock",       query: "lock." },
        { label: "Media",    icon: "speaker",    query: "media_player." },
        { label: "Scenes",   icon: "auto_awesome", query: "scene." },
        { label: "Fans",     icon: "mode_fan",   query: "fan." },
        { label: "Vacuum",   icon: "robot_vacuum", query: "vacuum." },
        { label: "Cameras",  icon: "camera",     query: "camera." },
        { label: "Persons",  icon: "account_circle", query: "person." },
    ]

    component IconVisual: Item {
        id: iconRoot
        property string glyphText: ""
        property string iconSource: ""
        property color tintColor: themeModel.iconTint
        property int iconSize: 18

        implicitWidth: iconSize
        implicitHeight: iconSize

        Text {
            anchors.centerIn: parent
            visible: iconRoot.iconSource === ""
            text: iconRoot.glyphText
            font.family: backend.materialFontFamily
            font.pixelSize: iconRoot.iconSize
            color: iconRoot.tintColor
            renderType: Text.NativeRendering
        }

        Item {
            anchors.centerIn: parent
            width: iconRoot.iconSize
            height: iconRoot.iconSize
            visible: iconRoot.iconSource !== ""

            Image {
                anchors.fill: parent
                source: iconRoot.iconSource
                fillMode: Image.PreserveAspectFit
                sourceSize.width: iconRoot.iconSize
                sourceSize.height: iconRoot.iconSize
                asynchronous: true
                cache: true
                smooth: true
                mipmap: true
            }
        }
    }

    component CircleButton: Button {
        id: circleButton
        property string iconText: ""
        property color iconColor: themeModel.text
        property color fillColor: Qt.rgba(1, 1, 1, 0.06)
        property string tooltipText: ""

        implicitWidth: 40
        implicitHeight: 40
        padding: 0
        hoverEnabled: true
        ToolTip.text: circleButton.tooltipText
        ToolTip.visible: circleButton.hovered && circleButton.tooltipText !== ""
        ToolTip.delay: 450

        background: Rectangle {
            radius: width / 2
            color: !circleButton.enabled
                   ? Qt.rgba(1, 1, 1, 0.04)
                   : circleButton.pressed
                        ? themeModel.pressed
                        : circleButton.hovered
                            ? themeModel.hover
                            : circleButton.fillColor
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            opacity: circleButton.enabled ? 1.0 : 0.55
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        contentItem: Text {
            text: circleButton.iconText
            font.family: backend.materialFontFamily
            font.pixelSize: 18
            color: circleButton.iconColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
    }

    component GlassChip: Rectangle {
        id: chip
        property string label: ""
        property color labelColor: themeModel.textMuted
        property color fillColor: Qt.rgba(1, 1, 1, 0.06)
        property color strokeColor: Qt.rgba(1, 1, 1, 0.10)

        radius: 13
        color: fillColor
        border.width: 1
        border.color: strokeColor
        implicitHeight: 30
        implicitWidth: chipText.implicitWidth + 22

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.label
            color: chip.labelColor
            font.family: backend.uiFontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
        }
    }

    component SoftButton: Button {
        id: softButton
        property color fillColor: Qt.rgba(1, 1, 1, 0.06)
        property color strokeColor: Qt.rgba(1, 1, 1, 0.10)
        property color textColor: themeModel.text
        property string iconText: ""
        property string tooltipText: ""

        implicitHeight: 36
        leftPadding: 12
        rightPadding: 14
        topPadding: 0
        bottomPadding: 0
        spacing: 8
        hoverEnabled: true
        ToolTip.text: softButton.tooltipText
        ToolTip.visible: softButton.hovered && softButton.tooltipText !== ""
        ToolTip.delay: 450

        background: Rectangle {
            radius: 16
            color: !softButton.enabled
                   ? Qt.rgba(1, 1, 1, 0.04)
                   : softButton.pressed
                        ? themeModel.pressed
                        : softButton.hovered
                            ? themeModel.hover
                            : softButton.fillColor
            border.width: 1
            border.color: softButton.strokeColor
            opacity: softButton.enabled ? 1.0 : 0.55
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        contentItem: Row {
            spacing: softButton.iconText !== "" ? 8 : 0
            leftPadding: 0
            rightPadding: 0
            anchors.verticalCenter: parent.verticalCenter

            Text {
                visible: softButton.iconText !== ""
                text: softButton.iconText
                font.family: backend.materialFontFamily
                font.pixelSize: 16
                color: softButton.textColor
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: softButton.text
                font.family: backend.uiFontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: softButton.textColor
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component FilterChip: Button {
        id: filterChip
        property string chipIcon: ""
        property color activeColor: themeModel.primary
        property bool isActive: false

        implicitHeight: 34
        leftPadding: 12
        rightPadding: 14
        topPadding: 0
        bottomPadding: 0
        spacing: 7
        hoverEnabled: true

        background: Rectangle {
            radius: 17
            color: filterChip.pressed
                   ? Qt.rgba(filterChip.activeColor.r, filterChip.activeColor.g, filterChip.activeColor.b, 0.22)
                   : filterChip.hovered
                       ? Qt.rgba(filterChip.activeColor.r, filterChip.activeColor.g, filterChip.activeColor.b, 0.12)
                       : filterChip.isActive
                           ? Qt.rgba(filterChip.activeColor.r, filterChip.activeColor.g, filterChip.activeColor.b, 0.16)
                           : Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            border.color: filterChip.isActive
                          ? Qt.rgba(filterChip.activeColor.r, filterChip.activeColor.g, filterChip.activeColor.b, 0.35)
                          : Qt.rgba(1, 1, 1, 0.08)
            Behavior on color { ColorAnimation { duration: 140 } }
            Behavior on border.color { ColorAnimation { duration: 140 } }
        }

        contentItem: Row {
            spacing: filterChip.spacing
            anchors.verticalCenter: parent.verticalCenter

            Text {
                visible: filterChip.chipIcon !== ""
                text: filterChip.chipIcon
                font.family: backend.materialFontFamily
                font.pixelSize: 16
                color: filterChip.isActive ? filterChip.activeColor : themeModel.textMuted
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: filterChip.text
                font.family: backend.uiFontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: filterChip.isActive ? filterChip.activeColor : themeModel.text
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component SummaryCard: Rectangle {
        id: summaryCard
        property string eyebrow: ""
        property string valueText: ""
        property string helperText: ""
        property color accentColor: themeModel.primary
        property string accentIcon: ""

        radius: 21
        color: Qt.rgba(1, 1, 1, 0.055)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        implicitHeight: 110

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: Qt.rgba(summaryCard.accentColor.r, summaryCard.accentColor.g, summaryCard.accentColor.b, 0.16)
                    border.width: 1
                    border.color: Qt.rgba(summaryCard.accentColor.r, summaryCard.accentColor.g, summaryCard.accentColor.b, 0.28)

                    Text {
                        anchors.centerIn: parent
                        text: summaryCard.accentIcon
                        font.family: backend.materialFontFamily
                        font.pixelSize: 15
                        color: summaryCard.accentColor
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: summaryCard.eyebrow
                    color: themeModel.textMuted
                    font.family: backend.uiFontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    renderType: Text.NativeRendering
                }
            }

            Text {
                Layout.fillWidth: true
                text: summaryCard.valueText
                color: themeModel.text
                font.family: backend.displayFontFamily
                font.pixelSize: 22
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                Layout.fillWidth: true
                text: summaryCard.helperText
                color: themeModel.textMuted
                font.family: backend.uiFontFamily
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 12
            radius: 30
            gradient: Gradient {
                GradientStop { position: 0.0; color: themeModel.panelStart }
                GradientStop { position: 0.55; color: themeModel.panelEnd }
                GradientStop { position: 1.0; color: themeModel.surfaceContainerHigh }
            }
            border.width: 1
            border.color: themeModel.border
            clip: true

            Rectangle {
                width: 260
                height: 260
                radius: 130
                x: -54
                y: -118
                color: themeModel.heroStart
                opacity: 0.40
            }

            Rectangle {
                width: 210
                height: 210
                radius: 105
                anchors.right: parent.right
                anchors.rightMargin: -72
                anchors.top: parent.top
                anchors.topMargin: 120
                color: themeModel.primary
                opacity: 0.08
            }

            Rectangle {
                width: 220
                height: 220
                radius: 110
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -84
                anchors.bottomMargin: -34
                color: themeModel.heroEnd
                opacity: 0.16
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    radius: 27
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    implicitHeight: headerContent.implicitHeight + 30

                    Rectangle {
                        anchors.fill: parent
                        radius: 27
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: themeModel.heroStart }
                            GradientStop { position: 0.5; color: themeModel.heroEnd }
                            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        }
                        opacity: 0.92
                    }

                    ColumnLayout {
                        id: headerContent
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 52
                                height: 52
                                radius: 20
                                color: Qt.rgba(1, 1, 1, 0.10)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.16)

                                Image {
                                    anchors.centerIn: parent
                                    source: "assets/icon_color.svg"
                                    width: 26
                                    height: 26
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                    mipmap: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "CONNECTED HOME"
                                    color: themeModel.textMuted
                                    font.family: backend.uiFontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: backend.statusHeadline
                                    color: themeModel.text
                                    font.family: backend.displayFontFamily
                                    font.pixelSize: 24
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.WordWrap
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: backend.statusHint
                                    color: themeModel.textMuted
                                    font.family: backend.uiFontFamily
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                    renderType: Text.NativeRendering
                                }
                            }

                            RowLayout {
                                spacing: 8

                                CircleButton {
                                    iconText: glyph("refresh")
                                    tooltipText: "Refresh entities now"
                                    onClicked: backend.refresh()
                                }

                                CircleButton {
                                    iconText: glyph("settings")
                                    tooltipText: "Open plugin settings"
                                    onClicked: backend.openSettings()
                                }

                                CircleButton {
                                    iconText: glyph("close")
                                    tooltipText: "Close popup"
                                    onClicked: backend.closeWindow()
                                }
                            }
                        }

                        Row {
                            spacing: 8

                            GlassChip {
                                label: backend.available ? "Live cache ready" : "Background sync pending"
                                labelColor: backend.available ? themeModel.text : themeModel.warning
                                fillColor: backend.available
                                           ? Qt.rgba(1, 1, 1, 0.10)
                                           : Qt.rgba(themeModel.warning.r, themeModel.warning.g, themeModel.warning.b, 0.16)
                                strokeColor: backend.available
                                             ? Qt.rgba(1, 1, 1, 0.12)
                                             : Qt.rgba(themeModel.warning.r, themeModel.warning.g, themeModel.warning.b, 0.28)
                            }

                            GlassChip {
                                visible: backend.latencyMs >= 0
                                label: backend.latencyMs >= 0 ? backend.latencyMs + " ms" : ""
                                labelColor: themeModel.text
                            }

                            GlassChip {
                                visible: backend.busy
                                label: "Refreshing"
                                labelColor: themeModel.primary
                                fillColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.16)
                                strokeColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.26)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 22
                    color: Qt.rgba(1, 1, 1, 0.065)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    implicitHeight: 56

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.12)

                            Text {
                                anchors.centerIn: parent
                                text: glyph("search")
                                font.family: backend.materialFontFamily
                                font.pixelSize: 18
                                color: themeModel.textMuted
                                renderType: Text.NativeRendering
                            }
                        }

                        TextField {
                            Layout.fillWidth: true
                            placeholderText: "Search entities, rooms, domains, states..."
                            text: backend.searchQuery
                            color: themeModel.text
                            placeholderTextColor: themeModel.textMuted
                            font.family: backend.uiFontFamily
                            font.pixelSize: 12
                            selectByMouse: true
                            background: Rectangle {
                                radius: 16
                                color: "transparent"
                            }
                            onTextChanged: backend.setSearchQuery(text)

                            Rectangle {
                                visible: backend.searchQuery.length > 0
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 24
                                height: 24
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.1)

                                Text {
                                    anchors.centerIn: parent
                                    text: glyph("close")
                                    font.family: backend.materialFontFamily
                                    font.pixelSize: 14
                                    color: themeModel.textMuted
                                    renderType: Text.NativeRendering
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: backend.setSearchQuery("")
                                }
                            }
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    contentWidth: domainRow.implicitWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.HorizontalFlick
                    interactive: contentWidth > width

                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

                    Row {
                        id: domainRow
                        spacing: 8

                        Repeater {
                            model: root.domainChips

                            FilterChip {
                                text: modelData.label
                                chipIcon: glyph(modelData.icon)
                                isActive: backend.searchQuery === modelData.query

                                onClicked: {
                                    if (isActive) {
                                        backend.setSearchQuery("")
                                    } else {
                                        backend.setSearchQuery(modelData.query)
                                    }
                                }
                            }
                        }

                        FilterChip {
                            text: "All"
                            chipIcon: glyph("home")
                            isActive: backend.searchQuery.length === 0

                            onClicked: backend.setSearchQuery("")
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    SummaryCard {
                        Layout.fillWidth: true
                        eyebrow: "Pinned controls"
                        valueText: backend.pinnedEntities.length.toString()
                        helperText: backend.pinnedEntities.length > 0
                                    ? "Quick actions parked here for one-tap control."
                                    : "Pin up to five entities to build your shortcut dock."
                        accentColor: themeModel.primary
                        accentIcon: glyph("push_pin")
                    }

                    SummaryCard {
                        Layout.fillWidth: true
                        eyebrow: "Visible now"
                        valueText: backend.entities.length.toString()
                        helperText: backend.searchQuery.length > 0
                                    ? "Filtered results for current search."
                                    : "Entities from hanauta-service cache."
                        accentColor: themeModel.good
                        accentIcon: glyph("bolt")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 23
                    color: Qt.rgba(1, 1, 1, 0.055)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    implicitHeight: pinnedColumn.implicitHeight + 24
                    visible: backend.pinnedEntities.length > 0

                    ColumnLayout {
                        id: pinnedColumn
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Pinned controls"
                                color: themeModel.text
                                font.family: backend.displayFontFamily
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: backend.pinnedEntities.length + "/5"
                                color: themeModel.textMuted
                                font.family: backend.uiFontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.preferredHeight: backend.pinnedEntities.length > 0 ? 100 : 72
                            contentWidth: pinnedRow.implicitWidth
                            contentHeight: pinnedRow.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Row {
                                id: pinnedRow
                                spacing: 10

                                Repeater {
                                    model: backend.pinnedEntities

                                    Rectangle {
                                        width: 128
                                        height: 88
                                        radius: 20
                                        color: Qt.rgba(1, 1, 1, 0.07)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.10)

                                        scale: pinHoverHandler.hovered ? 1.03 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                                        HoverHandler { id: pinHoverHandler }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Rectangle {
                                                    width: 34
                                                    height: 34
                                                    radius: 14
                                                    color: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.14)
                                                    border.width: 1
                                                    border.color: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.24)

                                                    IconVisual {
                                                        anchors.centerIn: parent
                                                        glyphText: modelData.iconGlyph
                                                        iconSource: modelData.iconSource
                                                        iconSize: 18
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }

                                                CircleButton {
                                                    implicitWidth: 30
                                                    implicitHeight: 30
                                                    iconText: glyph("push_pin_outline")
                                                    tooltipText: "Unpin from shortcuts"
                                                    iconColor: themeModel.primary
                                                    fillColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.14)
                                                    onClicked: backend.togglePinned(modelData.entityId)
                                                }
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.friendlyName
                                                color: themeModel.text
                                                font.family: backend.uiFontFamily
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.state
                                                color: themeModel.textMuted
                                                font.family: backend.uiFontFamily
                                                font.pixelSize: 10
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }

                                            Item { Layout.fillHeight: true }

                                            SoftButton {
                                                Layout.fillWidth: true
                                                text: modelData.actionLabel
                                                iconText: glyph("play_arrow")
                                                visible: modelData.canToggle
                                                implicitHeight: 30
                                                fillColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.16)
                                                strokeColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.28)
                                                textColor: themeModel.text
                                                onClicked: backend.activateEntity(modelData.entityId)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 23
                    color: Qt.rgba(1, 1, 1, 0.055)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    implicitHeight: favoriteColumn.implicitHeight + 24

                    ColumnLayout {
                        id: favoriteColumn
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Quick toggles"
                                color: themeModel.text
                                font.family: backend.displayFontFamily
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: backend.favoriteEntities.length > 0 ? "Tap to toggle" : "No toggleable entities"
                                color: themeModel.textMuted
                                font.family: backend.uiFontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                renderType: Text.NativeRendering
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.preferredHeight: backend.favoriteEntities.length > 0 ? 68 : 56
                            contentWidth: favoriteRow.implicitWidth
                            contentHeight: favoriteRow.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            flickableDirection: Flickable.HorizontalFlick
                            interactive: contentWidth > width
                            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                            Row {
                                id: favoriteRow
                                spacing: 10

                                Repeater {
                                    model: backend.favoriteEntities

                                    Rectangle {
                                        width: 114
                                        height: 58
                                        radius: 17
                                        color: Qt.rgba(1, 1, 1, 0.065)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.10)

                                        scale: favHoverHandler.hovered ? 1.04 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                                        HoverHandler { id: favHoverHandler }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 10

                                            Rectangle {
                                                width: 34
                                                height: 34
                                                radius: 14
                                                color: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.16)
                                                border.width: 1
                                                border.color: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.26)

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: backend.activateEntity(modelData.entityId)
                                                }

                                                IconVisual {
                                                    anchors.centerIn: parent
                                                    glyphText: modelData.iconGlyph
                                                    iconSource: modelData.favoriteIconSource
                                                    iconSize: 16
                                                    tintColor: "#F5F7FF"
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 3

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.friendlyName
                                                    color: themeModel.text
                                                    font.family: backend.uiFontFamily
                                                    font.pixelSize: 12
                                                    font.weight: Font.DemiBold
                                                    elide: Text.ElideRight
                                                    renderType: Text.NativeRendering
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.state
                                                    color: themeModel.textMuted
                                                    font.family: backend.uiFontFamily
                                                    font.pixelSize: 9
                                                    elide: Text.ElideRight
                                                    renderType: Text.NativeRendering
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: backend.favoriteEntities.length === 0
                                    width: Math.max(300, root.width - 92)
                                    height: 56
                                    radius: 18
                                    color: Qt.rgba(1, 1, 1, 0.045)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.08)

                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width - 24
                                        text: "Actionable entities like lights, switches and scenes will appear here."
                                        color: themeModel.textMuted
                                        font.family: backend.uiFontFamily
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignHCenter
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 200
                    radius: 24
                    color: Qt.rgba(1, 1, 1, 0.050)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: "Home canvas"
                                    color: themeModel.text
                                    font.family: backend.displayFontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: backend.searchQuery.length > 0
                                          ? "Filtered entity stream"
                                          : "Everyday devices, scenes and automations"
                                    color: themeModel.textMuted
                                    font.family: backend.uiFontFamily
                                    font.pixelSize: 11
                                    renderType: Text.NativeRendering
                                }
                            }

                            Item { Layout.fillWidth: true }

                            GlassChip {
                                label: backend.entities.length + " results"
                            }
                        }

                        ListView {
                            id: entityList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: backend.entities
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                id: entityCard
                                width: ListView.view.width
                                height: contentColumn.implicitHeight + 24
                                radius: 21
                                color: Qt.rgba(1, 1, 1, 0.060)
                                border.width: 1
                                border.color: modelData.stateTone === "active"
                                              ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.22)
                                              : Qt.rgba(1, 1, 1, 0.08)

                                scale: entityHoverHandler.hovered ? 1.015 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                Behavior on border.color { ColorAnimation { duration: 180 } }

                                HoverHandler { id: entityHoverHandler }

                                property bool expanded: false

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    width: 4
                                    radius: 2
                                    visible: modelData.stateTone === "active"
                                    color: themeModel.primary
                                    opacity: modelData.stateTone === "active" ? 0.7 : 0.0
                                }

                                ColumnLayout {
                                    id: contentColumn
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 12

                                        Rectangle {
                                            width: 42
                                            height: 42
                                            radius: 16
                                            color: modelData.stateTone === "active"
                                                   ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.16)
                                                   : Qt.rgba(1, 1, 1, 0.07)
                                            border.width: 1
                                            border.color: modelData.stateTone === "active"
                                                         ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.26)
                                                         : Qt.rgba(1, 1, 1, 0.10)

                                            IconVisual {
                                                anchors.centerIn: parent
                                                glyphText: modelData.iconGlyph
                                                iconSource: modelData.iconSource
                                                iconSize: 20
                                                tintColor: modelData.stateTone === "active" ? themeModel.primary : themeModel.iconTint
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 3

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.friendlyName
                                                color: themeModel.text
                                                font.family: backend.uiFontFamily
                                                font.pixelSize: 13
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.secondary
                                                color: themeModel.textMuted
                                                font.family: backend.uiFontFamily
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                                visible: text.length > 0
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.entityId
                                                color: Qt.rgba(themeModel.textMuted.r, themeModel.textMuted.g, themeModel.textMuted.b, 0.82)
                                                font.family: backend.uiFontFamily
                                                font.pixelSize: 10
                                                elide: Text.ElideMiddle
                                                renderType: Text.NativeRendering
                                            }
                                        }

                                        Column {
                                            spacing: 6

                                            GlassChip {
                                                label: modelData.state
                                                labelColor: modelData.stateTone === "active" ? themeModel.text : themeModel.textMuted
                                                fillColor: modelData.stateTone === "active"
                                                           ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.16)
                                                           : Qt.rgba(1, 1, 1, 0.06)
                                                strokeColor: modelData.stateTone === "active"
                                                             ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.26)
                                                             : Qt.rgba(1, 1, 1, 0.08)
                                            }

                                            GlassChip {
                                                label: modelData.domainLabel
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.updatedText
                                            color: themeModel.textMuted
                                            font.family: backend.uiFontFamily
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        SoftButton {
                                            text: modelData.isPinned ? "Pinned" : "Pin"
                                            iconText: modelData.isPinned ? glyph("push_pin") : glyph("push_pin_outline")
                                            tooltipText: modelData.isPinned
                                                          ? "Remove from pinned shortcuts"
                                                          : "Pin to shortcuts"
                                            fillColor: modelData.isPinned
                                                       ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.15)
                                                       : Qt.rgba(1, 1, 1, 0.05)
                                            strokeColor: modelData.isPinned
                                                         ? Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.24)
                                                         : Qt.rgba(1, 1, 1, 0.08)
                                            onClicked: backend.togglePinned(modelData.entityId)
                                        }

                                        SoftButton {
                                            visible: modelData.canToggle
                                            text: modelData.actionLabel
                                            iconText: glyph("play_arrow")
                                            tooltipText: "Send action to entity"
                                            fillColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.15)
                                            strokeColor: Qt.rgba(themeModel.primary.r, themeModel.primary.g, themeModel.primary.b, 0.24)
                                            onClicked: backend.activateEntity(modelData.entityId)
                                        }

                                        SoftButton {
                                            text: entityCard.expanded ? "Hide" : "Details"
                                            iconText: entityCard.expanded ? glyph("expand_more") : glyph("chevron_right")
                                            tooltipText: entityCard.expanded
                                                          ? "Collapse details"
                                                          : "Expand details"
                                            onClicked: entityCard.expanded = !entityCard.expanded
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        visible: entityCard.expanded
                                        radius: 17
                                        color: Qt.rgba(1, 1, 1, 0.045)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.07)
                                        implicitHeight: detailsText.implicitHeight + 20

                                        Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                                        Text {
                                            id: detailsText
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            text: modelData.details.length > 0
                                                  ? modelData.details
                                                  : "No extra attributes exposed for this entity."
                                            color: themeModel.textMuted
                                            font.family: backend.uiFontFamily
                                            font.pixelSize: 10
                                            wrapMode: Text.WordWrap
                                            renderType: Text.NativeRendering
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: backend.entities.length === 0
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: 170
                                radius: 24
                                color: Qt.rgba(1, 1, 1, 0.045)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.08)

                                Column {
                                    anchors.centerIn: parent
                                    width: parent.width - 48
                                    spacing: 10

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 52
                                        height: 52
                                        radius: 20
                                        color: Qt.rgba(1, 1, 1, 0.06)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.10)

                                        Text {
                                            anchors.centerIn: parent
                                            text: glyph("home")
                                            font.family: backend.materialFontFamily
                                            font.pixelSize: 24
                                            color: themeModel.textMuted
                                            renderType: Text.NativeRendering
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: backend.available
                                              ? "No entities matched your search."
                                              : "Your Home Assistant stream is not ready yet."
                                        horizontalAlignment: Text.AlignHCenter
                                        color: themeModel.text
                                        font.family: backend.displayFontFamily
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                        wrapMode: Text.WordWrap
                                        renderType: Text.NativeRendering
                                    }

                                    Text {
                                        width: parent.width
                                        text: backend.statusHint
                                        horizontalAlignment: Text.AlignHCenter
                                        color: themeModel.textMuted
                                        font.family: backend.uiFontFamily
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
