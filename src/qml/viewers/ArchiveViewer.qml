// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Contents listing of archives.
Rectangle {
    readonly property Flickable scrollTarget: list

    color: CachyPalette.sheetBackground

    ArchiveModel {
        id: archive
        url: PeekController.url
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        visible: !archive.loading && !archive.failed

        QQC2.Label {
            Layout.fillWidth: true
            Layout.margins: CachyTheme.marginCard
            text: archive.incomplete
                ? i18ncp("@info archive summary", "The archive is damaged or incomplete; %1 file could be read", "The archive is damaged or incomplete; %1 files could be read", archive.fileCount)
                : archive.truncated
                ? i18ncp("@info archive summary", "First %1 entry listed; the archive has more", "First %1 entries listed; the archive has more", archive.maxEntries)
                : i18ncp("@info archive summary", "%1 file, %2 uncompressed", "%1 files, %2 uncompressed", archive.fileCount, archive.totalSizeText)
            color: CachyPalette.textSecondary
        }

        CachyDivider {
            Layout.fillWidth: true
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: list
                clip: true
                model: archive
                reuseItems: true

                delegate: RowLayout {
                    id: row

                    required property string name
                    required property string path
                    required property int depth
                    required property string sizeText
                    required property string iconName

                    width: ListView.view.width
                    height: 28
                    spacing: CachyTheme.spacingSmall

                    CachyIcon {
                        name: row.iconName
                        fallback: "unknown"
                        colored: false
                        Layout.leftMargin: CachyTheme.marginCard + row.depth * 16
                        size: 16
                    }
                    Text {
                        id: nameLabel
                        text: row.name
                        textFormat: Text.PlainText
                        elide: Text.ElideMiddle
                        color: CachyPalette.text
                        font.pixelSize: 12
                        Layout.fillWidth: true

                        HoverHandler {
                            id: hover
                        }
                        CachyTooltip {
                            visible: hover.hovered && nameLabel.truncated
                            text: row.path
                        }
                    }
                    Text {
                        text: row.sizeText
                        color: CachyPalette.textSecondary
                        font.pixelSize: 12
                        Layout.rightMargin: CachyTheme.marginCard
                    }
                }
            }
        }
    }

    CachyBusyIndicator {
        anchors.centerIn: parent
        running: archive.loading
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: archive.failed
        iconName: "dialog-error"
        text: i18nc("@info", "This archive could not be read")
    }
}
