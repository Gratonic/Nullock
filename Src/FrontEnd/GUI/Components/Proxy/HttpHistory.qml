import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: httpHistoryItem
    anchors.fill: parent

    Rectangle {
        id: httpHistoryArea
        anchors.fill: parent
        color: "transparent"

        // Positioner :) (should be super helpful with the httpHistory display box

        // StackView {
        //     anchors.fill: parent

        //     Rectangle {
        //         width: parent.width
        //         height: 100
        //         color: "transparent"

        //         anchors.topMargin: 15
        //     }

        //     Rectangle {
        //         anchors.bottomMargin: 15
        //         color: "transparent"

        //         ColumnLayout {
        //             Rectangle {
        //                 width: parent.width / 2
        //                 height: 100
        //             }

        //             Rectangle {
        //                 width: parent.width / 2
        //                 height: 100
        //             }
        //         }
        //     }
        // }
    }
}

// StackView {
//     anchors.fill: parent

//     anchors.leftMargin: 15
//     anchors.topMargin: 15

//     spacing: 15

//     Rectangle {
//         id: historyBar0 // history top/title bar
//         width: parent.width - 15
//         height: (0.10 * parent.height)
//         color: "green"
//     }

//     Rectangle {
//         id: testRectangle
//         width: parent.width - 15
//         height: (0.83 * parent.height) / 13
//         color: "yellow"
//     }

//     Rectangle {
//         id: historyBar14 // history bottom/footer bar
//         width: parent.width - 15
//         height: (0.07 * parent.height)
//         color: "red"
//     }
// }
