import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../workspaces/"
import "../theme"

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 40
    margins.top: 0
    margins.left: 0
    margins.right: 0

    Rectangle {
        id: bar
        anchors.fill: parent
        color: Colors.background
        radius: 0
        border.color: "#333333"
        border.width: 0

        Workspaces {}

        Text {
            visible: Hyprland.workspaces.length === 0
            text: "No workspaces"
            color: "#ffffff"
            font.pixelSize: 12
        }
    }

    Text {
        id: timeDisplay
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 16
        }

        property string currentTime: ""

        text: currentTime
        color: "#ffffff"
        font.pixelSize: 12
        font.family: "Iosevka Nerd Font"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                var now = new Date();
                timeDisplay.currentTime = Qt.formatDateTime(now, "hh:mm:ss");
            }
        }
    }
}
