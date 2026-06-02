import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: root
    title: "HTTP Proxy"
    width: 1000
    height: 600
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    
    background: Rectangle {
        color: "#2b2b2b"
        radius: 15
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // WINDOW TITLE BAR
        Rectangle {
            Layout.fillWidth: true
            height: 35
            color: "#1e1e1e"
            radius: 8
            
            // Drag Area
            MouseArea {
                anchors.fill: parent
                drag.target: root
                drag.axis: Drag.XandYAxis
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    Text {
                        text: "HTTP Proxy"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Minimize Button
                    Button {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        text: "−"
                        font.pixelSize: 20
                        onClicked: root.showMinimized()
                    }
                    
                    // Maximize Button
                    Button {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        text: "□"
                        font.pixelSize: 16
                        onClicked: {
                            if (root.visibility === Window.Maximized) {
                                root.showNormal()
                            } else {
                                root.showMaximized()
                            }
                        }
                    }
                    
                    // Close Button
                    Button {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        text: "✕"
                        font.pixelSize: 16
                        onClicked: root.close()
                    }
                }
            }
        }
        
        // MAIN CONTENT
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            
            // LEFT PANE - SIDEBAR
            Rectangle {
                Layout.fillHeight: true
                width: 180
                color: "#1e1e1e"
                radius: 10
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    Text {
                        text: "Overview"
                        color: "#888"
                        font.bold: true
                        font.pixelSize: 12
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "Dashboard"
                        onClicked: contentStack.currentIndex = 0
                    }
                    
                    Text {
                        text: "Proxy"
                        color: "#888"
                        font.bold: true
                        font.pixelSize: 12
                        Layout.topMargin: 10
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "Intercept"
                        onClicked: contentStack.currentIndex = 1
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "HTTP history"
                        onClicked: contentStack.currentIndex = 2
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "WebSocket history"
                        onClicked: contentStack.currentIndex = 3
                    }
                    
                    Text {
                        text: "Repeater Hub"
                        color: "#888"
                        font.bold: true
                        font.pixelSize: 12
                        Layout.topMargin: 10
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "Repeater"
                        onClicked: contentStack.currentIndex = 4
                    }
                    
                    Text {
                        text: "Workspace"
                        color: "#888"
                        font.bold: true
                        font.pixelSize: 12
                        Layout.topMargin: 10
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        text: "Collaborator"
                        onClicked: contentStack.currentIndex = 5
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
            
            // RIGHT PANE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#2b2b2b"
                radius: 10
                
                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    anchors.margins: 10
                    currentIndex: 0
                    
                    Rectangle { color: "#3a3a3a"; radius: 8 }
                    Rectangle { color: "#404040"; radius: 8 }
                    Rectangle { color: "#464646"; radius: 8 }
                    Rectangle { color: "#4a4a4a"; radius: 8 }
                    Rectangle { color: "#505050"; radius: 8 }
                    Rectangle { color: "#565656"; radius: 8 }
                }
            }
        }
    }
    
    // RESIZE HANDLE (bottom-right corner)
    MouseArea {
        width: 20
        height: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 15
        anchors.bottomMargin: 15
        cursorShape: Qt.SizeFDiagCursor
        
        onMouseXChanged: {
            if (pressed) {
                root.width = Math.max(400, mouseX + anchors.rightMargin)
            }
        }
        
        onMouseYChanged: {
            if (pressed) {
                root.height = Math.max(300, mouseY + anchors.bottomMargin)
            }
        }
    }
}
