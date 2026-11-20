// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Font specimen: the family name, the alphabet and a pangram at several sizes.
Rectangle {
    id: root

    property real zoom: 1.0
    readonly property Flickable scrollTarget: scroll.contentItem as Flickable

    color: CachyPalette.sheetBackground

    FontFile {
        id: loader
        url: PeekController.url
    }

    QQC2.ScrollView {
        id: scroll
        contentWidth: availableWidth
        anchors.fill: parent
        visible: !loader.failed

        ColumnLayout {
            width: scroll.availableWidth
            spacing: CachyTheme.spacingLarge

            CachyHeading {
                text: [loader.font.family, loader.font.styleName].filter(s => s.length > 0).join(" ")
                textFormat: Text.PlainText
                level: 1
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.margins: CachyTheme.marginCard
            }

            Text {
                text: "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789 .,;:!?&@#%()[]{}"
                font.family: loader.font.family
                font.styleName: loader.font.styleName
                font.pointSize: 18 * root.zoom
                color: CachyTheme.textPrimary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.leftMargin: CachyTheme.marginCard
                Layout.rightMargin: CachyTheme.marginCard
            }

            Repeater {
                model: [10, 14, 20, 28, 40, 56]

                Text {
                    required property int modelData
                    text: i18nc("@info font sample pangram", "The quick brown fox jumps over the lazy dog")
                    font.family: loader.font.family
                    font.styleName: loader.font.styleName
                    font.pointSize: modelData * root.zoom
                    color: CachyTheme.textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.leftMargin: CachyTheme.marginCard
                    Layout.rightMargin: CachyTheme.marginCard
                }
            }
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: loader.failed
        iconName: "dialog-error"
        text: i18nc("@info", "This font could not be loaded")
    }

    RelativeScrollAnchor {
        flickable: root.scrollTarget
    }
}
