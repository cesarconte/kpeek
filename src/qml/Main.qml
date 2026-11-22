// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>
// SPDX-FileCopyrightText: 2026 CachyOS UI contributors

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

CachyWindow {
    id: root

    title: PeekController.fileName
    width: Math.min(768, Screen.desktopAvailableWidth * 0.85)
    height: Math.min(512, Screen.desktopAvailableHeight * 0.85)
    minimumWidth: 320
    minimumHeight: 192
    visible: false
    showTrafficLights: true
    showTitle: false
    showTitleBarDivider: false
    cornerRadius: CachyTheme.radiusWindow

    function toggleFullScreen() {
        if (root.visibility === Window.FullScreen) {
            root.showNormal();
        } else {
            root.showFullScreen();
        }
    }

    // Closing the window closes the preview, which quits KPeek.
    onClosing: close => {
        close.accepted = false;
        PeekController.close();
    }

    // =========================================================================
    // 1. HEADER LEADING (Segmented Previous / Next Chevron Pill)
    // =========================================================================
    headerLeading: [
        CachyNavigationButtons {
            anchors.verticalCenter: parent.verticalCenter
            visible: PeekController.count > 1
            canGoBack: PeekController.count > 1
            canGoForward: PeekController.count > 1
            opacity: PeekController.count > 1 ? 1.0 : 0.4
            onBackClicked: PeekController.previous()
            onForwardClicked: PeekController.next()
        }
    ]

    // =========================================================================
    // 2. HEADER CENTER (File Icon + Filename + Counter Badge)
    // =========================================================================
    headerCenter: [
        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            CachyIcon {
                name: PeekController.iconName
                fallback: "unknown"
                size: 16
                colored: false
            }

            Text {
                text: PeekController.fileName
                textFormat: Text.PlainText
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: CachyPalette.text
                elide: Text.ElideMiddle
                Layout.maximumWidth: Math.max(120, parent.width - 200)
            }

            Rectangle {
                visible: PeekController.count > 1
                radius: 9
                color: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.06)
                border.width: 1
                border.color: CachyPalette.specularBorder
                implicitWidth: countLabel.implicitWidth + 12
                implicitHeight: 18

                Text {
                    id: countLabel
                    anchors.centerIn: parent
                    text: i18nc("@info position in file list", "%1 / %2", PeekController.index + 1, PeekController.count)
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: CachyPalette.textSecondary
                }
            }
        }
    ]

    // =========================================================================
    // 3. HEADER ACTIONS (Zoom Controls + Open with... + Capsule Actions Group)
    // =========================================================================
    headerActions: [
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            // Zoom Controls Capsule Group (macOS Golden Gate Quick Look pattern)
            CachyToolbarGroup {
                visible: input.zoomable
                anchors.verticalCenter: parent.verticalCenter

                // Zoom Out (-)
                CachyToolbarButton {
                    iconName: "zoom-out"
                    pillStyle: false
                    enabled: input.zoom > input.minZoom
                    tooltipText: i18nc("@info:tooltip", "Zoom out (Ctrl+−)")
                    onClicked: input.zoomBy(-1)
                }

                // Reset Zoom Label / Button (%)
                Rectangle {
                    width: zoomLabelMetrics.advanceWidth + 10
                    height: 22
                    radius: 4
                    color: zoomResetHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: zoomLabel
                        anchors.centerIn: parent
                        text: i18nc("@info zoom level", "%1%", Math.round(input.zoom * 100))
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.features: { "tnum": 1 }
                        color: Math.abs(input.zoom - 1) > 0.001 ? CachyTheme.accentColor : CachyPalette.textSecondary
                    }

                    TextMetrics {
                        id: zoomLabelMetrics
                        font: zoomLabel.font
                        text: i18nc("@info zoom level", "%1%", 8888)
                    }

                    HoverHandler {
                        id: zoomResetHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: input.zoom = 1
                    }

                    CachyTooltip {
                        visible: zoomResetHover.hovered
                        text: i18nc("@info:tooltip", "Reset zoom (Ctrl+0)")
                    }
                }

                // Zoom In (+)
                CachyToolbarButton {
                    iconName: "zoom-in"
                    pillStyle: false
                    enabled: input.zoom < input.maxZoom
                    tooltipText: i18nc("@info:tooltip", "Zoom in (Ctrl++)")
                    onClicked: input.zoomBy(1)
                }
            }

            // Open with Default Application Button
            CachyButton {
                id: openButton
                anchors.verticalCenter: parent.verticalCenter
                text: PeekController.defaultAppName.length > 0
                    ? i18nc("@action:button", "Open with %1", PeekController.defaultAppName)
                    : i18nc("@action:button", "Open")
                iconName: PeekController.defaultAppIcon.length > 0 ? PeekController.defaultAppIcon : "document-open"
                primary: true
                pillStyle: true
                implicitHeight: 28
                leftPadding: 12
                rightPadding: 14
                onClicked: PeekController.openExternally()

                CachyTooltip {
                    visible: openButton.hovered
                    text: i18nc("@info:tooltip", "Open with %1 (Enter)", PeekController.defaultAppName.length > 0 ? PeekController.defaultAppName : i18n("default application"))
                }
            }

            // Actions Capsule Group (Share + Fullscreen)
            CachyToolbarGroup {
                anchors.verticalCenter: parent.verticalCenter

                // Share button (copies path to clipboard)
                CachyToolbarButton {
                    iconName: "share"
                    pillStyle: false
                    tooltipText: i18nc("@action:button", "Copy path to clipboard")
                    onClicked: {
                        PeekController.share();
                        statusToast.show(i18nc("@info:status", "Path copied to clipboard"), "success", 2000);
                    }
                }

                // Fullscreen toggle button
                CachyToolbarButton {
                    iconName: root.visibility === Window.FullScreen ? "view-restore" : "view-fullscreen"
                    pillStyle: false
                    tooltipText: root.visibility === Window.FullScreen
                        ? i18nc("@action:button", "Exit Full Screen (Esc / F)")
                        : i18nc("@action:button", "Full Screen (F)")
                    onClicked: root.toggleFullScreen()
                }
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
    // 5. OVERLAYS (Status Feedback Toast)
    // =========================================================================
    overlay: [
        CachyToast {
            id: statusToast
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
        }
    ]

    // =========================================================================
    // 6. CONTROLLER & SHORTCUT CONNECTIONS
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
        onActivated: {
            if (root.visibility === Window.FullScreen) {
                root.showNormal();
            } else {
                PeekController.close();
            }
        }
    }
    Shortcut {
        sequences: ["F", "F11"]
        onActivated: root.toggleFullScreen()
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
