import QtQuick
import Quickshell.Hyprland
import "../theme"

Row {
    id: workspacesRow

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 16
    }
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            width: 24
            height: 24
            radius: 8
            color: modelData.active ? "#4a9eff" : "#333333"
            border.color: "#555555"
            border.width: 0

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }

            Text {
                text: modelData.id
                anchors.centerIn: parent
                color: modelData.active ? "#ffffff" : "#cccccc"
                font.pixelSize: 12
                font.family: "Iosevka Nerd Font"
            }
        }
    }
}
