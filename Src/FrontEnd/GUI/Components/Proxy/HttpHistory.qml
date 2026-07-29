// note: lets the row delegate refer to ids declared out here (the list, the column widths).
// Without it qmllint flags every one of those as an unqualified access.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: httpHistoryItem
    anchors.fill: parent

    /*
     *  note: the model is handed IN, it is not created here on purpose. The tab is built by a
     *        Loader (nullock.qml), and a Loader destroys and recreates its item every time the
     *        user switches away and back -- so a model owned by this file would take the whole
     *        capture history with it each time. It is owned by nullock.qml instead, which
     *        outlives the tab.
     *  note: this also means the file needs no C++ import, so it can be opened on its own.
    */
    property var historyModel: null

    /*
     *  note: column widths live here so the title bar and the row delegate read the SAME
     *        numbers -- written out twice they drift apart the first time one gets edited
     *  note: the url column takes whatever is left over, so long urls get the room
    */
    readonly property int numberColumnWidth:    44
    readonly property int methodColumnWidth:    64
    readonly property int statusColumnWidth:    52
    readonly property int paramsColumnWidth:    72
    readonly property int mimeColumnWidth:      96
    readonly property int timestampColumnWidth: 120
    readonly property int flagColumnWidth:      40
    readonly property int rowLeftInset:         13

    readonly property int fixedColumnsWidth: numberColumnWidth + methodColumnWidth
                                           + statusColumnWidth + paramsColumnWidth
                                           + mimeColumnWidth + timestampColumnWidth
                                           + flagColumnWidth

    // note: how much room the url column has left after the fixed ones have taken theirs
    function urlColumnWidth(total_width) {
        return Math.max(0, total_width - rowLeftInset - fixedColumnsWidth);
    }

    // note: a title-bar cell. Same grey/size/weight as the "Overview" section label.
    component HeaderCell: Text {
        property int cellWidth: 0

        width: cellWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter

        color: "#929292"
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    // note: a body cell. Muted columns take the same grey the placeholder text uses.
    component Cell: Text {
        property int cellWidth: 0
        property bool muted: false

        width: cellWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter

        color: muted ? "#929292" : "#EDEAE8"
        font.pixelSize: 11
        font.weight: Font.Medium
    }

    Rectangle {
        id: httpHistoryArea
        anchors.fill: parent
        // note: transparent so the tabPanel's radial gradient shows through, as the stub had it
        color: "transparent"

        anchors.margins: 15

        /*
         *  note: the three bars below keep the proportions from the original scaffolding that
         *        was commented out in this file -- a ~10% title bar, a body, a ~7% footer bar
        */
        Rectangle {
            id: historyBar0 // history top/title bar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 0.10 * parent.height

            color: "#22232B"
            radius: 3

            Row {
                anchors.fill: parent
                anchors.leftMargin: httpHistoryItem.rowLeftInset

                HeaderCell { text: qsTr("#");      cellWidth: httpHistoryItem.numberColumnWidth }
                HeaderCell { text: qsTr("Method"); cellWidth: httpHistoryItem.methodColumnWidth }
                HeaderCell {
                    text: qsTr("URL")
                    cellWidth: httpHistoryItem.urlColumnWidth(historyBar0.width)
                }
                HeaderCell { text: qsTr("Status"); cellWidth: httpHistoryItem.statusColumnWidth }
                HeaderCell { text: qsTr("Params"); cellWidth: httpHistoryItem.paramsColumnWidth }
                HeaderCell { text: qsTr("MIME");   cellWidth: httpHistoryItem.mimeColumnWidth }
                HeaderCell { text: qsTr("Time");   cellWidth: httpHistoryItem.timestampColumnWidth }
                HeaderCell { text: qsTr("Flag");   cellWidth: httpHistoryItem.flagColumnWidth }
            }
        }

        ListView {
            id: httpHistoryList
            anchors.top: historyBar0.bottom
            anchors.bottom: historyBar14.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            clip: true
            model: httpHistoryItem.historyModel

            // note: sized for the 13 visible rows the original scaffolding laid out
            readonly property int rowHeight: Math.max(18, (0.83 * httpHistoryArea.height) / 13)

            ScrollBar.vertical: ScrollBar {
                policy: httpHistoryList.contentHeight > httpHistoryList.height
                            ? ScrollBar.AlwaysOn
                            : ScrollBar.AlwaysOff
                width: 6

                contentItem: Rectangle {
                    radius: 3
                    color: "#80929292"
                }
            }

            delegate: Item {
                id: historyRow
                width: httpHistoryList.width
                height: httpHistoryList.rowHeight

                required property int index
                required property int number
                required property string method
                required property string url
                required property int status
                required property bool hasParams
                required property string mime
                required property string timestamp
                required property bool flagged

                /*
                 *  note: selected / hovered / idle -- the same three-state fill the tab buttons
                 *        in nullock.qml use: solid #22232B when picked, the 50%-alpha
                 *        #8022232B on hover, nothing otherwise
                */
                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: historyRow.ListView.isCurrentItem ? "#22232B"
                         : rowHoverHandler.hovered           ? "#8022232B"
                         : "transparent"
                }

                HoverHandler {
                    id: rowHoverHandler
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: httpHistoryList.currentIndex = historyRow.index
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: httpHistoryItem.rowLeftInset

                    Cell {
                        text: historyRow.number
                        cellWidth: httpHistoryItem.numberColumnWidth
                    }
                    Cell {
                        text: historyRow.method
                        cellWidth: httpHistoryItem.methodColumnWidth
                    }
                    Cell {
                        text: historyRow.url
                        cellWidth: httpHistoryItem.urlColumnWidth(historyRow.width)
                        elide: Text.ElideRight
                    }
                    Cell {
                        // note: status is 0 until the response lands -- show nothing, not "0"
                        text: historyRow.status === 0 ? "" : historyRow.status
                        cellWidth: httpHistoryItem.statusColumnWidth
                    }
                    Cell {
                        text: historyRow.hasParams ? qsTr("yes") : ""
                        cellWidth: httpHistoryItem.paramsColumnWidth
                        muted: true
                    }
                    Cell {
                        text: historyRow.mime
                        cellWidth: httpHistoryItem.mimeColumnWidth
                        muted: true
                        elide: Text.ElideRight
                    }
                    Cell {
                        text: historyRow.timestamp
                        cellWidth: httpHistoryItem.timestampColumnWidth
                        muted: true
                    }
                    Cell {
                        // note: the flag is a triage marker, so it takes the same accent the
                        // selected nav rows use
                        text: historyRow.flagged ? "⚑" : ""
                        cellWidth: httpHistoryItem.flagColumnWidth
                        color: "#FF6C50"
                    }
                }
            }
        }

        // note: nothing captured yet -- say so, rather than leaving the panel looking broken
        Text {
            anchors.centerIn: httpHistoryList
            visible: httpHistoryList.count === 0

            text: qsTr("No HTTP history yet — proxied traffic will appear here.")
            color: "#929292"
            font.family: "georgia"
            font.pixelSize: 15
            font.weight: Font.Light
        }

        Rectangle {
            id: historyBar14 // history bottom/footer bar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 0.07 * parent.height

            color: "#22232B"
            radius: 3

            Text {
                anchors.left: parent.left
                anchors.leftMargin: httpHistoryItem.rowLeftInset
                anchors.verticalCenter: parent.verticalCenter

                text: httpHistoryList.count === 1
                          ? qsTr("1 request")
                          : qsTr("%1 requests").arg(httpHistoryList.count)
                color: "#929292"
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }
    }
}
