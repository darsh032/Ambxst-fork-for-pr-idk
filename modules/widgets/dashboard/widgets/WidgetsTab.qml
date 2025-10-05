import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.config

Rectangle {
    color: "transparent"
    implicitWidth: 600
    implicitHeight: 300

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.surface
            radius: Config.roundness > 4 ? Config.roundness + 4 : 0

            Text {
                anchors.centerIn: parent
                text: "Widgets"
                color: Colors.overSurfaceVariant
                font.family: Config.theme.font
                font.pixelSize: 16
                font.weight: Font.Medium
            }
        }

        NotificationHistory {
            Layout.preferredWidth: 290
            Layout.fillHeight: true
        }
    }
}
