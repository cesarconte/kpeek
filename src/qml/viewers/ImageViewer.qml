// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import CachyOS.UI
import io.github.iamandelib.kpeek

// Plain images, SVG and animated WebP/GIF.
Rectangle {
    id: root

    property real zoom: 1.0
    // Extra zoom for photos so their pixels can be inspected, but not for huge images.
    readonly property real maxZoom: Math.max(4.0, Math.min(16.0, 4096 / Math.max(1, root.sourceSize.width)))
    readonly property Flickable scrollTarget: flick
    readonly property bool dragPans: true

    readonly property bool animated: ["gif", "webp"].includes(PeekController.extension)
    readonly property Item baseImage: animated ? animatedImage : stillImage
    readonly property size sourceSize: Qt.size(baseImage?.implicitWidth ?? 0, baseImage?.implicitHeight ?? 0)

    // Fit to window with a margin; never scale up by default.
    readonly property real fitScale: sourceSize.width > 0 && sourceSize.height > 0
        ? Math.min(1.0, (flick.width - 16) / sourceSize.width, (flick.height - 16) / sourceSize.height)
        : 1.0
    readonly property real shownWidth: Math.round(sourceSize.width * fitScale * zoom)
    readonly property real shownHeight: Math.round(sourceSize.height * fitScale * zoom)

    onZoomChanged: keepCenterInPlace()
    onFitScaleChanged: keepCenterInPlace()

    function keepCenterInPlace() {
        const before = Qt.size(canvas.width, canvas.height);
        const after = Qt.size(shownWidth, shownHeight);
        if (before.width <= 0 || before.height <= 0) {
            return;
        }
        const fx = (flick.contentX + flick.width / 2 - Math.max(0, flick.width - before.width) / 2) / before.width;
        const fy = (flick.contentY + flick.height / 2 - Math.max(0, flick.height - before.height) / 2) / before.height;
        const contentWidth = Math.max(flick.width, after.width);
        const contentHeight = Math.max(flick.height, after.height);
        flick.contentX = Math.max(0, Math.min(fx * after.width + (contentWidth - after.width) / 2 - flick.width / 2, contentWidth - flick.width));
        flick.contentY = Math.max(0, Math.min(fy * after.height + (contentHeight - after.height) / 2 - flick.height / 2, contentHeight - flick.height));
    }

    color: "transparent"

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: CachyTheme.spacingSmall
        contentWidth: Math.max(width, root.shownWidth)
        contentHeight: Math.max(height, root.shownHeight)
        interactive: contentWidth > width || contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Item {
            id: canvas
            x: (flick.contentWidth - width) / 2
            y: (flick.contentHeight - height) / 2
            width: root.shownWidth
            height: root.shownHeight

            Image {
                id: stillImage
                anchors.fill: parent
                visible: !root.animated
                source: !root.animated ? PeekController.url : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                // Render SVGs sharp at any zoom/window size.
                sourceSize.width: PeekController.extension === "svg" ? width : 0
                sourceSize.height: PeekController.extension === "svg" ? height : 0
            }

            AnimatedImage {
                id: animatedImage
                anchors.fill: parent
                visible: root.animated
                source: root.animated ? PeekController.url : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
            }
        }
    }

    CachyBusyIndicator {
        anchors.centerIn: parent
        running: root.baseImage?.status === Image.Loading && PeekController.thumbnail.toString() === ""
    }

    Image {
        id: fallback
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width - 32)
        height: Math.min(implicitHeight, parent.height - 32)
        visible: root.baseImage?.status === Image.Error && status === Image.Ready
        source: root.baseImage?.status === Image.Error ? PeekController.thumbnail : ""
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 64
        visible: root.baseImage?.status === Image.Error && !fallback.visible && fallback.status !== Image.Loading
        iconName: "image-missing"
        text: i18nc("@info", "This image could not be displayed")
    }
}
