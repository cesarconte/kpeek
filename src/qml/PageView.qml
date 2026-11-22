// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import CachyOS.UI
import io.github.iamandelib.kpeek

// Scrollable page list shared by the PDF, office and comic viewers.
Rectangle {
    id: root

    required property QtObject document
    property real zoom: 1.0
    readonly property Flickable scrollTarget: view
    readonly property bool dragPans: true
    readonly property real fitWidth: Math.max(160, view.width - CachyTheme.spacingLarge * 2)
    property real pageWidth: 0
    readonly property int renderWidth: Math.min(PeekController.lowMemory ? 2048 : 4096, Math.ceil(pageWidth * PeekController.devicePixelRatio / 256) * 256)

    onZoomChanged: layoutPages()
    onFitWidthChanged: layoutPages()
    Component.onCompleted: layoutPages()

    function layoutPages() {
        const pageBefore = pageWidth;
        if (pageBefore <= 0) {
            pageWidth = fitWidth * zoom;
            return;
        }
        const margin = CachyTheme.spacingLarge * 2;
        const contentBefore = Math.max(view.width, pageBefore + margin);
        const fx = (view.contentX + view.width / 2 - (contentBefore - pageBefore) / 2) / pageBefore;
        const centreY = view.contentY + view.height / 2;
        const index = view.indexAt(view.contentX + view.width / 2, centreY);
        const item = index >= 0 ? view.itemAtIndex(index) : null;
        const t = item ? (centreY - item.y) / item.height : 0;

        pageWidth = fitWidth * zoom;
        view.forceLayout();

        const contentAfter = Math.max(view.width, pageWidth + margin);
        view.contentX = Math.max(0, Math.min(fx * pageWidth + (contentAfter - pageWidth) / 2 - view.width / 2, contentAfter - view.width));
        if (item) {
            view.contentY = item.y + t * item.height - view.height / 2;
        }
    }

    readonly property color borderColor: CachyPalette.specularBorder

    color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.22) : Qt.rgba(0, 0, 0, 0.05)

    ListView {
        id: view
        anchors.fill: parent
        visible: root.document.pageCount > 0
        clip: true
        spacing: CachyTheme.spacingLarge
        topMargin: CachyTheme.spacingLarge
        bottomMargin: 48
        contentWidth: Math.max(width, root.pageWidth + CachyTheme.spacingLarge * 2)
        flickableDirection: Flickable.AutoFlickIfNeeded
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: height
        model: root.document.pageCount

        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}
        QQC2.ScrollBar.horizontal: QQC2.ScrollBar {}

        delegate: Item {
            id: pageItem
            required property int index
            readonly property size pointSize: root.document.pageSize(index)

            width: view.contentWidth
            height: root.pageWidth * pointSize.height / Math.max(1, pointSize.width)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.pageWidth
                height: parent.height
                color: "white"
                border.color: root.borderColor

                Image {
                    id: pageImage
                    anchors.fill: parent
                    source: root.document.pageSource(pageItem.index)
                    sourceSize.width: root.renderWidth
                    asynchronous: true
                    cache: false
                    retainWhileLoading: true
                }
                CachyIcon {
                    anchors.centerIn: parent
                    size: 64
                    visible: pageImage.status === Image.Error
                    name: "image-missing"
                }
            }
        }
    }

    // Page position capsule
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: CachyTheme.spacingLarge
        visible: root.document.pageCount > 0
        width: pageLabel.implicitWidth + 24
        height: 26
        radius: 13
        color: CachyPalette.surfacePill
        border.width: 1
        border.color: CachyPalette.specularBorder

        Text {
            id: pageLabel
            property int current: 0
            readonly property int probe: view.indexAt(view.contentX + view.width / 2, view.contentY + view.height / 2)
            onProbeChanged: if (probe >= 0) current = probe
            anchors.centerIn: parent
            font.pixelSize: 11
            font.weight: Font.Medium
            color: CachyPalette.text
            text: i18nc("@info page position", "Page %1 of %2", current + 1, root.document.pageCount)
        }
    }

    CachyBusyIndicator {
        anchors.centerIn: parent
        running: root.document.pageCount === 0 && !root.document.failed && !root.document.locked
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: root.document.failed || root.document.locked
        iconName: root.document.locked ? "object-locked" : "dialog-error"
        text: root.document.locked ? i18nc("@info", "This document is password-protected") : i18nc("@info", "This document could not be opened")
    }
}
