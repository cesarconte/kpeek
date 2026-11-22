// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>
// SPDX-FileCopyrightText: 2026 CachyOS UI contributors

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Fallback for folders and files without a dedicated viewer: a summary card. When Dolphin has made a
// thumbnail (camera RAW, EPUB, Blender, Krita, …), it is shown instead of the generic icon.
Rectangle {
    id: root

    color: "transparent"

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 64, 384)
        spacing: CachyTheme.spacingLarge

        Image {
            id: thumbnail
            visible: status === Image.Ready
            source: PeekController.thumbnail
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(implicitWidth, root.width * 0.6)
            Layout.preferredHeight: Math.min(implicitHeight, root.height * 0.5)
        }

        CachyIcon {
            visible: !thumbnail.visible
            name: PeekController.iconName
            fallback: PeekController.isFolder ? "folder" : "unknown"
            Layout.alignment: Qt.AlignHCenter
            size: Math.min(96, Math.max(32, Math.round(root.height / 4)))
            colored: false
        }

        CachyHeading {
            text: PeekController.fileName
            textFormat: Text.PlainText
            level: 2
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        GridLayout {
            columns: 2
            columnSpacing: CachyTheme.spacingMedium
            rowSpacing: CachyTheme.spacingSmall
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: i18nc("@label", "Type:")
                font.pixelSize: 12
                color: CachyPalette.textSecondary
                Layout.alignment: Qt.AlignRight
            }
            Text {
                text: PeekController.mimeComment
                font.pixelSize: 12
                color: CachyPalette.text
            }

            Text {
                text: PeekController.isFolder ? i18nc("@label", "Contains:") : i18nc("@label", "Size:")
                font.pixelSize: 12
                color: CachyPalette.textSecondary
                Layout.alignment: Qt.AlignRight
                visible: sizeValue.visible
            }
            Text {
                id: sizeValue
                text: PeekController.sizeText
                font.pixelSize: 12
                color: CachyPalette.text
                visible: text.length > 0
            }

            Text {
                text: i18nc("@label", "Modified:")
                font.pixelSize: 12
                color: CachyPalette.textSecondary
                Layout.alignment: Qt.AlignRight
                visible: modValue.visible
            }
            Text {
                id: modValue
                text: PeekController.modified.toLocaleString(Qt.locale(), Locale.ShortFormat)
                font.pixelSize: 12
                color: CachyPalette.text
                visible: !isNaN(PeekController.modified)
            }
        }
    }
}
