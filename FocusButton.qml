import QtQuick

Rectangle {
    id: fbRoot
    property string text: ""
    property color accent: "#00E5FF"
    signal clicked()

    height: 46
    width: fbLabel.implicitWidth + 40
    radius: 23
    color: fbMa.containsMouse
           ? Qt.rgba(accent.r, accent.g, accent.b, 0.12)
           : "transparent"
    border.color: Qt.rgba(accent.r, accent.g, accent.b,
                          fbMa.containsMouse ? 0.8 : 0.35)
    border.width: 1.5
    scale: fbMa.pressed ? 0.94 : 1.0

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80 } }

    Text {
        id: fbLabel
        anchors.centerIn: parent
        text: fbRoot.text
        font.pixelSize: 13
        font.family: "Segoe UI"
        font.weight: Font.Medium
        font.letterSpacing: 1.5
        color: fbRoot.accent
    }

    MouseArea {
        id: fbMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: fbRoot.clicked()
    }
}
