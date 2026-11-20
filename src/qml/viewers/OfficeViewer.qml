// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI
import io.github.iamandelib.kpeek

// Office documents are converted to PDF with LibreOffice, then shown like any PDF.
Rectangle {
    id: root

    property real zoom: 1.0
    readonly property Flickable scrollTarget: pdfLoader.item?.scrollTarget ?? null
    readonly property bool dragPans: true
    readonly property bool converting: converter.status === OfficeConverter.Converting

    color: CachyPalette.sheetBackground

    OfficeConverter {
        id: converter
        source: PeekController.url
    }

    Loader {
        id: pdfLoader
        anchors.fill: parent
        active: converter.status === OfficeConverter.Ready
        sourceComponent: PageView {
            document: PdfDocument {
                url: converter.pdfUrl
            }
            zoom: root.zoom
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginCard
        visible: !pdfLoader.active && preview.status === Image.Ready
        spacing: CachyTheme.spacingMedium

        Image {
            id: preview
            Layout.fillWidth: true
            Layout.fillHeight: true
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: converter.embeddedPreview.length > 0 && !embeddedFailed ? converter.embeddedPreview : PeekController.thumbnail
            property bool embeddedFailed: false
            onStatusChanged: if (status === Image.Error && source.toString() === converter.embeddedPreview) embeddedFailed = true
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: CachyTheme.spacingSmall

            CachyBusyIndicator {
                visible: root.converting
                running: visible
            }
            Text {
                text: root.converting ? i18nc("@info", "Preparing the full preview…") : i18nc("@info", "First page only.")
                color: CachyTheme.textSecondary
                font.pixelSize: 12
            }
            CachyButton {
                visible: !root.converting
                iconName: "document-open"
                text: i18nc("@action:button", "Open")
                onClicked: PeekController.openExternally()
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        visible: root.converting && preview.status !== Image.Ready
        spacing: CachyTheme.spacingMedium

        CachyBusyIndicator {
            running: parent.visible
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: i18nc("@info", "Preparing preview…")
            color: CachyTheme.textPrimary
            font.pixelSize: 13
            Layout.alignment: Qt.AlignHCenter
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: (converter.status === OfficeConverter.Unavailable || converter.status === OfficeConverter.Failed) && preview.status !== Image.Ready
                 && preview.status !== Image.Loading
        iconName: PeekController.iconName
        text: converter.status === OfficeConverter.Unavailable && !converter.sandboxed ? i18nc("@info", "Install LibreOffice to preview this document")
                                                                                      : i18nc("@info", "This document has no preview")
    }
}
