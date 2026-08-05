import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Dialogs

import "../Components/Overview/"
import "../Components/Proxy/"
import "../Components/RepeaterHub/"
import "../Components/IntruderHub/"
import "../Components/ExtensionsHub/"
import "../Components/DevicesHub/"
import "../Components/Workspace/"

// note: the App singleton (registered in nullock.cpp). Gives QML the ThemeEngine and the
// HTTP History model. NOT `import GUI` -- this file is part of the GUI module itself, and a
// module cannot import itself, which is where the "QML module not found" error came from.
import Nullock


// note: components must be defined in main app window....
// Component {
//     id: initialBlueprint
//     InitItem { }
// }

// ApplicationWindow {
//     id: root
//     visible: true
//     width: 800
//     height: 600
//     flags: Qt.FramelessWindowHint
//     color: "transparent"

//     Rectangle {
//         Rectangle {
//             id: hubPlaceholder
//             width: (parent.width - parent.spacing) * 0.8
//             height: parent.height
//             radius: 10
//             color: "transparent"

//             Loader {
//                 id: hubLoader
//                 anchors.fill: parent
//                 sourceComponent: initialBlueprint
//             }
//         }
//     }
// }

// Component {
//     id: scopeBlueprint
//     Scope {}
// }

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    flags: Qt.FramelessWindowHint
    color: "transparent"

    // note: this property is for accessing the ThemeEngine and the associated JSON theme data
    property var theme: App.ThemeEngineInstance


    // ensures the user does not make the window too small
    minimumWidth: 800
    minimumHeight: 600

    MouseArea {
        id: topEdgeWindowResizeArea
        width: root.width
        height: 5

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: 0
        y: 0
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeVerCursor

        onPressed: {
            root.startSystemResize(Qt.TopEdge)
        }
    }

    MouseArea {
        id: bottomEdgeWindowResizeArea
        width: root.width
        height: 5

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: 0
        y: root.height - 5
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeVerCursor

        onPressed: {
            root.startSystemResize(Qt.BottomEdge)
        }
    }

    MouseArea {
        id: leftEdgeWindowResizeArea
        width: 5
        height: root.height

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: 0
        y: 0
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeHorCursor

        onPressed: {
            root.startSystemResize(Qt.LeftEdge)
        }
    }

    MouseArea {
        id: rightEdgeWindowResizeArea
        width: 5
        height: root.height

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: root.width - 5
        y: 0
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeHorCursor

        onPressed: {
            root.startSystemResize(Qt.RightEdge)
        }
    }

    MouseArea {
        id: topLeftEdgeWindowResizeArea
        width: 10
        height: 10

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: 0
        y: 0
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeFDiagCursor

        onPressed: {
            root.startSystemResize(Qt.TopEdge | Qt.LeftEdge)
        }
    }

    MouseArea {
        id: topRightEdgeWindowResizeArea
        width: 10
        height: 10

        x: root.width - 10
        y: 0
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        cursorShape: Qt.SizeBDiagCursor

        onPressed: {
            root.startSystemResize(Qt.TopEdge | Qt.RightEdge)
        }
    }

    MouseArea {
        id: bottomLeftEdgeWindowResizeArea
        width: 10
        height: 10

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: 0
        y: root.height - 10
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeBDiagCursor

        onPressed: {
            root.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
        }
    }

    MouseArea {
        id: bottomRightEdgeWindowResizeArea
        width: 10
        height: 10

        // allows events to pass through this MouseArea - highly important
        propagateComposedEvents: true

        x: root.width - 10
        y: root.height - 10
        z: 10 // brings this MouseArea to the front to stop conflicts with the appBar MouseArea(s)/HoverArea(s)

        cursorShape: Qt.SizeFDiagCursor

        onPressed: {
            root.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
        }
    }

    Rectangle {
        id: mainArea
        anchors.fill: parent
        radius: 10
        color: "transparent"

        // appBar: start
        Rectangle {
            id: appBar
            height: 0.07 * parent.height // 7% of parent
            radius: mainArea.radius
            color: theme["colors.background.appBar"]

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true

            // inner rectangle to square off the bottom
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                color: theme["colors.background.appBar"]
            }
        }

        // drag area for window movement
        MouseArea {
            id: dragArea
            width: parent.width

            // allows events to pass through this MouseArea - highly important
            propagateComposedEvents: true

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: appBar.bottom

            onPressed: root.startSystemMove()
        }

        // needed for the projectButtonPopup
        FileDialog {
            id: openProjectFileDialog
            title: "Open Project"
            nameFilters: ["Project files (*.proj)", "All files (*)"]

            onAccepted: {
                // openProject(selectedFile)
            }
        }

        // for projectButton
        FileDialog {
            id: saveProjectFileDialog
            title: "Save Project As"
            nameFilters: ["Project files (*.json)", "All files (*)"]
            fileMode: FileDialog.SaveFile

            onAccepted: {
                // saveProject(selectedFile)
            }
        }

        Row {
            spacing: 7

            anchors.verticalCenter: appBar.verticalCenter

            // for nullockIcon positioning
            anchors.left: parent.left
            anchors.leftMargin: 7

            // nullock icon
            Image  {
                id: nullockIcon
                width: 30
                height: 30

                source: "qrc:/icons/nullock.png"

                anchors.verticalCenter: parent.verticalCenter
            }

            // for an alternative way to switch tabs (the normal way is to use the dashboard tab buttons in the hub areas)
            Button {
                id: nullockButton
                width: implicitWidth // dynamically calculated based on text size
                height: appBar.height

                property bool colorFlashActive: false

                contentItem: Text {
                    text: "Nullock"
                    font.pixelSize: 15
                    font.family: "georgia"
                    font.weight: Font.ExtraLight
                    color: {
                        if (nullockButton.hovered && !nullockButton.colorFlashActive) {
                            return theme["colors.buttons.nullockButton.onHoverText"]
                        } else {
                            return theme["colors.buttons.nullockButton.onColorFlashActiveText"]
                        }
                    }

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: {
                        if (nullockButton.hovered && !nullockButton.colorFlashActive) {
                            return theme["colors.buttons.nullockButton.onHover"]
                        } else if (nullockButton.colorFlashActive) {
                            return theme["colors.buttons.nullockButton.onColorFlashActive"]
                        } else {
                            return "transparent"
                        }
                    }
                }

                Popup {
                    id: nullockButtonPopupMenu
                    parent: nullockButton
                    width: implicitWidth
                    height: implicitHeight

                    x: nullockButton.width - nullockButton.width // gets the projectButton's left position (can't use projectButton.left)
                    y: nullockButton.height

                    background: Rectangle {
                        color: theme["colors.popups.nullockButtonPopupMenu.background"]

                        border.width: 1
                        border.color: theme["colors.popups.nullockButtonPopupMenu.border"]
                    }

                    contentItem: Column {
                        spacing: 0

                        MenuItem {
                            id: sitemapMenuItem
                            text: "Sitemap"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: sitemapMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: scopeMenuItem
                            text: "Scope"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: scopeMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: httpHistoryMenuItem
                            text: "HTTP History"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: httpHistoryMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: interceptMenuItem
                            text: "Intercept"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: interceptMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: repeaterMenuItem
                            text: "Repeater"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: repeaterMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: repeaterConsoleMenuItem
                            text: "Repeater Console"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: repeaterConsoleMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: intruderMenuItem
                            text: "Intruder"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: intruderMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: intruderConsoleMenuItem
                            text: "Intruder Console"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: intruderConsoleMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: extensionsMenuItem
                            text: "Extensions"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: "#8048B584"

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: extensionsMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: extensionsConsoleMenuItem
                            text: "Extensions Console"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: extensionsConsoleMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: devicesMenuItem
                            text: "Devices"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: devicesMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: devicesConsoleMenuItem
                            text: "Devices Console"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: devicesConsoleMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: reportGeneratorMenuItem
                            text: "Report Generator"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: reportGeneratorMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: notesMenuItem
                            text: "Notes"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: notesMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: themesMenuItem
                            text: "Themes"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: themesMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: settingsMenuItem
                            text: "Settings"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: settingsMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }

                onClicked: {
                    nullockButton.colorFlashActive = true
                    nullockButtonResetTimer.start()

                    nullockButtonPopupMenu.open()
                }

                Timer {
                    id: nullockButtonResetTimer
                    interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                    onTriggered: {
                        nullockButton.colorFlashActive = false
                    }
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: nullockButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            // for managing the saving the project, managing the project save file, opening post project files, and creating new project instances (new app windows)
            Button {
                id: projectButton
                width: implicitWidth // dynamically calculated based on text size
                height: appBar.height

                property bool colorFlashActive: false

                contentItem: Text {
                    text: "Project"
                    font.pixelSize: 15
                    font.family: "georgia"
                    font.weight: Font.ExtraLight
                    color: {
                        if (projectButton.hovered && !projectButton.colorFlashActive || projectButtonPopupMenu.hovered) {
                            return theme["colors.buttons.projectButton.onHoverText"]
                        } else {
                            return theme["colors.buttons.projectButton.onColorFlashActiveText"]
                        }
                    }

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: {
                        if (projectButton.hovered && !projectButton.colorFlashActive) {
                            return theme["colors.buttons.projectButton.onHover"]
                        } else if (projectButton.colorFlashActive) {
                            return theme["colors.buttons.projectButton.onColorFlashActive"]
                        } else {
                            return "transparent"
                        }
                    }
                }

                Popup {
                    id: projectButtonPopupMenu
                    parent: projectButton
                    width: implicitWidth
                    height: implicitHeight

                    x: projectButton.width - projectButton.width // gets the projectButton's left position (can't use projectButton.left)
                    y: projectButton.height

                    background: Rectangle {
                        color: theme["colors.popups.projectButtonPopupMenu.background"]

                        border.width: 1
                        border.color: theme["colors.popups.projectButtonPopupMenu.border"]
                    }

                    contentItem: Column {
                        spacing: 0

                        MenuItem {
                            id: newProjectMenuItem
                            text: "New Project"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                var component = Qt.createComponent("nullock.qml");
                                var newWindowInstance = component.createObject();

                                // note: this may trigger a warning on Wayland systems in the debugger output but it is harmless and can be ignored
                                newWindowInstance.show()

                                projectButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: newProjectMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: openProjectMenuItem
                            text: "Open"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                openProjectFileDialog.open()

                                projectButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: openProjectMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        Text {
                            id: projectButtonPopupMenuDivider
                            text: "-----------------------------"
                            color: theme["colors.primary.text"]
                        }

                        MenuItem {
                            id: saveMenuItem
                            text: "Save"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                projectButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: saveMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: saveAsMenuItem
                            text: "Save as..."

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                openProjectFileDialog.open()

                                projectButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: saveAsMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }

                onClicked: {
                    projectButton.colorFlashActive = true
                    projectButtonResetTimer.start()

                    projectButtonPopupMenu.open()
                }

                Timer {
                    id: projectButtonResetTimer
                    interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                    onTriggered: {
                        projectButton.colorFlashActive = false
                    }
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    id: projectButtonHoverHandler

                    cursorShape: projectButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Button {
                id: helpButton
                width: implicitWidth // dynamically calculated based on text size
                height: appBar.height

                property bool colorFlashActive: false

                contentItem: Text {
                    text: "Help"
                    font.pixelSize: 15
                    font.family: "georgia"
                    font.weight: Font.ExtraLight
                    color: {
                        if (helpButton.hovered && !helpButton.colorFlashActive) {
                            return theme["colors.buttons.helpButton.onHoverText"]
                        } else {
                            return theme["colors.buttons.helpButton.onColorFlashActiveText"]
                        }
                    }

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: {
                        if (helpButton.hovered && !helpButton.colorFlashActive) {
                            return theme["colors.buttons.helpButton.onHover"]
                        } else if (helpButton.colorFlashActive) {
                            return theme["colors.buttons.helpButton.onColorFlashActive"]
                        } else {
                            return "transparent"
                        }
                    }
                }

                Popup {
                    id: helpButtonPopupMenu
                    parent: helpButton
                    width: implicitWidth
                    height: implicitHeight

                    x: helpButton.width - helpButton.width // gets the projectButton's left position (can't use projectButton.left)
                    y: helpButton.height

                    background: Rectangle {
                        color: theme["colors.popups.helpButtonPopupMenu.background"]

                        border.width: 1
                        border.color: theme["colors.popups.helpButtonPopupMenu.border"]
                    }

                    contentItem: Column {
                        spacing: 0

                        MenuItem {
                            id: uiHelpMenuItem
                            text: "UI"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                helpButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: cliHelpMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: cliHelpMenuItem
                            text: "CLI"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                helpButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: cliHelpMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: extensionsApiHelpMenuItem
                            text: "Extensions API"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                helpButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: extensionsApiHelpMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }

                        MenuItem {
                            id: proxyApiHelpMenuItem
                            text: "Proxy API"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                helpButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: proxyApiHelpMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }

                onClicked: {
                    helpButton.colorFlashActive = true
                    helpButtonResetTimer.start()

                    helpButtonPopupMenu.open()
                }

                Timer {
                    id: helpButtonResetTimer
                    interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                    onTriggered: {
                        helpButton.colorFlashActive = false
                    }
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: helpButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

            }

            Button {
                id: extensionsButton
                width: implicitWidth // dynamically calculated based on text size
                height: appBar.height

                property bool colorFlashActive: false

                contentItem: Text {
                    text: "Extensions"
                    font.pixelSize: 15
                    font.family: "georgia"
                    font.weight: Font.ExtraLight
                    color: {
                        if (extensionsButton.hovered && !extensionsButton.colorFlashActive) {
                            return theme["colors.buttons.extensionsButton.onHoverText"]
                        } else {
                            return theme["colors.buttons.extensionsButton.onColorFlashActiveText"]
                        }
                    }

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: {
                        if (extensionsButton.hovered && !extensionsButton.colorFlashActive) {
                            return theme["colors.buttons.extensionsButton.onHover"]
                        } else if (extensionsButton.colorFlashActive) {
                            return theme["colors.buttons.extensionsButton.onColorFlashActive"]
                        } else {
                            return "transparent"
                        }
                    }
                }

                Popup {
                    id: extensionsButtonPopupMenu
                    parent: extensionsButton
                    width: implicitWidth
                    height: implicitHeight

                    x: extensionsButton.width - extensionsButton.width // gets the projectButton's left position (can't use projectButton.left)
                    y: extensionsButton.height

                    background: Rectangle {
                        color: theme["colors.popups.extensionsButtonPopupMenu.background"]

                        border.width: 1
                        border.color: theme["colors.popups.extensionsButtonPopupMenu.border"]
                    }

                    contentItem: Column {
                        spacing: 0

                        MenuItem {
                            id: extensionsPlaceholderMenuItem
                            text: "Extension Name"

                            palette.text: theme["colors.primary.text"]

                            palette.highlight: theme["colors.miscellaneous.title_onHover"]
                            palette.highlightedText: theme["colors.primary.onHover"]

                            onClicked: {
                                extensionsButtonPopupMenu.close()
                            }

                            // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                            HoverHandler {
                                cursorShape: extensionsPlaceholderMenuItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }

                onClicked: {
                    extensionsButton.colorFlashActive = true
                    extensionsButtonResetTimer.start()

                    extensionsButtonPopupMenu.open()
                }

                Timer {
                    id: extensionsButtonResetTimer
                    interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                    onTriggered: {
                        extensionsButton.colorFlashActive = false
                    }
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: extensionsButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

            }
        }

        // window control buttons
        Row {
            spacing: 7

            // seems to fix a weird overlap glitch (not 100% sure)
            z: 1

            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: appBar.verticalCenter

            // Hide Button
            Button {
                id: hideButton
                width: 25
                height: 25
                background: Rectangle {
                    color: theme["colors.buttons.hideButton.color"]
                    border.color: hideButton.hovered ? theme["colors.buttons.hideButton.onHover"] : theme["colors.buttons.hideButton.color"]
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: "🗕"
                    font.pixelSize: 20
                    color: theme["colors.miscellaneous.text"]
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: hideButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                onClicked: root.showMinimized()
            }

            // Resize Button
            Button {
                id: resizeButton
                width: 25
                height: 25
                background: Rectangle {
                    color: theme["colors.buttons.resizeButton.color"]
                    border.color: resizeButton.hovered ? theme["colors.buttons.resizeButton.onHover"] : theme["colors.buttons.resizeButton.color"]
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: root.visibility === Window.Maximized ? "⛶" : "□"
                    font.pixelSize: 20
                    color: theme["colors.miscellaneous.text"]
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: resizeButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                onClicked: {
                    if (root.visibility === Window.Maximized) {
                        root.showNormal()
                    } else {
                        root.showMaximized()
                    }
                }
            }

            // close Button
            Button {
                id: closeButton
                width: 25
                height: 25
                background: Rectangle {
                    color: theme["colors.buttons.closeButton.color"]
                    border.color: closeButton.hovered ? theme["colors.buttons.closeButton.onHover"] : theme["colors.buttons.closeButton.color"]
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: "🗙"
                    font.pixelSize: 20
                    color: theme["colors.miscellaneous.text"]
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                HoverHandler {
                    cursorShape: closeButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                onClicked: root.close()
            }
        }
        // appBar: end

        // content Area
        Rectangle {
            id: contentArea
            anchors.top: appBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            bottomLeftRadius: mainArea.radius
            bottomRightRadius: mainArea.radius
            color: theme["colors.background.contentArea"]

            // fixes some weird overlap glitching
            border.width: 10
            border.color: theme["colors.background.contentArea"]

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // controlPanel: start
                Rectangle {
                    id: controlPanel
                    width: parent.width
                    height: parent.height * 0.050
                    radius: mainArea.radius
                    color: "transparent"
                    // gradient: RadialGradient {
                    //     centerX: 200
                    //     centerY: 200
                    //     centerRadius: 100

                    //     GradientStop { position: 0.0; color: "#2E3139" }
                    //     GradientStop { position: 1.0; color: "#2F323A" }
                    // }

                    Rectangle {
                        anchors.fill: parent
                        radius: mainArea.radius
                        color: "transparent"

                        Text {
                            id: titleText
                            text: "NULLOCK"
                            color: theme["colors.primary.text"]
                            font.pixelSize: 24
                            font.family: "georgia" // theme["typography.font_family.primary"] // note: fix this
                            font.weight: Font.ExtraLight

                            anchors.leftMargin: 5
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // note: the controlArea is needed to position the comboBox's, buttons, and keywordSearchBox correctly
                        Rectangle {
                            id: controlArea
                            width: (parent.width - 15) * 0.8 // this is the same as the tabPanel length: (parent.width - parent.spacing) * 0.8
                            height: parent.height
                            color: "transparent"

                            anchors.right: parent.right

                            topRightRadius: mainArea.radius
                            bottomRightRadius: mainArea.radius

                            Rectangle {
                                id: controlBox
                                anchors.fill: parent
                                radius: mainArea.radius
                                color: "transparent"

                                ComboBox {
                                    id: projectComboBox
                                    width: 0.18 * parent.width
                                    height: parent.height
                                    palette.buttonText: {
                                        if (projectComboBox.hovered) {
                                            return theme["colors.comboBoxes.projectComboBox.text_onHover"]
                                        } else {
                                            return theme["colors.comboBoxes.projectComboBox.text"]
                                        }
                                    }

                                    font.pixelSize: 15
                                    font.family: "georgia"
                                    font.weight: Font.ExtraLight

                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    model: ["Project", "Option 1", "Option 2"]

                                    background: Rectangle {
                                        color: "transparent"
                                        border.color: {
                                            if (projectComboBox.hovered) {
                                                return theme["colors.comboBoxes.projectComboBox.border_onHover"]
                                            } else {
                                                return theme["colors.comboBoxes.projectComboBox.border"]
                                            }
                                        }

                                        border.width: 1
                                        radius: 3
                                    }

                                    popup.background: Rectangle {
                                        id: projectComboBoxPopup
                                        color: theme["colors.popups.projectComboBoxPopup.color"]
                                        radius: 3
                                        border.color: theme["colors.popups.projectComboBoxPopup.border"]
                                        border.width: 1
                                    }

                                    /*
                                     * note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                                     * note: needed for the HoverHandler to work for the popup items
                                    */
                                    delegate: ItemDelegate {
                                        width: projectComboBox.width
                                        highlighted: projectComboBox.highlightedIndex === index
                                        background: Rectangle {
                                            color: highlighted ? theme["colors.comboBoxes.projectComboBox.background_onHover"] : "transparent"
                                        }

                                        contentItem: Text {
                                            text: modelData
                                            color: highlighted ? theme["colors.comboBoxes.projectComboBox.text_onHover"] : theme["colors.comboBoxes.projectComboBox.text"]

                                            font.pixelSize: 15
                                            font.family: "georgia"
                                            font.weight: Font.ExtraLight
                                            font.bold: index === projectComboBox.currentIndex

                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 5
                                        }

                                        HoverHandler {
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }

                                    HoverHandler {
                                        cursorShape: projectComboBox.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }
                                }


                                Button {
                                    id: sendToRepeaterButton
                                    width: 0.18 * parent.width
                                    height: parent.height

                                    anchors.left: projectComboBox.right
                                    anchors.leftMargin: 7.5
                                    anchors.verticalCenter: parent.verticalCenter

                                    property bool colorFlashActive: false

                                    contentItem: Text {
                                        id: sendToRepeaterButtonText
                                        font.pixelSize: 15
                                        font.weight: Font.Medium

                                        color: {
                                            if (sendToRepeaterButton.hovered && !sendToRepeaterButton.colorFlashActive) {
                                                return theme["colors.secondary.onHover"]
                                            } else {
                                                return theme["colors.secondary.text"]
                                            }
                                        }

                                        text: qsTr("Repeater ⟶")

                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 3
                                        color: {
                                            if (sendToRepeaterButton.hovered && !sendToRepeaterButton.colorFlashActive) {
                                                return theme["colors.buttons.sendToRepeaterButton.onHover"]
                                            } else {
                                                return theme["colors.buttons.sendToRepeaterButton.color"]
                                            }
                                        }

                                        border.color: {
                                            if (sendToRepeaterButton.hovered && !sendToRepeaterButton.colorFlashActive) {
                                                return theme["colors.buttons.sendToRepeaterButton.border_onHover"]
                                            } else {
                                                return theme["colors.buttons.sendToRepeaterButton.border"]
                                            }
                                        }

                                        border.width: 1
                                    }

                                    onClicked: {
                                        sendToRepeaterButton.colorFlashActive = true
                                        sendToRepeaterButtonResetTimer.start()
                                    }

                                    Timer {
                                        id: sendToRepeaterButtonResetTimer
                                        interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                                        onTriggered: {
                                            sendToRepeaterButton.colorFlashActive = false
                                        }
                                    }

                                    // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                                    HoverHandler {
                                        cursorShape: sendToRepeaterButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }
                                }

                                SearchField {
                                    id: keywordSearchBox
                                    width: (0.28 * parent.width) - 30 // note: 30 is removed for margin cost (7.5 * 4)
                                    height: parent.height

                                    palette.buttonText: theme["colors.searchFields.keywordSearchBox.icon"] // icon color
                                    palette.button: theme["colors.searchFields.keywordSearchBox.icon_background_onClick"] // button click background highlight

                                    anchors.centerIn: parent

                                    contentItem: TextField {
                                        id: keywordSearchBoxTextContainer

                                        /*
                                         * note: this line keeps the TextField's text synchronized with keywordSearchBox.text so that the internal clear button will work as intended
                                         * note: when the clear button is pressed, this text will have a length of 0
                                        */
                                        text: keywordSearchBox.text

                                        // note: when this TextField's text's (linked to keywordSearchBox.text) length is 0, this placeholderText will take it's place
                                        placeholderText: "keyword"
                                        placeholderTextColor: theme["colors.searchFields.keywordSearchBox.placeholder"]

                                        color: theme["colors.searchFields.keywordSearchBox.placeholder"]
                                        font.pixelSize: 15
                                        font.weight: Font.Light

                                        // removes the source/default TextField background
                                        background: null
                                    }

                                    background: Rectangle {
                                        radius: 3
                                        color: "transparent"
                                        border.color: theme["colors.searchFields.keywordSearchBox.border"]
                                        border.width: 1
                                    }

                                    // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                                    HoverHandler {
                                        cursorShape: keywordSearchBox.searchIndicator.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }

                                    // ensures the user's cursor stays focused on the SearchBox (SearchField) when they click the clear button
                                    onClearButtonPressed: {
                                        keywordSearchBoxTextContainer.forceActiveFocus()
                                    }
                                }

                                Button {
                                    id: sendToIntruderButton
                                    width: 0.18 * parent.width
                                    height: parent.height

                                    anchors.right: scopeComboBox.left
                                    anchors.rightMargin: 7.5
                                    anchors.verticalCenter: parent.verticalCenter

                                    property bool colorFlashActive: false

                                    contentItem: Text {
                                        id: sendToIntruderButtonText
                                        font.pixelSize: 15
                                        font.weight: Font.Medium
                                        color: {
                                            if (sendToIntruderButton.hovered && !sendToIntruderButton.colorFlashActive) {
                                                return theme["colors.secondary.onHover"]
                                            } else {
                                                return theme["colors.secondary.text"]
                                            }
                                        }

                                        text: qsTr("Intruder ⟶")

                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 3
                                        color: {
                                            if (sendToIntruderButton.hovered && !sendToIntruderButton.colorFlashActive) {
                                                return theme["colors.buttons.sendToIntruderButton.onHover"]
                                            } else {
                                                return theme["colors.buttons.sendToIntruderButton.color"]
                                            }
                                        }

                                        border.color: {
                                            if (sendToIntruderButton.hovered && !sendToIntruderButton.colorFlashActive) {
                                                return theme["colors.buttons.sendToIntruderButton.border_onHover"]
                                            } else {
                                                return theme["colors.buttons.sendToIntruderButton.border"]
                                            }
                                        }

                                        border.width: 1
                                    }

                                    onClicked: {
                                        sendToIntruderButton.colorFlashActive = true
                                        sendToIntruderButtonResetTimer.start()
                                    }

                                    Timer {
                                        id: sendToIntruderButtonResetTimer
                                        interval: 75 // miliseconds (near instant to the human eye according to MIT scientists)
                                        onTriggered: {
                                            sendToIntruderButton.colorFlashActive = false
                                        }
                                    }

                                    // note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                                    HoverHandler {
                                        cursorShape: sendToIntruderButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }
                                }

                                ComboBox {
                                    id: scopeComboBox
                                    width: 0.18 * parent.width
                                    height: parent.height
                                    palette.buttonText: {
                                        if (scopeComboBox.hovered) {
                                            return theme["colors.comboBoxes.scopeComboBox.text_onHover"]
                                        } else {
                                            return theme["colors.comboBoxes.scopeComboBox.text"]
                                        }
                                    }

                                    font.pixelSize: 15
                                    font.family: "georgia"
                                    font.weight: Font.ExtraLight

                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    model: ["In-Scope", "All", "Out-Of-Scope"]

                                    background: Rectangle {
                                        color: "transparent"
                                        border.color: {
                                            if (scopeComboBox.hovered) {
                                                return theme["colors.comboBoxes.scopeComboBox.border_onHover"]
                                            } else {
                                                return theme["colors.comboBoxes.scopeComboBox.border"]
                                            }
                                        }

                                        border.width: 1
                                        radius: 3
                                    }

                                    popup.background: Rectangle {
                                        id: scopeComboBoxPopup
                                        color: theme["colors.popups.scopeComboBoxPopup.color"]
                                        radius: 3
                                        border.color: theme["colors.popups.scopeComboBoxPopup.border"]
                                        border.width: 1
                                    }

                                    /*
                                     * note: HoverHandler is used over MouseArea because it detects hovering without blocking signals and events
                                     * note: needed for the HoverHandler to work for the popup items
                                    */
                                    delegate: ItemDelegate {
                                        width: scopeComboBox.width
                                        highlighted: scopeComboBox.highlightedIndex === index
                                        background: Rectangle {
                                            color: highlighted ? theme["colors.comboBoxes.scopeComboBox.background_onHover"] : "transparent"
                                        }

                                        contentItem: Text {
                                            text: modelData
                                            color: highlighted ? theme["colors.comboBoxes.scopeComboBox.text_onHover"] : theme["colors.comboBoxes.scopeComboBox.text"]

                                            font.pixelSize: 15
                                            font.family: "georgia"
                                            font.weight: Font.ExtraLight
                                            font.bold: index === scopeComboBox.currentIndex

                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 5
                                        }

                                        HoverHandler {
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }

                                    HoverHandler {
                                        cursorShape: scopeComboBox.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    }
                                }
                            }
                        }
                    }
                }
                // controlPanel: end

                Row {
                    width: parent.width
                    height:  (parent.height - controlPanel.height) - parent.spacing
                    spacing: 15

                    // dashboardPanel: start
                    Rectangle {
                        id: dashboardPanel
                        width: (parent.width - parent.spacing) * 0.2
                        height: parent.height
                        radius: mainArea.radius

                        // note: without this there would be some white showing
                        gradient: RadialGradient {
                            centerX: 200
                            centerY: 200
                            centerRadius: 100

                            GradientStop { position: 0.0; color: "#2E3139" }
                            GradientStop { position: 1.0; color: "#2F323A" }
                        }

                        // Hubs and Buttons
                        Rectangle {
                            anchors.fill: parent
                            radius: mainArea.radius

                            gradient: RadialGradient {
                                centerX: 200
                                centerY: 200
                                centerRadius: 100

                                GradientStop { position: 0.0; color: "#2E3139" }
                                GradientStop { position: 1.0; color: "#2F323A" }
                            }

                            // ensures only one button can be seen as clicked at a time (dark background with orange text)
                            ButtonGroup {
                                id: dashboardButtonGroup
                            }

                            Column {
                                id: hubArea
                                anchors.fill: parent

                                anchors.topMargin: 10
                                anchors.bottomMargin: 10
                                anchors.leftMargin: 5
                                anchors.rightMargin: 5

                                // used to determine the height and size of the Hub Area's TextArea(s) and Button(s) (7 total: 06/27/2026)
                                property double smallContentSpace: 0.90 * (parent.height / 8)
                                property double smallExtraContentSpace: 0.10 * (parent.height / 8)

                                // used to determine the height and size of the large Hub Area's TextArea(s) and Button(s) (1 total: 06/27/2026)
                                // property double bigContentSpace: 0.90 * ((parent.height / 8)  +  (parent.height / 12))
                                // property double bigExtraContentSpace: 0.10 * ((parent.height / 8)  +  (parent.height / 12))

                                // note: a gradient is used for the button background hover/checked/pressed color in order to give theme creators/artist more control
                                Rectangle {
                                    id: overviewArea
                                    width: parent.width
                                    height: (parent.height / 8)
                                    color: "transparent"

                                    // note: when a 100% transparent color is returned (#00RRGGBB) in the Button gradients code it is done to avoid a weird color rendering issue
                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: overviewText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) + hubArea.smallExtraContentSpace

                                            text: qsTr("Overview")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: sitemapTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: sitemapTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (sitemapTabButton.checked && !sitemapTabButton.hovered || sitemapTabButton.pressed && !sitemapTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (sitemapTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Sitemap")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: sitemapTabButtonIcon.right
                                            }

                                            Image {
                                                id: sitemapTabButtonIcon
                                                width: sitemapTabButtonText.height
                                                height: sitemapTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (sitemapTabButton.hovered) {
                                                        return "qrc:/icons/sitemap_clicked_icon.png"
                                                    } else if (sitemapTabButton.checked) {
                                                        return "qrc:/icons/sitemap_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/sitemap_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (sitemapTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: scopeTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (sitemapTabButton.checked || sitemapTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (sitemapTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (sitemapTabButton.checked || sitemapTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (sitemapTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (sitemapTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: scopeTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: scopeTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (scopeTabButton.checked && !scopeTabButton.hovered || scopeTabButton.pressed && !scopeTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (scopeTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Scope")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: scopeTabButtonIcon.right
                                            }

                                            Image {
                                                id: scopeTabButtonIcon
                                                width: scopeTabButtonText.height
                                                height: scopeTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (scopeTabButton.hovered) {
                                                        return "qrc:/icons/scope_clicked_icon.svg"
                                                    } else if (scopeTabButton.checked) {
                                                        return "qrc:/icons/scope_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/scope_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (scopeTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (scopeTabButton.checked || scopeTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (scopeTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (scopeTabButton.checked || scopeTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (scopeTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (scopeTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: proxyArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: proxyText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) + hubArea.smallExtraContentSpace

                                            text: qsTr("Proxy")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: httpHistoryTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: httpHistoryTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (httpHistoryTabButton.checked && !httpHistoryTabButton.hovered || httpHistoryTabButton.pressed && !httpHistoryTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (httpHistoryTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("HTTP History")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: httpHistoryTabButtonIcon.right
                                            }

                                            Image {
                                                id: httpHistoryTabButtonIcon
                                                width: httpHistoryTabButtonText.height
                                                height: httpHistoryTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (httpHistoryTabButton.hovered) {
                                                        return "qrc:/icons/http_history_clicked_icon.svg"
                                                    } else if (httpHistoryTabButton.checked) {
                                                        return "qrc:/icons/http_history_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/http_history_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (httpHistoryTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }


                                            anchors.rightMargin: 30
                                            anchors.bottom: interceptTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (httpHistoryTabButton.checked || httpHistoryTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (httpHistoryTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (httpHistoryTabButton.checked || httpHistoryTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (httpHistoryTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (httpHistoryTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: interceptTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: interceptTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (interceptTabButton.checked && !interceptTabButton.hovered || interceptTabButton.pressed && !interceptTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (interceptTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intercept")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: interceptTabButtonIcon.right
                                            }

                                            Image {
                                                id: interceptTabButtonIcon
                                                width: interceptTabButtonText.height
                                                height: interceptTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (interceptTabButton.hovered) {
                                                        return "qrc:/icons/intercept_clicked_icon.png"
                                                    } else if (interceptTabButton.checked) {
                                                        return "qrc:/icons/intercept_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/intercept_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (interceptTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (interceptTabButton.checked || interceptTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (interceptTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (interceptTabButton.checked || interceptTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (interceptTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (interceptTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: repeaterHubArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: repeaterHubText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) + hubArea.smallExtraContentSpace

                                            text: qsTr("Repeater Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: repeaterTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: repeaterTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (repeaterTabButton.checked && !repeaterTabButton.hovered || repeaterTabButton.pressed && !repeaterTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (repeaterTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Repeater")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: repeaterTabButtonIcon.right
                                            }

                                            Image {
                                                id: repeaterTabButtonIcon
                                                width: repeaterTabButtonText.height
                                                height: repeaterTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (repeaterTabButton.hovered) {
                                                        return "qrc:/icons/repeater_clicked_icon.svg"
                                                    } else if (repeaterTabButton.checked) {
                                                        return "qrc:/icons/repeater_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/repeater_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (repeaterTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }


                                            anchors.rightMargin: 30
                                            anchors.bottom: repeaterConsoleTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (repeaterTabButton.checked || repeaterTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (repeaterTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (repeaterTabButton.checked || repeaterTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (repeaterTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (repeaterTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: repeaterConsoleTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: repeaterConsoleTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (repeaterConsoleTabButton.checked && !repeaterConsoleTabButton.hovered || repeaterConsoleTabButton.pressed && !repeaterConsoleTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (repeaterConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Repeater Console")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: repeaterConsoleTabButtonIcon.right
                                            }

                                            Image {
                                                id: repeaterConsoleTabButtonIcon
                                                width: repeaterTabButtonText.height
                                                height: repeaterTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (repeaterConsoleTabButton.hovered) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else if (repeaterConsoleTabButton.checked) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/console_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (repeaterConsoleTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (repeaterConsoleTabButton.checked || repeaterConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (repeaterConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (repeaterConsoleTabButton.checked || repeaterConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (repeaterConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (repeaterConsoleTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: intruderHubArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: intruderHubText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) * hubArea.smallExtraContentSpace

                                            text: qsTr("Intruder Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: intruderTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: intruderTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (intruderTabButton.checked && !intruderTabButton.hovered || intruderTabButton.pressed && !intruderTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (intruderTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intruder")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: intruderTabButtonIcon.right
                                            }

                                            Image {
                                                id: intruderTabButtonIcon
                                                width: intruderTabButtonText.height
                                                height: intruderTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (intruderTabButton.hovered) {
                                                        return "qrc:/icons/intruder_clicked_icon.png"
                                                    } else if (intruderTabButton.checked) {
                                                        return "qrc:/icons/intruder_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/intruder_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (intruderTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }


                                            anchors.rightMargin: 30
                                            anchors.bottom: intruderConsoleTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (intruderTabButton.checked || intruderTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (intruderTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (intruderTabButton.checked || intruderTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (intruderTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (intruderTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: intruderConsoleTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: intruderConsoleTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (intruderConsoleTabButton.checked && !intruderConsoleTabButton.hovered || intruderConsoleTabButton.pressed && !intruderConsoleTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (intruderConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intruder Console")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: intruderConsoleTabButtonIcon.right
                                            }

                                            Image {
                                                id: intruderConsoleTabButtonIcon
                                                width: repeaterTabButtonText.height
                                                height: repeaterTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (intruderConsoleTabButton.hovered) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else if (intruderConsoleTabButton.checked) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/console_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (intruderConsoleTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (intruderConsoleTabButton.checked || intruderConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (intruderConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (intruderConsoleTabButton.checked || intruderConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (intruderConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (intruderConsoleTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: extensionsHubArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: extensionsHubText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) + hubArea.smallExtraContentSpace

                                            text: qsTr("Extensions Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: extensionsTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: extensionsTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (extensionsTabButton.checked && !extensionsTabButton.hovered || extensionsTabButton.pressed && !extensionsTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (extensionsTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Extensions")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: extensionsTabButtonIcon.right
                                            }

                                            Image {
                                                id: extensionsTabButtonIcon
                                                width: extensionsTabButtonText.height
                                                height: extensionsTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (extensionsTabButton.hovered) {
                                                        return "qrc:/icons/extensions_clicked_icon.svg"
                                                    } else if (extensionsTabButton.checked) {
                                                        return "qrc:/icons/extensions_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/extensions_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (extensionsTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }


                                            anchors.rightMargin: 30
                                            anchors.bottom: extensionsConsoleTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (extensionsTabButton.checked || extensionsTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (extensionsTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (extensionsTabButton.checked || extensionsTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (extensionsTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (extensionsTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: extensionsConsoleTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: extensionsConsoleTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (extensionsConsoleTabButton.checked && !extensionsConsoleTabButton.hovered || extensionsConsoleTabButton.pressed && !extensionsConsoleTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (extensionsConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Extensions Console")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: extensionsConsoleTabButtonIcon.right
                                            }

                                            Image {
                                                id: extensionsConsoleTabButtonIcon
                                                width: extensionsTabButtonText.height
                                                height: extensionsTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (extensionsConsoleTabButton.hovered) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else if (extensionsConsoleTabButton.checked) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/console_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (extensionsConsoleTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (extensionsConsoleTabButton.checked || extensionsConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (extensionsConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (extensionsConsoleTabButton.checked || extensionsConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (extensionsConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (extensionsConsoleTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: devicesHubArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: devicesHubText
                                            width: parent.width
                                            height: (hubArea.smallContentSpace * (1/5)) + hubArea.smallExtraContentSpace

                                            text: qsTr("Devices Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: devicesTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: devicesTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (devicesTabButton.checked && !devicesTabButton.hovered || devicesTabButton.pressed && !devicesTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (devicesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Devices")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: devicesTabButtonIcon.right
                                            }

                                            Image {
                                                id: devicesTabButtonIcon
                                                width: devicesTabButtonText.height
                                                height: devicesTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (devicesTabButton.hovered) {
                                                        return "qrc:/icons/devices_clicked_icon.svg"
                                                    } else if (devicesTabButton.checked) {
                                                        return "qrc:/icons/devices_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/devices_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (devicesTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }


                                            anchors.rightMargin: 30
                                            anchors.bottom: devicesConsoleTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (devicesTabButton.checked || devicesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (devicesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (devicesTabButton.checked || devicesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (devicesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (devicesTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: devicesConsoleTabButton
                                            width: parent.width
                                            height: hubArea.smallContentSpace * (2/5)

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: devicesConsoleTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (devicesConsoleTabButton.checked && devicesConsoleTabButton.hovered || devicesConsoleTabButton.pressed && devicesConsoleTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (devicesConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Devices Console")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: devicesConsoleTabButtonIcon.right
                                            }

                                            Image {
                                                id: devicesConsoleTabButtonIcon
                                                width: devicesTabButtonText.height
                                                height: devicesTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (devicesConsoleTabButton.hovered) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else if (devicesConsoleTabButton.checked) {
                                                        return "qrc:/icons/console_clicked_icon.svg"
                                                    } else {
                                                        return "qrc:/icons/console_icon.svg"
                                                    }
                                                }

                                                opacity: {
                                                    if (devicesConsoleTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (devicesConsoleTabButton.checked || devicesConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (devicesConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (devicesConsoleTabButton.checked || devicesConsoleTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (devicesConsoleTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (devicesConsoleTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: workspaceArea
                                    width: parent.width
                                    height: extensionsHubArea.height + (extensionsTabButton.height * 2)
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: workspaceHubText
                                            width: parent.width
                                            height: extensionsTabButtonText.height

                                            text: qsTr("Workspace Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: reportGeneratorTabButton
                                            width: parent.width
                                            height: extensionsTabButton.height

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: reportGeneratorTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (reportGeneratorTabButton.checked && !reportGeneratorTabButton.hovered || reportGeneratorTabButton.pressed && !reportGeneratorTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (reportGeneratorTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Report Generator")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: reportGeneratorTabButtonIcon.right
                                            }

                                            Image {
                                                id: reportGeneratorTabButtonIcon
                                                width: reportGeneratorTabButtonText.height
                                                height: reportGeneratorTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (reportGeneratorTabButton.hovered) {
                                                        return "qrc:/icons/report_generator_clicked_icon.png"
                                                    } else if (reportGeneratorTabButton.checked) {
                                                        return "qrc:/icons/report_generator_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/report_generator_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (reportGeneratorTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: notesTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (reportGeneratorTabButton.checked || reportGeneratorTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (reportGeneratorTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (reportGeneratorTabButton.checked || reportGeneratorTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (reportGeneratorTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (reportGeneratorTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: notesTabButton
                                            width: parent.width
                                            height: extensionsTabButton.height

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: notesTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (notesTabButton.checked && !notesTabButton.hovered || notesTabButton.pressed && !notesTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (notesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Notes")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: notesTabButtonIcon.right
                                            }

                                            Image {
                                                id: notesTabButtonIcon
                                                width: notesTabButtonText.height
                                                height: notesTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (notesTabButton.hovered) {
                                                        return "qrc:/icons/notes_clicked_icon.png"
                                                    } else if (notesTabButton.checked) {
                                                        return "qrc:/icons/notes_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/notes_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (notesTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: themesTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (notesTabButton.checked || notesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (notesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (notesTabButton.checked || notesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (notesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (notesTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: themesTabButton
                                            width: parent.width
                                            height: extensionsTabButton.height

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: themesTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (themesTabButton.checked && !themesTabButton.hovered || themesTabButton.pressed && !themesTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (themesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Themes")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: themesTabButtonIcon.right
                                            }

                                            Image {
                                                id: themesTabButtonIcon
                                                width: themesTabButtonText.height
                                                height: themesTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (themesTabButton.hovered) {
                                                        return "qrc:/icons/themes_clicked_icon.png"
                                                    } else if (themesTabButton.checked) {
                                                        return "qrc:/icons/themes_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/themes_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (themesTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: settingsTabButton.top

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (themesTabButton.checked || themesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (themesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (themesTabButton.checked || themesTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (themesTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (themesTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: settingsTabButton
                                            width: parent.width
                                            height: extensionsTabButton.height

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: settingsTabButtonText
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: {
                                                    if (settingsTabButton.checked && !settingsTabButton.hovered || settingsTabButton.pressed && !settingsTabButton.hovered) {
                                                        return "#FF6C50"
                                                    } else if (settingsTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Settings")
                                                verticalAlignment: Text.AlignVCenter

                                                leftPadding: 3
                                                anchors.left: settingsTabButtonIcon.right
                                            }

                                            Image {
                                                id: settingsTabButtonIcon
                                                width: settingsTabButtonText.height
                                                height: settingsTabButtonText.height

                                                anchors.leftMargin: 13

                                                source: {
                                                    if (settingsTabButton.hovered) {
                                                        return "qrc:/icons/settings_clicked_icon.png"
                                                    } else if (settingsTabButton.checked) {
                                                        return "qrc:/icons/settings_clicked_icon.png"
                                                    } else {
                                                        return "qrc:/icons/settings_icon.png"
                                                    }
                                                }

                                                opacity: {
                                                    if (settingsTabButton.hovered) {
                                                        return 0.5
                                                    } else {
                                                        return 1.0
                                                    }
                                                }

                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            anchors.rightMargin: 30
                                            anchors.bottom: parent.bottom

                                            background: Rectangle {
                                                anchors.fill: parent
                                                radius: 3

                                                gradient: RadialGradient {
                                                    centerX: 200
                                                    centerY: 200
                                                    centerRadius: 100

                                                    GradientStop {
                                                        position: 0.0
                                                        color: {
                                                            if (settingsTabButton.checked || settingsTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (settingsTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: {
                                                            if (settingsTabButton.checked || settingsTabButton.pressed) {
                                                                return "#22232B"
                                                            } else if (settingsTabButton.hovered) {
                                                                return "#8022232B"
                                                            } else {
                                                                return "transparent"
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            HoverHandler {
                                                cursorShape: {
                                                    if (settingsTabButton.hovered) {
                                                        return Qt.PointingHandCursor
                                                    } else {
                                                        return Qt.ArrowCursor
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // dashboardPanel: end

                    // tabPanel: start
                    Rectangle {
                        id: tabPanel
                        width: (parent.width - parent.spacing) * 0.8
                        height: parent.height
                        radius: mainArea.radius
                        color: "transparent"

                        // gradient: RadialGradient {
                        //     centerX: 200
                        //     centerY: 200
                        //     centerRadius: 100

                        //     GradientStop { position: 0.0; color: "#2E3139" }
                        //     GradientStop { position: 1.0; color: "#2F323A" }
                        // }

                        Component {
                            id: defaultBlueprint

                            Rectangle {
                                radius: mainArea.radius
                                color: "transparent"
                            }
                        }

                        Component {
                            id: scopeBlueprint
                            Scope {}
                        }

                        /*
                         *  note: the history model is NOT created here, and not inside
                         *        HttpHistory.qml either -- it lives in C++ on AppController and
                         *        is reached as App.HttpHistoryModel.
                         *
                         *  note: that is what fixes the "QML module not found" error. This file
                         *        is itself PART of the GUI module, and a module cannot import
                         *        itself, so `import GUI` could never resolve here. The App
                         *        singleton (registered in nullock.cpp) is the bridge that
                         *        already works, and it only needs `import Nullock`.
                         *
                         *  note: owning it in C++ also solves two real problems. This tab is
                         *        built by a Loader, which DESTROYS its item on every tab switch
                         *        -- a model owned by QML would take the whole capture history
                         *        with it each time the user clicked away. And the proxy needs to
                         *        write to it from C++ once networking lands:
                         *            app_controller.httpHistoryModel()->addEntry(...)
                        */
                        Component {
                            id: httpHistoryBlueprint

                            HttpHistory {
                                historyModel: App.HttpHistoryModel
                            }
                        }

                        Component {
                            id: interceptBlueprint

                            Intercept {}
                        }

                        Loader {
                            id: tabLoader
                            anchors.fill: parent

                            sourceComponent: {
                                if (httpHistoryTabButton.checked) {
                                    return httpHistoryBlueprint
                                } else if (interceptTabButton.checked) {
                                    return interceptBlueprint
                                } else {
                                    return defaultBlueprint
                                }
                            }
                        }
                    }
                    // tabPanel: end
                }
            }
        }
    }
}
