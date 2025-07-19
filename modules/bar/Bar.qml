import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../workspaces"
import "../theme"
import "../clock"
import "../systray"
import "../launcher"

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
        // bottom: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: GlobalStates.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    exclusiveZone: 40

    // Default view component - user@host text
    Component {
        id: defaultViewComponent
        Item {
            width: userHostText.implicitWidth + 24
            height: 28

            Text {
                id: userHostText
                anchors.centerIn: parent
                text: `${Quickshell.env("USER")}@${Quickshell.env("HOSTNAME")}`
                color: Colors.foreground
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }
    }

    // Launcher view component
    Component {
        id: launcherViewComponent
        Item {
            width: 480
            height: Math.min(launcherSearch.implicitHeight, 400)

            LauncherSearch {
                id: launcherSearch
                anchors.fill: parent

                onItemSelected: {
                    GlobalStates.launcherOpen = false;
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.launcherOpen = false;
                        event.accepted = true;
                    }
                }

                Component.onCompleted: {
                    clearSearch();
                    Qt.callLater(() => {
                        forceActiveFocus();
                    });
                }
            }
        }
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "transparent"

        // Left side of bar
        RowLayout {
            id: leftSide
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            Workspaces {
                bar: QtObject {
                    property var screen: panel.screen
                }
            }
        }

        // Right side of bar
        RowLayout {
            id: rightSide
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.margins: 4
            spacing: 4

            SysTray {
                bar: panel
            }

            Clock {
                id: clockComponent
            }
        }

        // Center notch
        Rectangle {
            id: notchContainer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            width: Math.max(stackContainer.width + 32, 140)
            height: Math.max(stackContainer.height + 20, 34)

            color: Colors.surface
            radius: Math.min(width / 8, height / 2)

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Item {
                id: stackContainer
                anchors.centerIn: parent
                width: stackView.currentItem ? stackView.currentItem.width : 0
                height: stackView.currentItem ? stackView.currentItem.height : 0

                StackView {
                    id: stackView
                    anchors.fill: parent
                    initialItem: defaultViewComponent

                    pushEnter: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 250
                            easing.type: Easing.OutQuart
                        }
                        PropertyAnimation {
                            property: "scale"
                            from: 0.95
                            to: 1
                            duration: 250
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                    }

                    pushExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 200
                            easing.type: Easing.OutQuart
                        }
                        PropertyAnimation {
                            property: "scale"
                            from: 1
                            to: 1.05
                            duration: 200
                            easing.type: Easing.OutQuart
                        }
                    }

                    popEnter: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 250
                            easing.type: Easing.OutQuart
                        }
                        PropertyAnimation {
                            property: "scale"
                            from: 1.05
                            to: 1
                            duration: 250
                            easing.type: Easing.OutQuart
                        }
                    }

                    popExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 200
                            easing.type: Easing.OutQuart
                        }
                        PropertyAnimation {
                            property: "scale"
                            from: 1
                            to: 0.95
                            duration: 200
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            }
        }
    }

    // Listen for launcher state changes
    Connections {
        target: GlobalStates
        function onLauncherOpenChanged() {
            if (GlobalStates.launcherOpen) {
                stackView.push(launcherViewComponent);
                Qt.callLater(() => {
                    panel.requestActivate();
                    panel.forceActiveFocus();
                });
            } else {
                if (stackView.depth > 1) {
                    stackView.pop();
                }
            }
        }
    }

    // Handle global keyboard events
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape && GlobalStates.launcherOpen) {
            GlobalStates.launcherOpen = false;
            event.accepted = true;
        }
    }
}
