pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    FileView {
        id: loader
        path: Qt.resolvedUrl("./config.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property QtObject theme: QtObject {
                property bool oledMode: false
                property int roundness: 16
            }
            property QtObject bar: QtObject {
                property bool bottom: false
                property bool borderless: false
                property string topLeftIcon: "spark"
                property bool showBackground: true
                property bool verbose: true
                property list<string> screenList: []
            }
            property QtObject workspaces: QtObject {
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: false
                property int showNumberDelay: 300
                property bool showNumbers: false
            }
        }
    }

    // Theme configuration
    readonly property bool oledMode: loader.adapter.theme.oledMode
    readonly property int roundness: loader.adapter.theme.roundness

    // Bar configuration
    readonly property QtObject bar: QtObject {
        readonly property bool bottom: loader.adapter.bar.bottom
        readonly property bool borderless: loader.adapter.bar.borderless
        readonly property string topLeftIcon: loader.adapter.bar.topLeftIcon
        readonly property bool showBackground: loader.adapter.bar.showBackground
        readonly property bool verbose: loader.adapter.bar.verbose
        readonly property list<string> screenList: loader.adapter.bar.screenList
    }

    // Workspace configuration
    readonly property QtObject workspaces: QtObject {
        readonly property int shown: loader.adapter.workspaces.shown
        readonly property bool showAppIcons: loader.adapter.workspaces.showAppIcons
        readonly property bool alwaysShowNumbers: loader.adapter.workspaces.alwaysShowNumbers
        readonly property int showNumberDelay: loader.adapter.workspaces.showNumberDelay
        readonly property bool showNumbers: loader.adapter.workspaces.showNumbers
    }
}