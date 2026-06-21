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
//         // ... your existing structure ...

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
                font.pixelSize: 14
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
                    color: hideButton.hovered ? "#4B4F59" : "#3D414B"
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
                    color: resizeButton.hovered ? "#4B4F59" : "#3D414B"
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
                    color: closeButton.hovered ? "#4B4F59" : "#3D414B"
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

                Rectangle {
                    id: controlPanel
                    width: parent.width
                    height: parent.height * 0.1
                    radius: mainArea.radius
                    color: "#25272D"
                }

                Row {
                    width: parent.width
                    height:  parent.height - controlPanel.height - parent.spacing
                    spacing: 15

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

                            StackView {
                                id: hubArea
                                anchors.fill: parent

                                Rectangle {
                                    id: overview
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: proxy
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: repeaterHub
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: intruderHub
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: extensionsHub
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: devicesHub
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }

                                Rectangle {
                                    id: workspace
                                    width: parent.width
                                    height: parent.height / 7
                                    color: "transparent"
                                }
                            }
                        }
                    }

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
                }
            }
        }
    }
}
