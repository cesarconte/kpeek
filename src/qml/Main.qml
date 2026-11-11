// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>
// SPDX-FileCopyrightText: 2026 CachyOS UI contributors

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import CachyOS.UI
import io.github.iamandelib.kpeek

CachyWindow {
    id: root

    title: PeekController.fileName
    // Fits small screens (e.g. 1366×768 at 125%) with room to spare.
    width: Math.min(Kirigami.Units.gridUnit * 48, Screen.desktopAvailableWidth * 0.85)
    height: Math.min(Kirigami.Units.gridUnit * 32, Screen.desktopAvailableHeight * 0.85)
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 12
    visible: false

    // Closing the window closes the preview, which quits KPeek.
    onClosing: close => {
        close.accepted = false;
        PeekController.close();
    }

    // =========================================================================
    // 1. HEADER LEADING (Segmented Previous / Next Chevron Pill)
    // =========================================================================
    headerLeading: [
        Rectangle {
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
    ]

    // =========================================================================
    // 2. HEADER CENTER (File Icon + Filename + Counter Badge)
    // =========================================================================
    headerCenter: [
        RowLayout {
            spacing: 6

            Kirigami.Icon {
                source: PeekController.iconName
                fallback: "unknown"
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }

            Text {
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
    ]

    // =========================================================================
    // 3. HEADER ACTIONS (Zoom Controls + Open Button at 18px margin)
    // =========================================================================
    headerActions: [
        Row {
            spacing: 12

            // Zoom Controls Group
            Row {
                visible: input.zoomable
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                // Reset Zoom button
                Rectangle {
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
    ]

    // =========================================================================
    // 4. CLIENT CONTENT AREA (Injected into CachyWindow auto-masked content)
    // =========================================================================
    contentData: [
        Loader {
            id: viewerLoader
            anchors.fill: parent
            focus: true
            active: PeekController.showing
            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true
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
        },

        ViewerInput {
            id: input
            anchors.fill: viewerLoader
            viewer: viewerLoader.item
        }
    ]

    // =========================================================================
    // 5. CONTROLLER & SHORTCUT CONNECTIONS
    // =========================================================================
    Connections {
        target: PeekController
        function onCurrentChanged() {
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
        sequences: [StandardKey.Cancel, "Space", "Meta+Space", "Q"]
        onActivated: PeekController.close()
    }
    Shortcut {
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
