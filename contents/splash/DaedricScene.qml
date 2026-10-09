/*
 * DaedricScene — the shared shrine backdrop for the daedric-morrowind Plasma
 * pieces (lock screen wallpaper, splash). Pure QtQuick. Runes are live text in
 * OMW Ayembedt (SIL OFL), which maps Latin A–Z onto the Daedric alphabet.
 * Source of truth: plasma/shared/DaedricScene.qml (copied by build-assets.py).
 */

import QtQuick

Item {
    id: scene

    // inscriptions: letters A–Z and spaces only
    property string ringOuter:   "MANY FALL BUT ONE REMAINS MANY FALL BUT ONE REMAINS "
    property string ringInner:   "FEAR NOT FOR I AM WATCHFUL YOU HAVE BEEN CHOSEN "
    property string bannerLeft:  "COME NEREVAR FRIEND OR TRAITOR COME"
    property string bannerRight: "COME AND LOOK UPON THE HEART"
    property string rune:        ""       // centre rune, empty for none
    property real   ringRadius:  0.2      // outer ring radius as a fraction of height
    property real   sigilY:      0.37     // sigil centre as a fraction of height
    property bool   banners:     true
    property bool   ornate:      rune.length > 0   // stars, ripples and rune in the centre

    readonly property color cVoid:    "#060505"
    readonly property color cBrass:   "#6e4a38"
    readonly property color cBrassHi: "#86604a"
    readonly property color cBrassLo: "#3a261d"
    readonly property color cBone:    "#b3a58c"
    readonly property color cPeach:   "#c2633c"
    readonly property color cEmber:   "#a8402a"
    readonly property color cBlood:   "#3f0e0b"
    readonly property color cCrest:   "#e39a6a"

    readonly property real   u:     height / 1080
    readonly property string runes: daedricFont.status === FontLoader.Ready ? daedricFont.name : "serif"
    property real pulse: 0
    property real wave:  0

    FontLoader { id: daedricFont; source: "daedric/OMWAyembedt.otf" }

    SequentialAnimation on pulse {
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 2600; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1; to: 0; duration: 2600; easing.type: Easing.InOutSine }
    }
    NumberAnimation on wave { from: 0; to: Math.PI * 2; duration: 9000; loops: Animation.Infinite }

    component Diamond: Rectangle {
        property real size: 7 * scene.u
        width: size; height: size; rotation: 45
        color: scene.cBrassHi; antialiasing: true
    }

    // glowing rune text: peach core, blood stroke
    component Rune: Text {
        font.family: scene.runes
        color: scene.cPeach
        style: Text.Outline; styleColor: scene.cBlood
        renderType: Text.QtRendering
    }

    component RingText: Item {
        id: ringText
        property string text: ""
        property real radius: 100
        property real px: 24
        property int crests: 2
        property real drift: 1
        Repeater {
            model: ringText.text.length
            Item {
                readonly property real heat: Math.pow(0.5 + 0.5 * Math.sin(ringText.drift * scene.wave - index / ringText.text.length * Math.PI * 2 * ringText.crests), 3)
                x: ringText.width / 2; y: ringText.height / 2
                rotation: index * 360 / ringText.text.length
                Rune {
                    text: ringText.text.charAt(index)
                    color: Qt.tint(scene.cPeach, Qt.rgba(scene.cCrest.r, scene.cCrest.g, scene.cCrest.b, parent.heat))
                    font.pixelSize: ringText.px
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -ringText.radius
                }
            }
        }
    }

    component Banner: Item {
        id: banner
        property string text: ""
        property real phase: 0
        width: 64 * scene.u
        height: col.height + 56 * scene.u
        Rectangle { anchors.fill: parent; color: scene.cVoid; opacity: 0.45 }
        Rectangle { x: 0; width: 1; height: parent.height; color: scene.cBrassLo }
        Rectangle { x: parent.width - 1; width: 1; height: parent.height; color: scene.cBrassLo }
        Rectangle { width: parent.width; height: 1; color: scene.cBrass }
        Rectangle { width: parent.width; height: 1; y: parent.height - 1; color: scene.cBrass }
        Diamond { anchors.horizontalCenter: parent.horizontalCenter; anchors.verticalCenter: parent.top }
        Diamond { anchors.horizontalCenter: parent.horizontalCenter; anchors.verticalCenter: parent.bottom }
        Column {
            id: col
            anchors.centerIn: parent
            spacing: 1 * scene.u
            Repeater {
                model: banner.text.length
                Item {
                    readonly property bool gap: banner.text.charAt(index) === " "
                    readonly property real heat: 0.5 + 0.5 * Math.sin(scene.wave + banner.phase - index * 0.42)
                    width: banner.width; height: (gap ? 12 : 27) * scene.u
                    Rune {
                        visible: !parent.gap
                        anchors.centerIn: parent
                        text: banner.text.charAt(index)
                        font.pixelSize: 24 * scene.u
                        color: Qt.rgba(0.30 + 0.48 * parent.heat, 0.06 + 0.32 * parent.heat * parent.heat, 0.04 + 0.18 * parent.heat * parent.heat, 1)
                        styleColor: "#1f0706"
                    }
                }
            }
        }
    }

    // ---- backdrop -----------------------------------------------------------
    Rectangle { anchors.fill: parent; color: scene.cVoid }
    Image {
        anchors.fill: parent
        source: "daedric/background.jpg"
        fillMode: Image.PreserveAspectCrop
    }
    // the Heart breathing under the floor
    Image {
        source: "daedric/glow.png"
        width: scene.width * 0.9; height: scene.height * 0.75
        anchors.horizontalCenter: parent.horizontalCenter
        y: scene.height * 0.72
        opacity: 0.02 + 0.05 * scene.pulse
    }

    // ash on the wind
    Repeater {
        model: 46
        Rectangle {
            readonly property real lane:  Math.random()
            readonly property real drift: 16000 + Math.random() * 22000
            readonly property real size:  (1 + Math.random() * 2.2) * scene.u
            width: size; height: size; radius: size / 2
            color: scene.cBone
            opacity: 0.08 + Math.random() * 0.22
            y: lane * scene.height + Math.sin(scene.wave * 2 + index) * 14 * scene.u
            NumberAnimation on x {
                from: -20 - Math.random() * scene.width; to: scene.width + 20
                duration: drift; loops: Animation.Infinite
            }
        }
    }
    // embers rising
    Repeater {
        model: 16
        Rectangle {
            id: ember
            readonly property real lane: 0.2 + Math.random() * 0.6
            readonly property real life: 7000 + Math.random() * 9000
            width: 2.4 * scene.u; height: width; radius: width / 2
            color: index % 3 === 0 ? scene.cPeach : scene.cEmber
            x: lane * scene.width + Math.sin(scene.wave * 3 + index * 1.7) * 26 * scene.u
            ParallelAnimation {
                running: true; loops: Animation.Infinite
                NumberAnimation { target: ember; property: "y"; from: scene.height + 10; to: scene.height * 0.45; duration: ember.life }
                SequentialAnimation {
                    NumberAnimation { target: ember; property: "opacity"; from: 0; to: 0.85; duration: ember.life * 0.25 }
                    NumberAnimation { target: ember; property: "opacity"; from: 0.85; to: 0; duration: ember.life * 0.75 }
                }
            }
        }
    }

    // ---- banners ------------------------------------------------------------
    Banner {
        visible: scene.banners
        text: scene.bannerLeft
        x: scene.width * 0.055
        anchors.verticalCenter: parent.verticalCenter
    }
    Banner {
        visible: scene.banners
        text: scene.bannerRight
        phase: Math.PI
        x: scene.width * (1 - 0.055) - width
        anchors.verticalCenter: parent.verticalCenter
    }

    // ---- sigil --------------------------------------------------------------
    // layers, outside in: tick ring, outer script, orbiting embers, inner script,
    // then (when ornate) two counter-turning eight-point stars, ripples, the rune
    Item {
        id: sigil
        readonly property real r: scene.ringRadius * scene.height
        readonly property real px: Math.max(18 * scene.u, r * 0.125)
        readonly property real k: r / 208          // the login sigil is drawn at r = 208
        readonly property real c: width / 2
        width: r * 2 + px; height: width
        x: (scene.width - width) / 2
        y: scene.sigilY * scene.height - height / 2

        component Spin: RotationAnimation { loops: Animation.Infinite }
        component Frame: Rectangle {
            property real r: 100
            anchors.centerIn: parent
            width: r * Math.SQRT2; height: width
            color: "transparent"; border.width: 1; antialiasing: true
        }
        component Star: Item {
            id: star
            property real r: 100
            property color line: scene.cBrassLo
            property color gem: scene.cBrassHi
            anchors.fill: parent
            Frame { r: star.r; border.color: star.line }
            Frame { r: star.r; border.color: star.line; rotation: 45 }
            Repeater {
                model: 8
                Item {
                    x: sigil.c; y: sigil.c; rotation: index * 45 + 45
                    Diamond { size: 5 * sigil.k; color: star.gem; x: -size / 2; y: -star.r - size / 2 }
                }
            }
        }
        component Ripple: Rectangle {
            id: ripple
            property real t: 0
            property int delay: 0
            anchors.centerIn: parent
            width: (150 + 290 * t) * sigil.k; height: width; radius: width / 2
            color: "transparent"; border.width: 1; border.color: scene.cEmber
            opacity: 0.45 * (1 - t) * Math.min(1, t * 6)
            SequentialAnimation on t {
                PauseAnimation { duration: ripple.delay }
                NumberAnimation { from: 0; to: 1; duration: 6400; loops: Animation.Infinite; easing.type: Easing.OutQuad }
            }
        }

        Image {
            source: "daedric/glow.png"; anchors.centerIn: parent
            width: Math.min(parent.width, 520 * scene.u); height: width
            visible: scene.ornate
            opacity: 0.12 + 0.20 * scene.pulse
        }

        // tick ring: 72 marks, every sixth long
        Item {
            anchors.fill: parent
            Spin on rotation { from: 360; to: 0; duration: 260000 }
            Repeater {
                model: 72
                Item {
                    x: sigil.c; y: sigil.c; rotation: index * 5
                    Rectangle {
                        readonly property bool major: index % 6 === 0
                        width: 1; height: (major ? 9 : 4) * sigil.k
                        x: -0.5; y: -228 * sigil.k
                        color: major ? scene.cBrassHi : scene.cBrassLo
                    }
                }
            }
        }
        Rectangle { anchors.centerIn: parent; width: 432 * sigil.k; height: width; radius: width / 2; color: "transparent"; border.width: 1; border.color: scene.cBrass }
        Repeater {
            model: 4
            Item {
                x: sigil.c; y: sigil.c; rotation: index * 90
                Diamond { size: 8 * sigil.k; x: -size / 2; y: -216 * sigil.k - size / 2 }
            }
        }
        RingText {
            anchors.fill: parent
            text: scene.ringOuter; radius: sigil.r; px: sigil.px
            Spin on rotation { from: 0; to: 360; duration: 120000 }
        }

        Rectangle { anchors.centerIn: parent; width: 350 * sigil.k; height: width; radius: width / 2; color: "transparent"; border.width: 1; border.color: scene.cBrassLo }
        // embers riding the inner circle
        Item {
            anchors.fill: parent
            Spin on rotation { from: 0; to: 360; duration: 38000 }
            Repeater {
                model: 3
                Item {
                    x: sigil.c; y: sigil.c; rotation: index * 120
                    Rectangle {
                        width: 13 * scene.u; height: width; radius: width / 2
                        x: -width / 2; y: -175 * sigil.k - width / 2
                        color: scene.cEmber; opacity: 0.22
                    }
                    Rectangle {
                        width: 5 * scene.u; height: width; radius: width / 2
                        x: -width / 2; y: -175 * sigil.k - width / 2
                        color: scene.cCrest; opacity: 0.55 + 0.45 * scene.pulse
                    }
                }
            }
        }
        RingText {
            anchors.fill: parent
            text: scene.ringInner; radius: sigil.r - sigil.px * 1.85; px: sigil.px * 0.8
            crests: 3; drift: -1
            Spin on rotation { from: 360; to: 0; duration: 90000 }
        }

        // centre: only when there is no clock or password field to sit behind
        Item {
            anchors.fill: parent
            visible: scene.ornate
            Rectangle { anchors.centerIn: parent; width: 268 * sigil.k; height: width; radius: width / 2; color: "transparent"; border.width: 1; border.color: scene.cBrassLo; opacity: 0.8 }
            Star {
                r: 128 * sigil.k
                Spin on rotation { from: 0; to: 360; duration: 150000 }
            }
            Star {
                r: 104 * sigil.k
                line: scene.cBlood; gem: scene.cEmber
                Spin on rotation { from: 360; to: 0; duration: 96000 }
            }
            Ripple {}
            Ripple { delay: 3200 }
            Rune {
                anchors.centerIn: parent
                text: scene.rune
                font.pixelSize: sigil.r * 0.62
                scale: 1.16 + 0.10 * scene.pulse
                opacity: 0.10 + 0.08 * scene.pulse
                style: Text.Normal
            }
            Rune {
                anchors.centerIn: parent
                text: scene.rune
                font.pixelSize: sigil.r * 0.62
                color: Qt.tint(scene.cPeach, Qt.rgba(scene.cCrest.r, scene.cCrest.g, scene.cCrest.b, 0.25 + 0.55 * scene.pulse))
                scale: 0.98 + 0.03 * scene.pulse
            }
        }
    }
}
