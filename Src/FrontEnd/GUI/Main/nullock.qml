import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

import "../Components/Overview/"
import "../Components/Proxy/"
import "../Components/RepeaterHub/"
import "../Components/IntruderHub/"
import "../Components/ExtensionsHub/"
import "../Components/DevicesHub/"
import "../Components/Workspace/"


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
    Component {
        id: scopeBlueprint
        Scope {}
    }

    Component {
        id: httpHistoryBlueprint

        HttpHistory {}
    }

    id: root
    visible: true
    width: 800
    height: 600
    flags: Qt.FramelessWindowHint
    color: "transparent"

    // ensures the user does not make the window too small
    minimumWidth: 800
    minimumHeight: 600

    Rectangle {
        id: mainArea
        anchors.fill: parent
        radius: 10

        // fixes some weird white spots
        border.color: "#22232B"
        border.width: 1

        // app bar with rounded top corners
        Rectangle {
            id: appBar
            height: 0.07 * parent.height // 7% of parent
            radius: mainArea.radius
            color: "#22232B"

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
                color: "#22232B"
            }
        }

        // drag area for window movement
        MouseArea {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: appBar.bottom
            width: parent.width - 150

            onPressed: root.startSystemMove()

            // nullock Text
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "Nullock"
                color: "#48B584"
                font.pixelSize: 15
                font.weight: Font.Medium
            }
        }

        // window control buttons
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: appBar.verticalCenter
            spacing: 7
            z: 1

            // Hide Button
            Button {
                id: hideButton
                width: 25
                height: 25
                background: Rectangle {
                    color: "#22232B"
                    border.color: hideButton.hovered ? "#FF6C50" : "#22232B"
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: "🗕"
                    font.pixelSize: 20
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.showMinimized()
            }

            // Resize Button
            Button {
                id: resizeButton
                width: 25
                height: 25
                background: Rectangle {
                    color: "#22232B"
                    border.color: resizeButton.hovered ? "#48B584" : "#22232B"
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: root.visibility === Window.Maximized ? "⛶" : "□"
                    font.pixelSize: 20
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
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
                    color: "#22232B"
                    border.color: closeButton.hovered ? "#C45051" : "#22232B"
                    border.width: 1
                    radius: 180
                }

                contentItem: Text {
                    text: "🗙"
                    font.pixelSize: 20
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.close()
            }
        }

        // content Area
        Rectangle {
            id: contentArea
            anchors.top: appBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            bottomLeftRadius: mainArea.radius
            bottomRightRadius: mainArea.radius
            color: "#25272D"

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
                    // color: "transparent"
                    gradient: RadialGradient {
                        centerX: 200
                        centerY: 200
                        centerRadius: 100

                        GradientStop { position: 0.0; color: "#2E3139" }
                        GradientStop { position: 1.0; color: "#2F323A" }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: mainArea.radius
                        color: "transparent"

                        Text {
                            id: titleText
                            text: "Nullock"
                            color: "#48B584"
                            font.pixelSize: 24
                            font.weight: Font.Light

                            anchors.leftMargin: 5
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // note: the controlArea is needed to position the dropdowns, buttons, and search bar correctly
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
                                    id: projectDropdown
                                    width: 0.1625 * parent.width
                                    height: parent.height
                                    palette.buttonText: "#48B584"

                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    palette.text: "#48B584"
                                    model: ["Project", "Option 1", "Option 2"]
                                    palette.highlight: "#80929292"
                                    palette.highlightedText: "#AA48B584"

                                    background: Rectangle {
                                        color: "transparent"
                                        border.color: "#48B584"
                                        border.width: 1
                                        radius: 3
                                    }

                                    popup.background: Rectangle {
                                        color: "#22232B"
                                        radius: 3
                                        border.color: "#48B584"
                                        border.width: 1
                                    }
                                }

                                Button {
                                    id: sendToRepeaterButton
                                    width: 0.1625 * parent.width
                                    height: parent.height

                                    anchors.left: projectDropdown.right
                                    anchors.leftMargin: 7.5
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        radius: 3
                                        color: "red"
                                    }
                                }

                                Rectangle {
                                    id: searchBox
                                    width: (0.35 * parent.width) - 30 // note: 30 is removed for margin cost (7.5 * 4)
                                    height: parent.height
                                    radius: 3
                                    color: "green"

                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Button {
                                    id: sendToIntruderButton
                                    width: 0.1625 * parent.width
                                    height: parent.height

                                    anchors.right: scopeDropdown.left
                                    anchors.rightMargin: 7.5
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        radius: 3
                                        color: "red"
                                    }
                                }

                                ComboBox {
                                    id: scopeDropdown
                                    width: 0.1625 * parent.width
                                    height: parent.height
                                    palette.buttonText: "#48B584"

                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    palette.text: "#48B584"
                                    model: ["Show In-Scope", "Option 1", "Option 2"]
                                    palette.highlight: "#80929292"
                                    palette.highlightedText: "#AA48B584"

                                    background: Rectangle {
                                        color: "transparent"
                                        border.color: "#48B584"
                                        border.width: 1
                                        radius: 3
                                    }

                                    popup.background: Rectangle {
                                        color: "#22232B"
                                        radius: 3
                                        border.color: "#48B584"
                                        border.width: 1
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

                                Rectangle {
                                    id: overviewArea
                                    width: parent.width
                                    height: parent.height / 8
                                    color: "transparent"

                                    // note: when a 100% transparent color is returned (#00RRGGBB) in the Button gradients code it is done to avoid a weird color rendering issue
                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: overviewText
                                            width: parent.width
                                            height: parent.height / 3

                                            text: qsTr("Overview")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: sitemapTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: sitemapTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (sitemapTabButton.checked || sitemapTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (sitemapTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Sitemap")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: scopeTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: scopeTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (scopeTabButton.checked || scopeTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (scopeTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Scope")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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
                                            height: parent.height / 3

                                            text: qsTr("Proxy")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: httpHistoryTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: httpHistoryTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (httpHistoryTabButton.checked || httpHistoryTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (httpHistoryTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("HTTP History")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: interceptTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: interceptTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (interceptTabButton.checked || interceptTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (interceptTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intercept")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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
                                            height: parent.height / 3

                                            text: qsTr("Repeater Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: repeaterTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: repeaterTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (repeaterTabButton.checked || repeaterTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (repeaterTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Repeater")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: repeaterConsoleTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: repeaterConsoleTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (repeaterConsoleTabButton.checked || repeaterConsoleTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (repeaterConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Repeater Console")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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
                                            height: parent.height / 3

                                            text: qsTr("Intruder Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: intruderTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: intruderTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (intruderTabButton.checked || intruderTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (intruderTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intruder")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: intruderConsoleTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: intruderConsoleTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (intruderConsoleTabButton.checked || intruderConsoleTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (intruderConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Intruder Console")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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
                                            height: parent.height / 3

                                            text: qsTr("Extensions Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: extensionsTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: extensionsTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (extensionsTabButton.checked || extensionsTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (extensionsTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Extensions")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: extensionsConsoleTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: extensionsConsoleTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (extensionsConsoleTabButton.checked || extensionsConsoleTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (extensionsConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Extensions Console")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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
                                            height: parent.height / 3

                                            text: qsTr("Devices Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: devicesTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: devicesTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (devicesTabButton.checked || devicesTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (devicesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Devices")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: devicesConsoleTabButton
                                            width: parent.width
                                            height: parent.height / 3

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: devicesConsoleTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (devicesConsoleTabButton.checked || devicesConsoleTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (devicesConsoleTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Devices Console")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: workspaceArea
                                    width: parent.width
                                    height: (parent.height / 8) + (((parent.height / 8) / 3) * 2)
                                    color: "transparent"

                                    StackView {
                                        anchors.fill: parent

                                        Text {
                                            id: workspaceHubText
                                            width: parent.width
                                            height: parent.height / 5

                                            text: qsTr("Workspace Hub")
                                            color: "#929292"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Button {
                                            id: reportGeneratorTabButton
                                            width: parent.width
                                            height: parent.height / 5

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: reportGeneratorTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (reportGeneratorTabButton.checked || reportGeneratorTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (reportGeneratorTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Report Generator")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: notesTabButton
                                            width: parent.width
                                            height: parent.height / 5

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: notesTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (notesTabButton.checked || notesTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (notesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Notes")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: themesTabButton
                                            width: parent.width
                                            height: parent.height / 5

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: themesTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (themesTabButton.checked || themesTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (themesTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Themes")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Button {
                                            id: settingsTabButton
                                            width: parent.width
                                            height: parent.height / 5

                                            ButtonGroup.group: dashboardButtonGroup
                                            checkable: true

                                            contentItem: Text {
                                                id: settingsTabButtonText
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: {
                                                    if (settingsTabButton.checked || settingsTabButton.pressed) {
                                                        return "#FF6C50"
                                                    } else if (settingsTabButton.hovered) {
                                                        return "#80FF6C50"
                                                    } else {
                                                        return "#EDEAE8"
                                                    }
                                                }

                                                text: qsTr("Settings")

                                                leftPadding: 10
                                                horizontalAlignment: Text.AlignLeft
                                                verticalAlignment: Text.AlignVCenter
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
                                                                return "#002E3139"
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
                                                                return "#002F323A"
                                                            }
                                                        }
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

                        gradient: RadialGradient {
                            centerX: 200
                            centerY: 200
                            centerRadius: 100

                            GradientStop { position: 0.0; color: "#2E3139" }
                            GradientStop { position: 1.0; color: "#2F323A" }
                        }

                        Loader {
                            id: tabLoader
                            anchors.fill: parent

                            sourceComponent: httpHistoryBlueprint
                        }
                    }
                    // tabPanel: end
                }
            }
        }
    }
}
