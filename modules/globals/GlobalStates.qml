pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Global application states (runtime only)
    property bool notchOpen: launcherOpen || dashboardOpen || overviewOpen
    property bool overviewOpen: false
    property bool launcherOpen: false
    property bool dashboardOpen: false
    property var wallpaperManager: null
}
