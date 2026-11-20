// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2026 Andelib Taref Srizon <andelibtarefsrizon@gmail.com>

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick3D
import QtQuick3D.AssetUtils
import QtQuick3D.Helpers
import CachyOS.UI
import io.github.iamandelib.kpeek

// 3D models (glTF/GLB, OBJ, STL, 3MF) through Qt Quick 3D
Rectangle {
    id: root

    property real zoom: 1.0
    readonly property bool hardware: GraphicsInfo.api !== GraphicsInfo.Software
    property bool loadRequested: PeekController.modelBytes() <= (PeekController.lowMemory ? 4 : 10) * 1024 * 1024

    color: CachyPalette.sheetBackground

    Loader {
        anchors.fill: parent
        active: !root.hardware || !root.loadRequested
        source: "InfoViewer.qml"
    }

    CachyButton {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        visible: root.hardware && !root.loadRequested
        iconName: "view-preview"
        text: i18nc("@action:button", "Load 3D Model")
        primary: true
        onClicked: root.loadRequested = true
    }

    Loader {
        anchors.fill: parent
        active: root.hardware && root.loadRequested
        sourceComponent: Item {
            id: scene

            property real fitDistance: 0
            readonly property real zoom: root.zoom

            function fitCamera() {
                const min = model.bounds.minimum;
                const max = model.bounds.maximum;
                const radius = max.minus(min).length() / 2;
                if (radius <= 0) {
                    return;
                }
                model.position = min.plus(max).times(-0.5);
                origin.eulerRotation = Qt.vector3d(-20, 35, 0);
                fitDistance = radius / Math.sin(camera.fieldOfView * Math.PI / 360) * 1.05;
                camera.position = Qt.vector3d(0, 0, fitDistance / zoom);
            }

            onZoomChanged: {
                if (fitDistance > 0) {
                    camera.position = camera.position.normalized().times(fitDistance / zoom);
                }
            }

            View3D {
                id: view
                anchors.fill: parent

                environment: SceneEnvironment {
                    backgroundMode: SceneEnvironment.Color
                    clearColor: CachyPalette.sheetBackground
                    antialiasingMode: SceneEnvironment.MSAA
                    antialiasingQuality: PeekController.lowMemory ? SceneEnvironment.Medium : SceneEnvironment.High
                }

                Node {
                    id: origin

                    PerspectiveCamera {
                        id: camera
                        z: 300

                        DirectionalLight {
                            brightness: 0.9
                            ambientColor: Qt.rgba(0.35, 0.35, 0.35, 1)
                        }
                    }
                }

                DirectionalLight {
                    eulerRotation.x: -45
                    eulerRotation.y: 30
                    brightness: 0.5
                }

                RuntimeLoader {
                    id: model
                    source: PeekController.url
                    onBoundsChanged: scene.fitCamera()
                }
            }

            OrbitCameraController {
                anchors.fill: view
                origin: origin
                camera: camera
                automaticClipping: true
            }

            CachyPlaceholderMessage {
                anchors.centerIn: parent
                width: parent.width - 64
                visible: model.status === RuntimeLoader.Error
                iconName: "dialog-error"
                text: i18nc("@info", "This model could not be loaded")
            }
        }
    }
}
