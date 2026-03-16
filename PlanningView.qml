import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root

    // ─── Signals ───────────────────────────────────────────────────────────
    signal startSessionRequested()

    // ─── Properties exposed from parent ────────────────────────────────────
    required property var topicModel
    required property var focusCtrl

    // ─── Theme ─────────────────────────────────────────────────────────────
    color: "#0D0D11"

    // Subtle grid pattern overlay
    Canvas {
        anchors.fill: parent
        opacity: 0.04
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#00E5FF"
            ctx.lineWidth = 1
            var step = 48
            for (var x = 0; x <= width; x += step) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke()
            }
            for (var y = 0; y <= height; y += step) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 28

        // ── Header ──────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Column {
                spacing: 4
                Text {
                    text: "SYLLABUS CONQUEROR"
                    font.pixelSize: 28
                    font.family: "Segoe UI"
                    font.weight: Font.Bold
                    color: "#00E5FF"
                    style: Text.Outline
                    styleColor: "#003D44"
                }
                Text {
                    text: "Deep Focus Edition"
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                    font.letterSpacing: 3
                    color: "#607080"
                }
            }

            Item { Layout.fillWidth: true }

            Item { width: 1; height: 1 }

            // Timer configuration panel
            Rectangle {
                Layout.preferredWidth: 160
                height: 42
                radius: 8
                color: "#111820"
                border.color: "#1E2D3D"
                visible: true

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⏱"; color: "#607080" }
                    TextField {
                        id: timerMinutesInput
                        Layout.preferredWidth: 40
                        text: Math.floor(focusCtrl.totalSeconds / 60).toString()
                        font.pixelSize: 14
                        color: acceptableInput ? "#00E5FF" : "#FF4466"
                        background: Rectangle { color: "transparent" }
                        validator: IntValidator { bottom: 1; top: 1440 }
                        onEditingFinished: {
                            if (acceptableInput) {
                                var total = parseInt(text) * 60 + parseInt(timerSecondsInput.text)
                                focusCtrl.totalSeconds = total
                            }
                        }
                    }
                    Text { text: ":"; color: "#607080" }
                    TextField {
                        id: timerSecondsInput
                        Layout.preferredWidth: 30
                        text: (focusCtrl.totalSeconds % 60).toString().padStart(2, '0')
                        font.pixelSize: 14
                        color: acceptableInput ? "#00E5FF" : "#FF4466"
                        background: Rectangle { color: "transparent" }
                        validator: IntValidator { bottom: 0; top: 59 }
                        onEditingFinished: {
                            if (acceptableInput) {
                                var total = parseInt(timerMinutesInput.text) * 60 + parseInt(text)
                                focusCtrl.totalSeconds = total
                            }
                        }
                    }
                }
            }

            // Marks summary chip
            Rectangle {
                width: marksChipRow.implicitWidth + 24
                height: 42
                radius: 21
                color: "#111820"
                border.color: "#00E5FF"
                border.width: 1

                Row {
                    id: marksChipRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: topicModel.securedMarks
                        font.pixelSize: 22
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#00E5FF"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "/ " + topicModel.totalMarks + " marks"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        color: "#607080"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Item { width: 1; height: 1 }

        // Thin separator
        Rectangle { Layout.fillWidth: true; height: 1; color: "#1A2530" }

        // ── Add-topic form ───────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 88
            radius: 12
            color: "#111820"
            border.color: topicInput.activeFocus || marksInput.activeFocus ? "#00E5FF" : "#1E2D3D"
            border.width: 1
            visible: true

            Behavior on border.color { ColorAnimation { duration: 200 } }

            RowLayout {
                anchors { fill: parent; margins: 16 }
                spacing: 12

                TextField {
                    id: topicInput
                    Layout.fillWidth: true
                    placeholderText: "Topic name (e.g. Fourier Transform)"
                    font.pixelSize: 15
                    font.family: "Segoe UI"
                    color: "#E0E8F0"
                    placeholderTextColor: "#3A4A5A"
                    background: Rectangle { color: "transparent" }
                    verticalAlignment: TextInput.AlignVCenter
                    onAccepted: marksInput.forceActiveFocus()
                }

                Rectangle { width: 1; height: 40; color: "#1E2D3D" }

                ColumnLayout {
                    Layout.preferredWidth: 110
                    spacing: 2
                    TextField {
                        id: marksInput
                        Layout.fillWidth: true
                        placeholderText: "Marks"
                        text: "5"
                        font.pixelSize: 16
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: acceptableInput ? "#00E5FF" : "#FF4466"
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { color: "transparent" }
                        validator: IntValidator { bottom: 0; top: 100 }
                        onAccepted: {
                            if (acceptableInput) {
                                addBtn.clicked(null)
                            }
                        }
                    }
                    Text {
                        text: "0-100 only"
                        font.pixelSize: 10
                        color: "#FF4466"
                        visible: !marksInput.acceptableInput
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Rectangle { width: 1; height: 40; color: "#1E2D3D" }

                // Add button
                Rectangle {
                    width: 52; height: 52
                    radius: 26
                    color: addBtn.containsMouse ? "#00B8CC" : "#00E5FF"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    scale: addBtn.pressed ? 0.92 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.pixelSize: 28
                        font.weight: Font.Light
                        color: "#050A0D"
                    }

                    MouseArea {
                        id: addBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (marksInput.acceptableInput) {
                                topicModel.addTopic(topicInput.text, parseInt(marksInput.text))
                                topicInput.clear()
                                marksInput.text = "5"
                                topicInput.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }

        // ── Topic list ───────────────────────────────────────────────────
        ListView {
            id: topicList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: topicModel
            clip: true
            spacing: 8

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { radius: 3; color: "#00E5FF"; opacity: 0.5 }
            }

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 200 }
            }

            delegate: Rectangle {
                width: topicList.width
                height: 58
                radius: 10
                color: mouseArea.containsMouse ? "#131D28" : "#0F1820"
                border.color: model.topicChecked ? "#00E5FF" : "#1A2530"
                border.width: model.topicChecked ? 1.5 : 1

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14

                    // Checkbox
                    Rectangle {
                        width: 22; height: 22
                        radius: 11
                        color: model.topicChecked ? "#00E5FF" : "transparent"
                        border.color: model.topicChecked ? "#00E5FF" : "#3A5060"
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: "#050A0D"
                            visible: model.topicChecked
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: topicModel.toggleChecked(index)
                        }
                    }

                    // Topic name (Editable)
                    TextField {
                        id: topicNameEdit
                        Layout.fillWidth: true
                        text: model.topicName
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        color: model.topicChecked ? "#607080" : "#C8D8E8"
                        background: Rectangle { color: "transparent" }
                        readOnly: model.topicChecked
                        onEditingFinished: {
                            topicModel.updateTopicName(index, text)
                        }

                        // Strikethrough when checked
                        Rectangle {
                            width: topicNameEdit.contentWidth
                            height: 1
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#607080"
                            visible: model.topicChecked
                        }
                    }

                    // Marks badge (Editable)
                    TextField {
                        id: delegateMarks
                        Layout.preferredWidth: 60
                        text: model.topicMarks.toString()
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: acceptableInput ? "#00E5FF" : "#FF4466"
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        visible: !model.topicChecked
                        validator: IntValidator { bottom: 0; top: 100 }

                        onEditingFinished: {
                            if (acceptableInput) {
                                topicModel.updateTopicMarks(index, parseInt(text))
                            }
                        }

                        background: Rectangle {
                            color: "#0A1520"
                            border.color: delegateMarks.activeFocus ? "#00E5FF" : "#1E3A50"
                            radius: 14
                        }
                    }

                    // Marks badge (Static when checked)
                    Rectangle {
                        width: marksBadgeText.implicitWidth + 20
                        height: 28
                        radius: 14
                        color: "#0A1520"
                        border.color: "#1E3A50"
                        border.width: 1
                        visible: model.topicChecked

                        Text {
                            id: marksBadgeText
                            anchors.centerIn: parent
                            text: model.topicMarks + " M"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#607080"
                        }
                    }

                    // Delete button
                    Rectangle {
                        width: 30; height: 30
                        radius: 15
                        color: delBtn.containsMouse ? "#2A1018" : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 13
                            color: delBtn.containsMouse ? "#FF4466" : "#3A4A5A"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        MouseArea {
                            id: delBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: topicModel.removeTopic(index)
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: topicList.count === 0
                text: "No topics yet.\nAdd your first topic above ↑"
                font.pixelSize: 16
                font.family: "Segoe UI"
                color: "#2A3A4A"
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.6
            }
        }

        // ── Bottom bar ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Total marks pill
            Rectangle {
                height: 48
                width: totalText.implicitWidth + 32
                radius: 24
                color: "#0A1520"
                border.color: "#1E2D3D"
                border.width: 1

                Text {
                    id: totalText
                    anchors.centerIn: parent
                    text: topicList.count + " topic" + (topicList.count === 1 ? "" : "s")
                           + "  ·  " + topicModel.totalMarks + " total marks"
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                    color: "#607080"
                }
            }

            Item { Layout.fillWidth: true }

            // Clear button
            Rectangle {
                height: 48
                width: clearText.implicitWidth + 32
                radius: 24
                color: clearBtn.containsMouse ? "#1A0A10" : "transparent"
                border.color: clearBtn.containsMouse ? "#FF4466" : "#2A3A4A"
                border.width: 1
                visible: topicList.count > 0
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.pixelSize: 14
                    font.family: "Segoe UI"
                    color: clearBtn.containsMouse ? "#FF4466" : "#3A5060"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: clearBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topicModel.clearAll()
                }
            }

            // START SESSION button
            Rectangle {
                height: 56
                width: startText.implicitWidth + 48
                radius: 28
                enabled: topicList.count > 0

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: startMa.containsMouse ? "#00C8E0" : "#00E5FF" }
                    GradientStop { position: 1.0; color: startMa.containsMouse ? "#0090AA" : "#00B0CC" }
                }
                opacity: enabled ? 1.0 : 0.35
                scale: startMa.pressed ? 0.96 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

                // Glow effect
                layer.enabled: enabled
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.15
                    blurMax: 24
                    colorization: 0.8
                    colorizationColor: "#00E5FF"
                }

                Text { id: startText; anchors.centerIn: parent; text: "▶  START SESSION"; font.pixelSize: 15; font.family: "Segoe UI"; font.weight: Font.Bold; font.letterSpacing: 2; color: "#050A0D" }

                MouseArea {
                    id: startMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.startSessionRequested()
                }
            }
        }
    }
}
