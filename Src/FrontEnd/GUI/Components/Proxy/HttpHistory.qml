// note: lets the row delegate refer to ids declared out here (the list, the column widths).
// Without it qmllint flags every one of those as an unqualified access.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: httpHistoryItem
    anchors.fill: parent

    /*
     *  note: the model is handed IN, it is not created here. The tab is built by a Loader,
     *        and a Loader destroys and recreates its item every time the user switches away
     *        and back -- a model owned by this file would take the whole capture history with
     *        it each time. nullock.qml passes App.HttpHistoryModel, which lives in C++ on
     *        AppController and outlives the tab.
     *  note: keeping the model out of here also means this file needs no C++ import, so it
     *        can be opened and previewed on its own with a plain ListModel.
    */
    property var historyModel: null

    // note: the row the two panes at the bottom are showing
    readonly property int selectedRow: historyList.currentIndex

    /*
     *  note: column widths live in one place so the title bar, the row delegate and the empty
     *        grid behind them all read the SAME numbers -- written out three times they drift
     *        apart the first time one gets edited
     *  note: the url column takes whatever is left over, so long urls get the room
    */
    readonly property int numberColumnWidth:    56
    readonly property int methodColumnWidth:    92
    readonly property int statusColumnWidth:    96
    readonly property int paramsColumnWidth:    96
    readonly property int mimeColumnWidth:      96
    readonly property int timestampColumnWidth: 150
    readonly property int flagColumnWidth:      56

    readonly property int fixedColumnsWidth: numberColumnWidth + methodColumnWidth
                                           + statusColumnWidth + paramsColumnWidth
                                           + mimeColumnWidth + timestampColumnWidth
                                           + flagColumnWidth

    // note: how much room the url column has left after the fixed ones have taken theirs
    function urlColumnWidth(total_width) {
        return Math.max(80, total_width - fixedColumnsWidth);
    }

    readonly property int rowHeight: 34

    // note: the grid lines that make the table read as a table. Deliberately dim -- they
    // should separate cells without competing with the text.
    readonly property color gridLine:   "#3A3D45"
    readonly property color headerFill: "#22232B"
    readonly property color rowFill:    "#8022232B"

    /*
     *  note: flag colours, per NullE's verdict on the request:
     *          none     white   -- nothing found
     *          info     blue    -- informational CVE/CWE, or a leak
     *          warning  yellow  -- low/medium severity
     *          critical red     -- critical severity
     *  note: the user can click any flag to override NullE -- see the TapHandler below.
     *  note: white and red come from the existing palette (#EDEAE8, #C34143). Blue and
     *        yellow are NEW -- there is no blue or yellow anywhere else in nullock.qml, so
     *        these two are a judgement call and easy to swap.
    */
    function flagColor(flag_value) {
        switch (flag_value) {
        case 1:  return "#4A90D9";   // info
        case 2:  return "#E5B341";   // warning
        case 3:  return "#C34143";   // critical
        default: return "#EDEAE8";   // none
        }
    }

    // note: a title-bar cell. Centred, matching the plan.
    component HeaderCell: Item {
        property string label: ""
        property int cellWidth: 0
        width: cellWidth
        height: parent.height

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: "#EDEAE8"
            font.pixelSize: 14
            font.weight: Font.Medium
        }
        // note: right-hand separator, so the header reads as columns
        Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: httpHistoryItem.gridLine
        }
    }

    // note: a body cell. Centred like the header, with the same right separator so the
    // column edges line up exactly between header, rows and the empty grid below them.
    component Cell: Item {
        property string label: ""
        property int cellWidth: 0
        property color textColor: "#EDEAE8"
        property bool elide: false
        width: cellWidth
        height: parent.height

        Text {
            anchors.centerIn: parent
            width: parent.width - 12
            horizontalAlignment: Text.AlignHCenter
            text: parent.label
            color: parent.textColor
            font.pixelSize: 13
            elide: parent.elide ? Text.ElideRight : Text.ElideNone
        }
        Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: httpHistoryItem.gridLine
        }
    }

    // note: turns raw HTTP into lightly highlighted rich text for the two panes -- header
    // NAMES in coral, the first line's method/version in green, values left plain. Escapes
    // first: the text is attacker-controlled, and these panes are the whole point of the tab.
    function highlight(raw_text) {
        if (!raw_text || raw_text.length === 0)
            return "";

        var escaped = raw_text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        var lines = escaped.split("\n");
        var out = [];

        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            if (i === 0) {
                // request line or status line -- colour the verb/version tokens
                out.push('<span style="color:#B084E0">'
                         + line.replace(/(HTTP\/[0-9.]+)/g,
                                        '</span><span style="color:#48B584">$1</span><span style="color:#B084E0">')
                         + '</span>');
                continue;
            }
            var colon = line.indexOf(":");
            if (colon > 0) {
                out.push('<span style="color:#FF6C50">' + line.substring(0, colon)
                         + '</span><span style="color:#EDEAE8">' + line.substring(colon) + '</span>');
            } else {
                out.push('<span style="color:#EDEAE8">' + line + '</span>');
            }
        }
        return '<pre style="margin:0">' + out.join("\n") + '</pre>';
    }

    Item {
        id: httpHistoryArea
        anchors.fill: parent
        anchors.margins: 15

        // =====================================================================
        // HTTP history table -- the top half of the panel
        // =====================================================================
        Rectangle {
            id: historyTable
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // note: 50% of the tab panel, as asked. The panes below take the rest.
            height: parent.height * 0.5

            color: "transparent"
            border.color: httpHistoryItem.gridLine
            border.width: 1
            radius: 3
            clip: true

            // ---- title bar --------------------------------------------------
            Rectangle {
                id: historyHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: httpHistoryItem.rowHeight + 8
                color: httpHistoryItem.headerFill
                // note: square the bottom corners so the header sits flush on the grid
                radius: 3

                Row {
                    anchors.fill: parent

                    HeaderCell { label: qsTr("#");        cellWidth: httpHistoryItem.numberColumnWidth }
                    HeaderCell { label: qsTr("Method");   cellWidth: httpHistoryItem.methodColumnWidth }
                    HeaderCell {
                        label: qsTr("User Resource Locater (URL)")
                        cellWidth: httpHistoryItem.urlColumnWidth(historyHeader.width)
                    }
                    HeaderCell { label: qsTr("Status");    cellWidth: httpHistoryItem.statusColumnWidth }
                    HeaderCell { label: qsTr("Params");    cellWidth: httpHistoryItem.paramsColumnWidth }
                    HeaderCell { label: qsTr("MIME");      cellWidth: httpHistoryItem.mimeColumnWidth }
                    HeaderCell { label: qsTr("Timestamp"); cellWidth: httpHistoryItem.timestampColumnWidth }

                    // note: the flag column's header is the flag glyph itself, per the plan
                    Item {
                        width: httpHistoryItem.flagColumnWidth
                        height: parent.height
                        Text {
                            anchors.centerIn: parent
                            text: "⚑"
                            color: "#EDEAE8"
                            font.pixelSize: 15
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: httpHistoryItem.gridLine
                }
            }

            // ---- empty grid behind the rows ---------------------------------
            // note: the plan draws the full grid even where there is no data yet, so the
            // table reads as a table on an empty session instead of as a blank box.
            Column {
                id: emptyGrid
                anchors.top: historyHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Repeater {
                    model: Math.ceil(emptyGrid.height / httpHistoryItem.rowHeight)
                    delegate: Item {
                        required property int index
                        width: emptyGrid.width
                        height: httpHistoryItem.rowHeight

                        Row {
                            anchors.fill: parent
                            Repeater {
                                model: [ httpHistoryItem.numberColumnWidth,
                                         httpHistoryItem.methodColumnWidth,
                                         httpHistoryItem.urlColumnWidth(emptyGrid.width),
                                         httpHistoryItem.statusColumnWidth,
                                         httpHistoryItem.paramsColumnWidth,
                                         httpHistoryItem.mimeColumnWidth,
                                         httpHistoryItem.timestampColumnWidth,
                                         httpHistoryItem.flagColumnWidth ]
                                delegate: Item {
                                    required property int modelData
                                    width: modelData
                                    height: httpHistoryItem.rowHeight
                                    Rectangle {
                                        anchors.right: parent.right
                                        width: 1
                                        height: parent.height
                                        color: httpHistoryItem.gridLine
                                    }
                                }
                            }
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: httpHistoryItem.gridLine
                        }
                    }
                }
            }

            // ---- the rows ---------------------------------------------------
            ListView {
                id: historyList
                anchors.top: historyHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                clip: true
                model: httpHistoryItem.historyModel
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds

                /*
                 *  note: a thin overlay handle rather than a full gutter with arrows -- it
                 *        only appears while it is needed, so an empty or short history has
                 *        no chrome at all. Rounded and inset to match the panel's radius.
                */
                ScrollBar.vertical: ScrollBar {
                    id: historyScroll
                    policy: historyList.contentHeight > historyList.height
                                ? ScrollBar.AsNeeded
                                : ScrollBar.AlwaysOff
                    width: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 3

                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: historyScroll.pressed ? "#FF6C50"
                             : historyScroll.hovered ? "#EDEAE8"
                             : "#80929292"
                        opacity: historyScroll.active ? 1.0 : 0.45
                        Behavior on color   { ColorAnimation { duration: 120 } }
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                    background: Item {}
                }

                delegate: Item {
                    id: historyRow
                    width: historyList.width
                    height: httpHistoryItem.rowHeight

                    required property int index
                    required property int number
                    required property string method
                    required property string url
                    required property int status
                    required property bool hasParams
                    required property string mime
                    required property string timestamp
                    required property int flag

                    // note: selected / hovered / idle
                    Rectangle {
                        anchors.fill: parent
                        color: historyRow.ListView.isCurrentItem ? httpHistoryItem.headerFill
                             : rowHover.hovered                  ? httpHistoryItem.rowFill
                             : "transparent"
                    }

                    // note: the coral edge marker on the selected row, straight from the plan
                    Rectangle {
                        anchors.left: parent.left
                        width: 3
                        height: parent.height
                        color: "#FF6C50"
                        visible: historyRow.ListView.isCurrentItem
                    }

                    HoverHandler {
                        id: rowHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: historyList.currentIndex = historyRow.index
                    }

                    Row {
                        anchors.fill: parent

                        Cell {
                            label: historyRow.number
                            cellWidth: httpHistoryItem.numberColumnWidth
                        }
                        Cell {
                            label: historyRow.method
                            cellWidth: httpHistoryItem.methodColumnWidth
                        }
                        Cell {
                            label: historyRow.url
                            cellWidth: httpHistoryItem.urlColumnWidth(historyRow.width)
                            elide: true
                        }
                        Cell {
                            // note: status is 0 until the response lands -- show nothing, not "0"
                            label: historyRow.status === 0 ? "" : historyRow.status
                            cellWidth: httpHistoryItem.statusColumnWidth
                        }
                        Cell {
                            label: historyRow.hasParams ? "✓" : ""
                            cellWidth: httpHistoryItem.paramsColumnWidth
                        }
                        Cell {
                            label: historyRow.mime
                            cellWidth: httpHistoryItem.mimeColumnWidth
                            elide: true
                        }
                        Cell {
                            label: historyRow.timestamp
                            cellWidth: httpHistoryItem.timestampColumnWidth
                            elide: true
                        }

                        // note: the flag cell is interactive -- clicking it cycles NullE's
                        // verdict, so the user can raise something NullE missed or clear
                        // something it got wrong.
                        Item {
                            width: httpHistoryItem.flagColumnWidth
                            height: parent.height

                            Text {
                                anchors.centerIn: parent
                                text: "⚑"
                                font.pixelSize: 16
                                color: httpHistoryItem.flagColor(historyRow.flag)
                            }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    historyList.currentIndex = historyRow.index;
                                    if (httpHistoryItem.historyModel
                                        && httpHistoryItem.historyModel.cycleFlag)
                                        httpHistoryItem.historyModel.cycleFlag(historyRow.index);
                                }
                            }
                            Rectangle {
                                anchors.right: parent.right
                                width: 1
                                height: parent.height
                                color: httpHistoryItem.gridLine
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: httpHistoryItem.gridLine
                    }
                }
            }
        }

        // =====================================================================
        // Request / Response panes -- the bottom half
        // =====================================================================
        Row {
            id: paneRow
            anchors.top: historyTable.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 12

            // note: one pane. Both halves are identical apart from their title and body,
            // so they are one inline component rather than two near-copies.
            component MessagePane: Rectangle {
                // note: id rather than parent.parent chains -- those resolve to QQuickItem
                // and break the moment anything is nested differently
                id: paneRoot
                property string title: ""
                property string bodyText: ""

                color: "transparent"
                border.color: httpHistoryItem.gridLine
                border.width: 1
                radius: 3
                clip: true

                Rectangle {
                    id: paneHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: httpHistoryItem.rowHeight + 8
                    color: httpHistoryItem.headerFill

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 13
                        anchors.verticalCenter: parent.verticalCenter
                        text: paneRoot.title
                        color: "#EDEAE8"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    // note: the view selector from the plan. Only "Pretty" exists so far --
                    // Raw / Hex are the obvious next entries, which is why it is a combo
                    // rather than a label.
                    ComboBox {
                        id: viewMode
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 110
                        height: 26
                        model: [ qsTr("Pretty") ]

                        contentItem: Text {
                            leftPadding: 10
                            text: viewMode.displayText
                            color: "#48B584"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: "transparent"
                            border.color: "#48B584"
                            border.width: 1
                            radius: 3
                        }
                        indicator: Text {
                            x: viewMode.width - width - 10
                            y: (viewMode.height - height) / 2
                            text: "⌄"
                            color: "#48B584"
                            font.pixelSize: 14
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: httpHistoryItem.gridLine
                    }
                }

                ScrollView {
                    anchors.top: paneHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    clip: true

                    TextArea {
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextArea.NoWrap
                        textFormat: TextArea.RichText
                        text: httpHistoryItem.highlight(paneRoot.bodyText)
                        font.family: "monospace"
                        font.pixelSize: 13
                        color: "#EDEAE8"
                        background: Item {}
                    }
                }
            }

            /*
             *  note: both panes read the SELECTED ROW STRAIGHT FROM THE MODEL, not from
             *        historyList.currentItem. A ListView recycles delegates, so currentItem
             *        is null the moment the selected row scrolls out of view -- binding to it
             *        blanks both panes while the row is still perfectly well selected.
             *  note: the guard also covers a plain QML ListModel (used by the standalone
             *        preview), which has no requestTextAt.
            */
            MessagePane {
                width: (paneRow.width - paneRow.spacing) / 2
                height: paneRow.height
                title: qsTr("Request")
                bodyText: (httpHistoryItem.historyModel
                           && httpHistoryItem.historyModel.requestTextAt)
                              ? httpHistoryItem.historyModel.requestTextAt(httpHistoryItem.selectedRow)
                              : ""
            }

            MessagePane {
                width: (paneRow.width - paneRow.spacing) / 2
                height: paneRow.height
                title: qsTr("Response")
                bodyText: (httpHistoryItem.historyModel
                           && httpHistoryItem.historyModel.responseTextAt)
                              ? httpHistoryItem.historyModel.responseTextAt(httpHistoryItem.selectedRow)
                              : ""
            }
        }
    }
}
