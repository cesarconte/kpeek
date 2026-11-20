// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Rendered Markdown, with a toggle to show the source.
Rectangle {
    id: root

    property real zoom: 1.0
    property bool showSource: false
    // Rendering megabytes of Markdown would stall the window; such files are shown as source.
    readonly property bool sourceShown: showSource || !loader.highlight
    readonly property Flickable scrollTarget: scroll.contentItem as Flickable

    color: CachyPalette.sheetBackground

    TextLoader {
        id: loader
        url: PeekController.url
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        CachyInlineMessage {
            Layout.fillWidth: true
            Layout.margins: CachyTheme.spacingSmall
            visible: loader.truncated
            messageType: "information"
            text: i18nc("@info %1 is a size such as 2 MiB", "This file is large; only the first %1 are shown.", Qt.locale().formattedDataSize(loader.maxBytes))
        }

        QQC2.ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            Loader {
                width: scroll.availableWidth
                height: item?.implicitHeight ?? 0
                sourceComponent: root.sourceShown ? sourceView : renderedView
            }
        }
    }

    Component {
        id: renderedView
        QQC2.TextArea {
            text: loader.markdownToHtml(loader.text, PeekController.url)
            textFormat: TextEdit.RichText
            readOnly: true
            selectByMouse: true
            wrapMode: TextEdit.Wrap
            font.pointSize: 13 * root.zoom
            leftPadding: CachyTheme.marginCard
            rightPadding: CachyTheme.marginCard
            topPadding: CachyTheme.marginCard
            background: null
            onLinkActivated: link => {
                const url = new URL(link, PeekController.url);
                if (["http:", "https:", "mailto:"].includes(url.protocol)) {
                    Qt.openUrlExternally(url);
                }
            }
        }
    }

    Component {
        id: sourceView
        SourceText {
            text: loader.text
            fileName: PeekController.fileName
            highlight: loader.highlight
            wrap: true
            zoom: root.zoom
        }
    }

    CachyButton {
        id: srcBtn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: CachyTheme.marginCard
        anchors.rightMargin: CachyTheme.marginCard + (scroll.QQC2.ScrollBar.vertical?.width ?? 0)
        checkable: true
        checked: root.sourceShown
        enabled: loader.highlight
        iconName: "format-text-code"
        text: i18nc("@action:button", "Show Source")
        onClicked: root.showSource = !root.showSource

        CachyTooltip {
            visible: srcBtn.hovered
            text: i18nc("@info:tooltip", "Show the Markdown source (Ctrl+U)")
        }
    }

    Shortcut {
        sequence: "Ctrl+U"
        enabled: loader.highlight
        onActivated: root.showSource = !root.showSource
    }

    RelativeScrollAnchor {
        flickable: root.scrollTarget
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: loader.failed || loader.text.length === 0
        iconName: loader.failed ? "dialog-error" : PeekController.iconName
        text: loader.failed ? i18nc("@info", "This file could not be read") : i18nc("@info", "This file is empty")
    }
}
