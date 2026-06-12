import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    flags: Qt.FramelessWindowHint
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#AAAAAA"

        // title bar with rounded top corners
        Rectangle {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            color: "#f6f5f4"
            radius: 16
            clip: true

            // inner rectangle to square off the bottom
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "#f6f5f4"
            }
        }

        // drag area for window movement
        MouseArea {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: titleBar.bottom
            width: parent.width - 150

            onPressed: root.startSystemMove()

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "Nullock"
                color: "#333333"
                font.pixelSize: 14
                font.weight: Font.Medium
            }
        }

        // window control buttons
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: titleBar.verticalCenter
            spacing: 8
            z: 1

            // Minimize Button
            Button {
                width: 32
                height: 32
                background: Rectangle {
                    color: "#e8e7e6"
                    radius: 4
                }

                contentItem: Text {
                    text: "−"
                    font.pixelSize: 20
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.showMinimized()
            }

            // Maximize/Restore Button
            Button {
                width: 32
                height: 32
                background: Rectangle {
                    color: "#e8e7e6"
                    radius: 4
                }

                contentItem: Text {
                    text: root.visibility === Window.Maximized ? "❒" : "☐"
                    font.pixelSize: 16
                    color: "#333333"
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
                width: 32
                height: 32
                background: Rectangle {
                    color: "#e8e7e6"
                    radius: 4
                }

                contentItem: Text {
                    text: "✕"
                    font.pixelSize: 18
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.close()
            }
        }

        // content Area
        Rectangle {
            anchors.top: titleBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "content here"
                color: "#333333"
            }
        }
    }
}
