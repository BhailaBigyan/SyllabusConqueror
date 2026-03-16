import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root

    signal endSessionRequested()

    required property var topicModel
    required property var focusController

    color: "#050510"

    Connections {
        target: focusController
        function onSessionFinished() {
            sessionFinishedDialog.open()
        }
    }

    Dialog {
        id: sessionFinishedDialog
        title: "Mission Accomplished!"
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        standardButtons: Dialog.Ok

        background: Rectangle {
            color: "#111820"
            border.color: "#00E5FF"
            radius: 12
        }

        Text {
            text: "Congratulations! The 9-hour focus session has ended.\nTotal Marks Secured: " + topicModel.securedMarks + " / " + topicModel.totalMarks
            color: "#E0E8F0"
            width: 300
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        onAccepted: root.endSessionRequested()
    }

    // ── Animated background radial glow ─────────────────────────────────
    Canvas {
        id: bgGlow
        anchors.fill: parent
        property real glowAngle: 0

        onGlowAngleChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var cx = width  / 2 + Math.cos(glowAngle) * width  * 0.08
            var cy = height / 2 + Math.sin(glowAngle) * height * 0.08
            var r  = Math.max(width, height) * 0.72
            var grd = ctx.createRadialGradient(cx, cy, 0, cx, cy, r)
            grd.addColorStop(0.0, "#0A1535")
            grd.addColorStop(0.5, "#060A1A")
            grd.addColorStop(1.0, "#050510")
            ctx.fillStyle = grd
            ctx.fillRect(0, 0, width, height)
        }

        NumberAnimation on glowAngle {
            from: 0; to: Math.PI * 2
            duration: 30000
            loops: Animation.Infinite
            running: true
        }
    }

    // Subtle scanline overlay
    Canvas {
        anchors.fill: parent
        opacity: 0.03
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#00E5FF"
            ctx.lineWidth = 1
            for (var y = 0; y <= height; y += 4) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
            }
        }
    }

    // ── Main layout: clock centre + right sidebar ────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── LEFT/CENTER — Clock area ─────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: 36

                // FOCUS ACTIVE label
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "●  DEEP FOCUS ACTIVE"
                    font { pixelSize: 13; family: "Segoe UI"; letterSpacing: 5; weight: Font.Medium }
                    color: "#00E5FF"
                    opacity: pulseAnim.running ? 1.0 : 0.6

                    SequentialAnimation {
                        id: pulseAnim
                        running: focusController.running
                        loops: Animation.Infinite
                        NumberAnimation { target: pulseLabel; property: "opacity"; to: 0.3; duration: 900 }
                        NumberAnimation { target: pulseLabel; property: "opacity"; to: 1.0; duration: 900 }
                    }
                    id: pulseLabel
                }

                // Big HH:MM:SS clock
                Text {
                    id: clockDisplay
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: focusController.formattedTime
                    font {
                        pixelSize: 120
                        family: "Courier New"
                        weight: Font.Bold
                        letterSpacing: 8
                    }
                    color: "#00E5FF"

                    // Neon glow
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.35
                        blurMax: 40
                        colorization: 1.0
                        colorizationColor: "#00E5FF"
                    }

                    Behavior on text { }

                    // Subtle pulse on each tick
                    SequentialAnimation {
                        running: focusController.running
                        loops: Animation.Infinite
                        id: tickAnim

                        NumberAnimation {
                            target: clockDisplay
                            property: "scale"
                            to: 1.008
                            duration: 500
                            easing.type: Easing.OutSine
                        }
                        NumberAnimation {
                            target: clockDisplay
                            property: "scale"
                            to: 1.0
                            duration: 500
                            easing.type: Easing.InSine
                        }
                    }
                }

                // Session label
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SESSION DURATION"
                    font { pixelSize: 12; family: "Segoe UI"; letterSpacing: 4 }
                    color: "#2A3A5A"
                }

                // ── Progress bar ─────────────────────────────────────────
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: Math.min(root.width * 0.55, 600)

                    RowLayout {
                        width: parent.width

                        Text {
                            text: "Marks Secured"
                            font { pixelSize: 13; family: "Segoe UI" }
                            color: "#3A5070"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: topicModel.securedMarks + " / " + topicModel.totalMarks
                            font { pixelSize: 14; family: "Segoe UI"; weight: Font.Bold }
                            color: "#00E5FF"
                        }
                    }

                    // Background track
                    Rectangle {
                        width: parent.width
                        height: 12
                        radius: 6
                        color: "#0A1525"
                        border.color: "#1A2A40"
                        border.width: 1

                        // Fill
                        Rectangle {
                            id: progressFill
                            height: parent.height
                            radius: parent.radius
                            width: topicModel.totalMarks > 0
                                   ? parent.width * (topicModel.securedMarks / topicModel.totalMarks)
                                   : 0

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#007A99" }
                                GradientStop { position: 1.0; color: "#00E5FF" }
                            }

                            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

                            // Animated shimmer
                            Rectangle {
                                id: shimmer
                                width: 60; height: parent.height
                                radius: parent.radius
                                color: "white"
                                opacity: 0.12
                                x: -width

                                SequentialAnimation {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { target: shimmer; property: "x"; from: -60; to: progressFill.width + 60; duration: 1800; easing.type: Easing.InOutSine }
                                    PauseAnimation { duration: 1500 }
                                }
                            }
                        }
                    }

                    // Percentage text
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: topicModel.totalMarks > 0
                              ? Math.round(topicModel.securedMarks / topicModel.totalMarks * 100) + "% complete"
                              : "0% complete"
                        font { pixelSize: 12; family: "Segoe UI" }
                        color: "#2A4A60"
                    }
                }

                // ── Control buttons ───────────────────────────────────────
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    // Pause / Resume
                    FocusButton {
                        text: focusController.running ? "⏸  PAUSE" : "▶  RESUME"
                        accent: focusController.running ? "#FFB300" : "#00E5FF"
                        onClicked: focusController.running
                                   ? focusController.pauseSession()
                                   : focusController.resumeSession()
                    }

                    // End session
                    FocusButton {
                        text: "■  END SESSION"
                        accent: "#FF4466"
                        onClicked: root.endSessionRequested()
                    }
                }
            }
        }

        // ── RIGHT sidebar — topic checklist ──────────────────────────────
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#07090F"
            border.color: "#0E1828"
            border.width: 1

            Column {
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                spacing: 0

                // Sidebar header
                Text {
                    topPadding: 24
                    bottomPadding: 16
                    text: "TOPICS"
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                    font.letterSpacing: 4
                    font.weight: Font.Bold
                    color: "#2A4060"
                }

                Rectangle { width: parent.width; height: 1; color: "#0E1828" }
            }

            ListView {
                id: sidebarList
                anchors {
                    top: parent.top; topMargin: 72
                    left: parent.left; leftMargin: 0
                    right: parent.right; rightMargin: 0
                    bottom: sidebarBottom.top; bottomMargin: 8
                }
                model: topicModel
                clip: true
                spacing: 2

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle { radius: 2; color: "#00E5FF"; opacity: 0.3 }
                }

                delegate: Rectangle {
                    width: sidebarList.width
                    height: 54
                    color: sbMouse.containsMouse ? "#0D141E" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 20; rightMargin: 16 }
                        spacing: 12

                        // Mini checkbox
                        Rectangle {
                            width: 18; height: 18; radius: 9
                            color: model.topicChecked ? "#00E5FF" : "transparent"
                            border.color: model.topicChecked ? "#00E5FF" : "#2A3A50"
                            border.width: 1.5
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✓"; font { pixelSize: 10; weight: Font.Bold }
                                color: "#050A0D"; visible: model.topicChecked
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: topicModel.toggleChecked(index)
                            }
                        }

                        // Name
                        Text {
                            Layout.fillWidth: true
                            text: model.topicName
                            font { pixelSize: 13; family: "Segoe UI" }
                            color: model.topicChecked ? "#2A4050" : "#8AA0B8"
                            elide: Text.ElideRight
                        }

                        // Marks
                        Text {
                            text: model.topicMarks + "M"
                            font { pixelSize: 11; family: "Segoe UI"; weight: Font.Bold }
                            color: model.topicChecked ? "#1A3040" : "#005566"
                        }
                    }

                    // Separator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#0A1520"
                    }

                    MouseArea { id: sbMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                }
            }

            // Sidebar bottom — secured marks total
            Column {
                id: sidebarBottom
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 20 }
                bottomPadding: 20
                spacing: 6

                Rectangle { width: parent.width; height: 1; color: "#0E1828" }

                RowLayout {
                    width: parent.width

                    Text {
                        text: "Secured"
                        font.pixelSize: 12
                        font.family: "Segoe UI"
                        color: "#2A4060"
                        topPadding: 12
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: topicModel.securedMarks + " / " + topicModel.totalMarks + " M"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#00E5FF"
                        topPadding: 12
                    }
                }
            }
        }
    }

    // Peek time overlay
    property bool peekVisible: false
    property string peekText: Qt.formatTime(new Date(), "hh:mm:ss")
    Timer {
        id: peekUpdate
        interval: 1000
        repeat: true
        running: root.peekVisible
        onTriggered: root.peekText = Qt.formatTime(new Date(), "hh:mm:ss")
    }
    Timer {
        id: peekHide
        interval: 7000
        repeat: false
        onTriggered: root.peekVisible = false
    }
    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 16
        width: 160
        height: 40
        radius: 8
        color: "#0A1520"
        border.color: "#1A2A40"
        visible: root.peekVisible
        Text {
            anchors.centerIn: parent
            text: root.peekText
            color: "#00E5FF"
            font.pixelSize: 18
            font.family: "Courier New"
        }
    }
    Button {
        id: peekButton
        text: "Peek Time"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 16
        anchors.bottomMargin: 64
        background: Rectangle { color: "#1E2D3D"; radius: 6 }
        contentItem: Text { text: parent.text; color: "#00E5FF"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        onClicked: {
            root.peekText = Qt.formatTime(new Date(), "hh:mm:ss")
            root.peekVisible = true
            peekUpdate.restart()
            peekHide.restart()
        }
    }

    // FocusButton is defined in FocusButton.qml (same QML module)
}
