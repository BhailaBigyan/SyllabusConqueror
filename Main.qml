import QtQuick
import QtQuick.Controls
import SyllabusConqueror

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "Syllabus Conqueror · Deep Focus Edition"

    color: "#0D0D11"

    // ── C++ backend instances ─────────────────────────────────────────────
    TopicModel { 
        id: topicModel 
        Component.onCompleted: setDatabaseManager(databaseManager)
    }
    FocusController  { id: focusCtrl  }
    WindowManager    { id: winMgr     }

    // ── State machine and Views Wrapper ───────────────────────────────────
    Item {
        id: viewContainer
        anchors.fill: parent

        property string appState: "planning"   // "planning" | "focus"
        state: appState

        states: [
            State {
                name: "planning"
                PropertyChanges { target: planningView; opacity: 1; scale: 1; enabled: true  }
                PropertyChanges { target: focusView;    opacity: 0; scale: 0.96; enabled: false }
            },
            State {
                name: "focus"
                PropertyChanges { target: planningView; opacity: 0; scale: 1.04; enabled: false }
                PropertyChanges { target: focusView;    opacity: 1; scale: 1; enabled: true   }
            }
        ]

        transitions: [
            Transition {
                from: "planning"; to: "focus"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: planningView; property: "opacity"; duration: 300; easing.type: Easing.InCubic }
                        NumberAnimation { target: planningView; property: "scale";   duration: 300; easing.type: Easing.InCubic }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: focusView; property: "opacity"; duration: 400; easing.type: Easing.OutCubic }
                        NumberAnimation { target: focusView; property: "scale";   duration: 400; easing.type: Easing.OutCubic }
                    }
                }
            },
            Transition {
                from: "focus"; to: "planning"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: focusView; property: "opacity"; duration: 300; easing.type: Easing.InCubic }
                        NumberAnimation { target: focusView; property: "scale";   duration: 300; easing.type: Easing.InCubic }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: planningView; property: "opacity"; duration: 400; easing.type: Easing.OutCubic }
                        NumberAnimation { target: planningView; property: "scale";   duration: 400; easing.type: Easing.OutCubic }
                    }
                }
            }
        ]

        // ── Views ─────────────────────────────────────────────────────────────
        PlanningView {
            id: planningView
            anchors.fill: parent
            topicModel: topicModel
            focusCtrl: focusCtrl

            onStartSessionRequested: {
                focusCtrl.startSession()
                winMgr.enableFocusMode(root)
                viewContainer.appState = "focus"
            }
        }

        FocusView {
            id: focusView
            anchors.fill: parent
            topicModel: topicModel
            focusController: focusCtrl
            opacity: 0
            scale: 0.96
            enabled: false

            onEndSessionRequested: {
                focusCtrl.resetSession()
                winMgr.disableFocusMode(root)
                viewContainer.appState = "planning"
            }
        }
    }

    // ── Session-finished toast ────────────────────────────────────────────
    Connections {
        target: focusCtrl
        function onSessionFinished() { finishedBanner.visible = true }
    }

    Rectangle {
        id: finishedBanner
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 24 }
        width: bannerRow.implicitWidth + 40
        height: 52
        radius: 26
        visible: false
        color: "#0D2A0A"
        border.color: "#44FF66"
        border.width: 1.5
        z: 100

        Row {
            id: bannerRow
            anchors.centerIn: parent
            spacing: 12
            Text {
                text: "🎉"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Session complete! Great work!"
                font.pixelSize: 15
                font.family: "Segoe UI"
                font.weight: Font.Medium
                color: "#44FF66"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Auto-dismiss after 5 s
        Timer {
            interval: 5000; running: finishedBanner.visible
            onTriggered: {
                finishedBanner.visible = false
                focusCtrl.resetSession()
                winMgr.disableFocusMode(root)
                viewContainer.appState = "planning"
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                finishedBanner.visible = false
                focusCtrl.resetSession()
                winMgr.disableFocusMode(root)
                viewContainer.appState = "planning"
            }
        }
    }
}
