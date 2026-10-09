/*
 * Daedric Morrowind — Plasma splash (KSplash).
 * The inscription under the sigil ignites rune by rune as the session's
 * startup stages (1–6) arrive.
 */

import QtQuick

Rectangle {
    id: root
    color: "#060505"

    property int stage
    readonly property string line: "WAKE UP WE ARE HERE"
    readonly property string caption: "wake up. we're here."
    property real progress: Math.min(1, stage / 6)
    Behavior on progress { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }

    DaedricScene {
        id: scene
        anchors.fill: parent
        rune: "S"
        ringRadius: 0.215
        sigilY: 0.37
    }

    Item {
        id: inscription
        width: dimLine.implicitWidth; height: dimLine.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.735 - height / 2

        Text {
            id: dimLine
            text: root.line
            font.family: scene.runes; font.pixelSize: 46 * scene.u; font.letterSpacing: 6 * scene.u
            color: "#3a3330"
            style: Text.Outline; styleColor: "#0a0806"
        }
        Item {
            clip: true
            width: parent.width * root.progress; height: parent.height
            Text {
                text: root.line
                font: dimLine.font
                color: scene.cCrest
                style: Text.Outline; styleColor: "#5c1410"
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: inscription.bottom; anchors.topMargin: 14 * scene.u
        text: root.caption
        font.family: "Noto Serif"; font.italic: true; font.pixelSize: 20 * scene.u; font.letterSpacing: 3 * scene.u
        color: scene.cBrassHi
    }

    // molten bar in a brass frame
    Rectangle {
        id: bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.735 + 98 * scene.u
        width: 560 * scene.u; height: 12 * scene.u
        color: "#0a0806"; border.width: 1; border.color: scene.cBrass
        Rectangle {
            x: 2; y: 2; height: parent.height - 4
            width: (parent.width - 4) * root.progress
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#3f0e0b" }
                GradientStop { position: 0.3; color: "#7d1d15" }
                GradientStop { position: 0.5; color: "#c2633c" }
                GradientStop { position: 0.7; color: "#7d1d15" }
                GradientStop { position: 1.0; color: "#3f0e0b" }
            }
        }
    }
}
