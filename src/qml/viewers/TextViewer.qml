// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Plain text and source code with syntax highlighting.
Rectangle {
    id: root

    property real zoom: 1.0
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

            Item {
                implicitWidth: source.wrap ? scroll.availableWidth : source.implicitWidth
                implicitHeight: source.implicitHeight

                SourceText {
                    id: source
                    anchors.fill: parent
                    text: loader.text
                    fileName: PeekController.fileName
                    highlight: loader.highlight
                    zoom: root.zoom
                }
            }
        }
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
