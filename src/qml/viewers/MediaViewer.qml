// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtMultimedia
import CachyOS.UI
import io.github.iamandelib.kpeek

Rectangle {
    id: root

    readonly property bool hasThumbnail: PeekController.thumbnail.toString() !== ""
    property bool waitsForPlay: false

    function heavyForCpu() {
        const resolution = player.metaData.value(MediaMetaData.Resolution);
        const codec = player.metaData.value(MediaMetaData.VideoCodec);
        const large = resolution !== undefined && resolution.width * resolution.height > 1920 * 1080;
        const gpuFriendly = [MediaFormat.VideoCodec.H264, MediaFormat.VideoCodec.H265, MediaFormat.VideoCodec.VP9];
        return player.hasVideo && large && !gpuFriendly.includes(codec);
    }

    function formatTime(ms) {
        const total = Math.floor(ms / 1000);
        const h = Math.floor(total / 3600);
        const m = Math.floor(total % 3600 / 60);
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${s}` : `${m}:${s}`;
    }

    function togglePlayback() {
        player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play();
    }

    color: player.hasVideo ? "black" : CachyPalette.sheetBackground
    focus: true
    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_K: root.togglePlayback(); break;
        case Qt.Key_J: player.position = Math.max(0, player.position - 10000); break;
        case Qt.Key_L: player.position = Math.min(player.duration, player.position + 10000); break;
        case Qt.Key_M: audio.muted = !audio.muted; break;
        default: return;
        }
        event.accepted = true;
    }

    MediaPlayer {
        id: player
        source: PeekController.url
        videoOutput: video
        audioOutput: AudioOutput {
            id: audio
        }
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.LoadedMedia) {
                root.waitsForPlay = root.heavyForCpu();
                if (!root.waitsForPlay) {
                    play();
                }
            }
        }
    }

    Timer {
        id: mouseActivityTimer
        interval: 2500
        running: false
        repeat: false
    }

    Item {
        anchors.fill: parent

        VideoOutput {
            id: video
            anchors.fill: parent
            visible: player.hasVideo
        }

        Image {
            anchors.fill: parent
            visible: root.hasThumbnail && player.position === 0 && (player.hasVideo || player.mediaStatus === MediaPlayer.LoadingMedia)
            source: PeekController.thumbnail
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Rectangle {
            anchors.centerIn: parent
            z: 1
            visible: root.waitsForPlay && player.playbackState !== MediaPlayer.PlayingState && player.position === 0
            width: 64
            height: 64
            radius: 32
            color: Qt.rgba(0, 0, 0, 0.65)
            border.width: 1
            border.color: CachyPalette.specularBorder

            CachyIcon {
                anchors.centerIn: parent
                name: "media-playback-start"
                size: 32
                color: "#FFFFFF"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: player.play()
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: player.hasVideo
            hoverEnabled: true
            onPositionChanged: {
                mouseActivityTimer.restart();
            }
            onClicked: root.togglePlayback()
        }

        // Audio files: icon and tags
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 64, 384)
            visible: !player.hasVideo && player.error === MediaPlayer.NoError
            spacing: CachyTheme.spacingLarge

            CachyIcon {
                name: root.hasThumbnail ? PeekController.thumbnail : PeekController.iconName
                fallback: "audio-x-generic"
                Layout.alignment: Qt.AlignHCenter
                size: 96
                colored: false
            }
            CachyHeading {
                readonly property string title: player.metaData.stringValue(MediaMetaData.Title)
                text: title.length > 0 ? title : PeekController.fileName
                textFormat: Text.PlainText
                level: 2
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Text {
                text: [player.metaData.stringValue(MediaMetaData.ContributingArtist), player.metaData.stringValue(MediaMetaData.AlbumTitle)].filter(s => s.length > 0).join(" — ")
                textFormat: Text.PlainText
                visible: text.length > 0
                color: CachyPalette.textSecondary
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        CachyPlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - 64
            visible: player.error !== MediaPlayer.NoError
            iconName: "dialog-error"
            text: i18nc("@info", "This file could not be played")
        }

        // Floating Liquid Glass playback capsule
        Rectangle {
            id: playbackCapsule
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 32, 460)
            height: 38
            radius: 19
            color: CachyPalette.sheetBackground
            border.width: 1
            border.color: CachyPalette.specularBorder
            z: 2

            opacity: (!player.hasVideo || player.playbackState !== MediaPlayer.PlayingState || controlsHover.hovered || mouseActivityTimer.running) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: CachyTheme.animNormal } }

            HoverHandler {
                id: controlsHover
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: CachyTheme.spacingSmall

                CachyToolbarButton {
                    iconName: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                    tooltipText: player.playbackState === MediaPlayer.PlayingState ? i18nc("@action:button", "Pause") : i18nc("@action:button", "Play")
                    pillStyle: false
                    onClicked: root.togglePlayback()
                }

                Text {
                    text: root.formatTime(player.position)
                    font.pixelSize: 11
                    color: CachyPalette.textSecondary
                    font.family: "monospace"
                }

                CachySlider {
                    id: positionSlider
                    Layout.fillWidth: true
                    from: 0
                    to: Math.max(1, player.duration)
                    value: player.position
                    onMoved: player.position = value
                }

                Text {
                    text: root.formatTime(player.duration)
                    font.pixelSize: 11
                    color: CachyPalette.textSecondary
                    font.family: "monospace"
                }

                CachyToolbarButton {
                    iconName: audio.muted ? "audio-volume-muted" : "audio-volume-high"
                    tooltipText: audio.muted ? i18nc("@action:button", "Unmute") : i18nc("@action:button", "Mute")
                    pillStyle: false
                    onClicked: audio.muted = !audio.muted
                }
            }
        }
    }
}
