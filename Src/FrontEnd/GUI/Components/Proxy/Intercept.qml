import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: interceptItem

    Rectangle {
        id: interceptArea
        anchors.fill: parent
        radius: mainArea.radius
        color: "transparent"

        // Positioner :) (should be super helpful with the httpHistory display box

        Column {
            anchors.fill: parent
            spacing: 15

            Rectangle {
                id: interceptBox
                width: parent.width
                height: (0.50 * parent.height) - 7.5
                radius: mainArea.radius
                color: "transparent"

                border.width: 1
                border.color: "#929292"

                Text {
                    anchors.centerIn: parent

                    text: qsTr("[HTTP History]")
                    color: "#929292"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                id: intercpetControlBox
                width: parent.width
                height: (0.50 * parent.height) - 7.5
                radius: mainArea.radius
                color: "transparent"

                border.width: 1
                border.color: "#929292"

                Text {
                    anchors.centerIn: parent

                    text: qsTr("[Intercept Controls]")
                    color: "#929292"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }
    }
}