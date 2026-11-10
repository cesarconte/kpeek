// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>
// SPDX-FileCopyrightText: 2026 CachyOS UI contributors

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import CachyOS.UI
import io.github.iamandelib.kpeek

Window {
    id: root

    title: PeekController.fileName
    // Fits small screens (e.g. 1366×768 at 125%) with room to spare.
    width: Math.min(Kirigami.Units.gridUnit * 48, Screen.desktopAvailableWidth * 0.85)
    height: Math.min(Kirigami.Units.gridUnit * 32, Screen.desktopAvailableHeight * 0.85)
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 12
    visible: false

    // Frameless window with Wayland transparency and KWin blur
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    property real cornerRadius: CachyTheme.radiusWindow
    CachyWindowBlur.enabled: true

    // Closing the window closes the preview, which quits KPeek.
    onClosing: close => {
        close.accepted = false;
        PeekController.close();
    }

    // =========================================================================
    // WINDOW SURFACE
    // =========================================================================
    Item {
        id: windowSurface
        anchors.fill: parent

        // 1. Translucent Liquid Glass Background (22px squircle radius)
        Rectangle {
            id: windowBackground
            anchors.fill: parent
            radius: CachyTheme.radiusWindow
            color: CachyTheme.windowBackground
        }

        // =====================================================================
        // 2. HEADER BAR (macOS Quick Look Golden Gate Titlebar, 44px)
        // =====================================================================
        Item {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: CachyTheme.titleBarHeight
            z: 10

            DragHandler {
                target: null
                cursorShape: Qt.ClosedHandCursor
                onActiveChanged: if (active) root.startSystemMove()
            }

            TapHandler {
                onDoubleTapped: {
                    if (root.visibility === Window.Maximized) {
                        root.showNormal();
                    } else {
                        root.showMaximized();
                    }
                }
            }

            // --- LEADING AREA (Traffic Lights & Navigation Pill at 18px) ---
            Row {
                id: leadingArea
                anchors.left: parent.left
                anchors.leftMargin: CachyTheme.marginWindow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                CachyTrafficLights {
                    id: trafficLights
                    window: root
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Segmented Previous / Next Chevron Pill
                Rectangle {
                    id: navPill
                    anchors.verticalCenter: parent.verticalCenter
                    height: 26
                    width: 58
                    radius: 6
                    color: CachyTheme.withAlpha(CachyTheme.textPrimary, 0.06)
                    border.width: 1
                    border.color: CachyTheme.specularBorder
                    opacity: PeekController.count > 1 ? 1.0 : 0.35

                    Row {
                        anchors.fill: parent

                        // Previous (<)
                        Item {
                            width: 28
                            height: 26

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                source: "go-previous"
                                width: 14
                                height: 14
                                opacity: prevTap.pressed ? 0.5 : (prevHover.hovered ? 1.0 : 0.75)
                            }

                            HoverHandler {
                                id: prevHover
                                enabled: PeekController.count > 1
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                id: prevTap
                                enabled: PeekController.count > 1
                                onTapped: PeekController.previous()
                            }

                            QQC2.ToolTip.text: i18nc("@action:button", "Previous")
                            QQC2.ToolTip.visible: prevHover.hovered
                        }

                        // Vertical Divider
                        Rectangle {
                            width: 1
                            height: 14
                            anchors.verticalCenter: parent.verticalCenter
                            color: CachyTheme.specularBorder
                        }

                        // Next (>)
                        Item {
                            width: 28
                            height: 26

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                source: "go-next"
                                width: 14
                                height: 14
                                opacity: nextTap.pressed ? 0.5 : (nextHover.hovered ? 1.0 : 0.75)
                            }

                            HoverHandler {
                                id: nextHover
                                enabled: PeekController.count > 1
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                id: nextTap
                                enabled: PeekController.count > 1
                                onTapped: PeekController.next()
                            }

                            QQC2.ToolTip.text: i18nc("@action:button", "Next")
                            QQC2.ToolTip.visible: nextHover.hovered
                        }
                    }
                }
            }

            // --- CENTER AREA (File Icon + Filename + Counter) ---
            RowLayout {
                id: centerArea
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                width: Math.min(implicitWidth, Math.max(80, root.width - (leadingArea.width + trailingArea.width + 72)))

                Kirigami.Icon {
                    source: PeekController.iconName
                    fallback: "unknown"
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                }

                Text {
                    id: fileNameLabel
                    text: PeekController.fileName
                    textFormat: Text.PlainText
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: CachyTheme.textPrimary
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                }

                Rectangle {
                    visible: PeekController.count > 1
                    radius: 8
                    color: CachyTheme.withAlpha(CachyTheme.textPrimary, 0.08)
                    implicitWidth: countLabel.implicitWidth + 12
                    implicitHeight: 18

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: i18nc("@info position in file list", "%1 / %2", PeekController.index + 1, PeekController.count)
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: CachyTheme.textSecondary
                    }
                }
            }

            // --- TRAILING AREA (Zoom Controls + Open Button at 18px) ---
            Row {
                id: trailingArea
                anchors.right: parent.right
                anchors.rightMargin: CachyTheme.marginWindow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                // Zoom Controls Group
                Row {
                    id: zoomGroup
                    visible: input.zoomable
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    // Reset Zoom button (appears when zoom is not 100%)
                    Rectangle {
                        id: resetBtn
                        visible: Math.abs(input.zoom - 1) > 0.001
                        width: 26
                        height: 26
                        radius: 6
                        color: resetHover.hovered ? CachyTheme.cardBackgroundHover : CachyTheme.withAlpha(CachyTheme.textPrimary, 0.05)
                        border.width: 1
                        border.color: CachyTheme.specularBorder
                        anchors.verticalCenter: parent.verticalCenter

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "edit-reset"
                            width: 14
                            height: 14
                        }

                        HoverHandler {
                            id: resetHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: input.zoom = 1
                        }

                        QQC2.ToolTip.text: i18nc("@info:tooltip", "Reset zoom (Ctrl+0)")
                        QQC2.ToolTip.visible: resetHover.hovered
                    }

                    // Zoom Level Pill (- % +)
                    Rectangle {
                        id: zoomPill
                        height: 26
                        radius: 6
                        color: CachyTheme.withAlpha(CachyTheme.textPrimary, 0.06)
                        border.width: 1
                        border.color: CachyTheme.specularBorder
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: zoomRow.implicitWidth + 8

                        Row {
                            id: zoomRow
                            anchors.centerIn: parent
                            spacing: 2

                            // Zoom Out (-)
                            Item {
                                width: 24
                                height: 24
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: input.zoom > input.minZoom ? (zoomOutHover.hovered ? 1.0 : 0.8) : 0.35

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    source: "zoom-out"
                                    width: 13
                                    height: 13
                                }

                                HoverHandler {
                                    id: zoomOutHover
                                    enabled: input.zoom > input.minZoom
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    enabled: input.zoom > input.minZoom
                                    onTapped: input.zoomBy(-1)
                                }

                                QQC2.ToolTip.text: i18nc("@info:tooltip", "Zoom out (Ctrl+−)")
                                QQC2.ToolTip.visible: zoomOutHover.hovered
                            }

                            // Zoom % label
                            Text {
                                id: zoomLabel
                                text: i18nc("@info zoom level", "%1%", Math.round(input.zoom * 100))
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.features: { "tnum": 1 }
                                color: CachyTheme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                width: zoomLabelMetrics.advanceWidth + 8
                                anchors.verticalCenter: parent.verticalCenter

                                TextMetrics {
                                    id: zoomLabelMetrics
                                    font: zoomLabel.font
                                    text: i18nc("@info zoom level", "%1%", 8888)
                                }
                            }

                            // Zoom In (+)
                            Item {
                                width: 24
                                height: 24
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: input.zoom < input.maxZoom ? (zoomInHover.hovered ? 1.0 : 0.8) : 0.35

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    source: "zoom-in"
                                    width: 13
                                    height: 13
                                }

                                HoverHandler {
                                    id: zoomInHover
                                    enabled: input.zoom < input.maxZoom
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    enabled: input.zoom < input.maxZoom
                                    onTapped: input.zoomBy(1)
                                }

                                QQC2.ToolTip.text: i18nc("@info:tooltip", "Zoom in (Ctrl++)")
                                QQC2.ToolTip.visible: zoomInHover.hovered
                            }
                        }
                    }
                }

                // Open with Default Application Button
                CachyButton {
                    id: openButton
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18nc("@action:button", "Open")
                    primary: true
                    implicitHeight: 28
                    leftPadding: 14
                    rightPadding: 14
                    onClicked: PeekController.openExternally()
                    QQC2.ToolTip.text: i18nc("@info:tooltip", "Open with the default application (Enter)")
                    QQC2.ToolTip.visible: openButton.hovered
                }
            }

            // Hairline Separator below titlebar
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: CachyTheme.specularBorder
            }
        }

        // =====================================================================
        // 3. CLIENT VIEWER CONTENT AREA
        // =====================================================================
        Item {
            id: contentArea
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            // Mask that preserves square top corners and clips to 22px squircle bottom corners
            Item {
                id: contentMask
                anchors.fill: parent
                visible: false
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    radius: CachyTheme.radiusWindow
                    color: "white"

                    // Overwrite top half to keep top corners square (matching the 44px titlebar)
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: CachyTheme.radiusWindow
                        color: "white"
                    }
                }
            }

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: contentMask
                }

                Loader {
                    id: viewerLoader
                    anchors.fill: parent
                    focus: true
                    // Unloaded while hidden so closing the preview stops video and audio playback.
                    active: PeekController.showing
                    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
                    LayoutMirroring.childrenInherit: true
                    // A viewer whose QML modules are missing shows the info card rather than an empty window.
                    onStatusChanged: {
                        if (status === Loader.Error && !source.toString().endsWith("InfoViewer.qml")) {
                            source = Qt.resolvedUrl("viewers/InfoViewer.qml");
                        }
                    }
                    onLoaded: {
                        if ("zoom" in item) {
                            item.zoom = Qt.binding(() => input.zoom);
                        }
                    }
                    Keys.onPressed: event => input.handleKey(event)
                }

                ViewerInput {
                    id: input
                    anchors.fill: viewerLoader
                    viewer: viewerLoader.item
                }
            }
        }

        // =====================================================================
        // 4. SPECULAR BORDER (1px Continuous Specular Squircle Rim)
        // =====================================================================
        Rectangle {
            id: specularRim
            anchors.fill: parent
            radius: CachyTheme.radiusWindow
            color: "transparent"
            border.width: 1
            border.color: CachyTheme.specularBorder
            z: 999999
        }

        // =====================================================================
        // 5. FRAMELESS WINDOW RESIZE HANDLERS (Edges and Corners)
        // =========================================================================
        Item {
            anchors.fill: parent
            z: 1000000

            Repeater {
                // [edges, x and y as fractions of the window, spans the full width, spans the full height]
                model: [
                    [Qt.LeftEdge, 0, 0, 0, 1], [Qt.RightEdge, 1, 0, 0, 1], [Qt.TopEdge, 0, 0, 1, 0], [Qt.BottomEdge, 0, 1, 1, 0],
                    [Qt.LeftEdge | Qt.TopEdge, 0, 0, 0, 0], [Qt.RightEdge | Qt.TopEdge, 1, 0, 0, 0],
                    [Qt.LeftEdge | Qt.BottomEdge, 0, 1, 0, 0], [Qt.RightEdge | Qt.BottomEdge, 1, 1, 0, 0]
                ]

                Item {
                    required property var modelData
                    readonly property int edges: modelData[0]
                    // Corners get a larger target than edges.
                    readonly property int size: (modelData[3] || modelData[4] ? 1 : 2) * (Kirigami.Units.smallSpacing + 2)

                    x: modelData[1] * (parent.width - size)
                    y: modelData[2] * (parent.height - size)
                    width: modelData[3] ? parent.width : size
                    height: modelData[4] ? parent.height : size

                    HoverHandler {
                        cursorShape: {
                            const e = parent.edges;
                            if (e === (Qt.LeftEdge | Qt.TopEdge) || e === (Qt.RightEdge | Qt.BottomEdge)) {
                                return Qt.SizeFDiagCursor;
                            }
                            if (e === (Qt.RightEdge | Qt.TopEdge) || e === (Qt.LeftEdge | Qt.BottomEdge)) {
                                return Qt.SizeBDiagCursor;
                            }
                            return e & (Qt.LeftEdge | Qt.RightEdge) ? Qt.SizeHorCursor : Qt.SizeVerCursor;
                        }
                    }
                    DragHandler {
                        target: null
                        onActiveChanged: if (active) root.startSystemResize(parent.edges)
                    }
                }
            }
        }
    }

    // =========================================================================
    // CONTROLLER & SHORTCUT CONNECTIONS (100% Preserved)
    // =========================================================================
    Connections {
        target: PeekController
        function onCurrentChanged() {
            // Unload first: resetting the zoom while the old viewer exists would make it re-layout for nothing.
            viewerLoader.source = "";
            input.zoom = 1;
            viewerLoader.source = Qt.resolvedUrl("viewers/%1Viewer.qml".arg(PeekController.viewer));
        }
    }

    Shortcut {
        sequences: [StandardKey.ZoomIn, "Ctrl+="]
        onActivated: input.zoomBy(1)
    }
    Shortcut {
        sequences: [StandardKey.ZoomOut]
        onActivated: input.zoomBy(-1)
    }
    Shortcut {
        sequences: ["Ctrl+0"]
        onActivated: input.zoom = 1
    }

    Shortcut {
        // Meta+Space is the default Dolphin shortcut that opens a preview, so it closes it here too.
        sequences: [StandardKey.Cancel, "Space", "Meta+Space", "Q"]
        onActivated: PeekController.close()
    }
    Shortcut {
        // Up/Down and Page keys scroll inside documents, so only Left/Right switch files.
        sequences: ["Right"]
        onActivated: PeekController.next()
    }
    Shortcut {
        sequences: ["Left"]
        onActivated: PeekController.previous()
    }
    Shortcut {
        sequences: ["Return", "Enter"]
        onActivated: PeekController.openExternally()
    }
}
