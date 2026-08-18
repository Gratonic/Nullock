// note: lets the row delegate refer to ID's declared out here (the list, the column widths).
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

    // note: -1 means "nothing picked". Deliberately NOT 0: a hardcoded 0 forces a phantom
    // selection the user never made, and means the panes' empty state can never appear.
    readonly property int selectedRow: historyList.currentIndex
    readonly property bool hasSelection: selectedRow >= 0

    /*
     *  note: column widths live in one place so the header and the rows read the SAME
     *        numbers -- written out twice they drift apart the first time one gets edited
     *  note: the url column takes whatever is left over, so long urls get the room
    */
    readonly property int numberColumnWidth:    52
    readonly property int methodColumnWidth:    82
    readonly property int statusColumnWidth:    72
    readonly property int paramsColumnWidth:    72
    readonly property int mimeColumnWidth:      88
    readonly property int timestampColumnWidth: 150
    readonly property int flagColumnWidth:      48
    readonly property int rowInset:             14

    readonly property int fixedColumnsWidth: numberColumnWidth + methodColumnWidth + statusColumnWidth + paramsColumnWidth + mimeColumnWidth + timestampColumnWidth + flagColumnWidth

    function urlColumnWidth(total_width) {
        // note: Math.max() is used to ensure the returned width is at least 80
        return Math.max(80, total_width - fixedColumnsWidth - rowInset * 2);
    }

    readonly property int rowHeight: 32

    // note: ONE hairline, used only for the panel edges and under the header. The columns
    // are defined by alignment, not by ruled lines -- 8 vertical rules per row across 400
    // rows is a lot of ink competing with the data the user is actually scanning.
    readonly property color hairline:   "#33363E"
    readonly property color headerFill: "#2A2D33"
    readonly property color zebraFill:  "#0AFFFFFF"   // ~4% white, just enough to group rows
    readonly property color textPrimary: "#EDEAE8"
    readonly property color textMuted:   "#929292"

    /*
     *  note: severity, per NullE's verdict. Contrast checked against the #2E3139 panel;
     *        info/warning/critical are all >= 4:1, comfortably over the 3:1 floor for a
     *        non-text UI mark.
     *
     *  note: COLOUR ALONE IS NOT ENOUGH HERE. Under deuteranopia (~1 in 12 men) amber and
     *        red converge -- simulated, the two sit at a 1.03 contrast ratio, i.e. the same
     *        colour. No choice of red and amber fixes that, so critical ALSO tints its whole
     *        row (see criticalTint below). That second, non-chromatic channel is what makes
     *        "is this row dangerous" answerable without hue.
     *
     *  note: "none" renders NOTHING unless the row is hovered. Most rows are clean, and a
     *        bright mark on every clean row makes the column noise instead of signal; the
     *        hover state is what keeps it discoverable as clickable.
    */
    readonly property color flagInfo:     "#5A9FBF"
    readonly property color flagWarning:  "#D89B3C"
    readonly property color flagCritical: "#E4696B"
    readonly property color flagIdle:     "#565964"
    readonly property color criticalTint: "#1AE4696B"

    function flagColor(flag_value) {
        switch (flag_value) {
            case 1:  return flagInfo;
            case 2:  return flagWarning;
            case 3:  return flagCritical;
            default: return flagIdle;
        }
    }

    /*
     *  note: status class ramp -- the single biggest scan-speed win on this screen.
     *  note: 2xx is deliberately MUTED rather than green. Most requests succeed, so
     *        colouring success spends the contrast budget on the case nobody is hunting
     *        for and makes the 4xx/5xx rows fight to be seen. Same principle as the idle
     *        flag and the GET verb: the common case recedes, the interesting case shouts.
     *  note: 4xx/5xx separate by hue for most people. For a red-green colour-blind user
     *        they do not -- which is why a row NullE rates critical is also tinted.
    */
    function statusColor(code) {
        if (code >= 500) return flagCritical;
        if (code >= 400) return flagWarning;
        if (code >= 300) return textPrimary;
        return textMuted;
    }

    // note: safe verbs recede, state-changing verbs come forward. A page load is mostly GET;
    // the POST/PUT/PATCH/DELETE rows are the ones worth finding.
    function methodColor(verb) {
        switch (verb) {
            case "GET":
            case "HEAD":
            case "OPTIONS": return textMuted;
            default:        return textPrimary;
        }
    }

    // note: a header label. Quiet uppercase micro-type -- the header should orient, not
    // compete with the rows.
    component HeaderCell: Text {
        property int cellWidth: 0
        width: cellWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        color: httpHistoryItem.textMuted
        font.pixelSize: 11
        font.weight: Font.Medium
        font.letterSpacing: 0.6
        elide: Text.ElideRight
    }

    // note: a body cell. Alignment is what defines the column now that the vertical rules
    // are gone, so it is a first-class property rather than a fixed centre.
    component Cell: Text {
        property int cellWidth: 0
        width: cellWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        color: httpHistoryItem.textPrimary
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    // note: turns raw HTTP into lightly highlighted rich text for the two panes -- header
    // NAMES in coral, HTTP/x.x in green, the first line's verb in violet.
    // note: ESCAPES FIRST. This text comes off the wire from a target under test, and these
    // panes render RichText -- an unescaped "<img src=x onerror=...>" in a response would be
    // parsed as markup by the pane itself.
    function highlight(raw_text) {
        if (!raw_text || raw_text.length === 0) {
            return "";
        }

        var escaped = raw_text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        var lines = escaped.split("\n");
        var out = [];

        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            if (i === 0) {
                out.push('<span style="color:#B084E0">' + line.replace(/(HTTP\/[0-9.]+)/g, '</span><span style="color:#48B584">$1</span><span style="color:#B084E0">') + '</span>');
                continue;
            }
            var colon = line.indexOf(":");
            if (colon > 0) {
                out.push('<span style="color:#FF6C50">' + line.substring(0, colon) + '</span><span style="color:#EDEAE8">' + line.substring(colon) + '</span>');
            } else {
                out.push('<span style="color:#EDEAE8">' + line + '</span>');
            }
        }

        return '<pre style="margin:0">' + out.join("\n") + '</pre>';
    }

    Item {
        id: httpHistoryArea
        anchors.fill: parent

        // =====================================================================
        // History table -- the top half
        // =====================================================================
        Rectangle {
            id: historyTable
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // note: 50% of the tab panel. The panes below take the rest.
            height: 0.5 * parent.height

            color: "transparent"
            border.color: httpHistoryItem.hairline
            border.width: 1
            radius: 3
            clip: true

            // ---- header ------------------------------------------------------
            Rectangle {
                id: historyHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: httpHistoryItem.rowHeight
                color: httpHistoryItem.headerFill

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: httpHistoryItem.rowInset
                    anchors.rightMargin: httpHistoryItem.rowInset

                    HeaderCell {
                        text: qsTr("#")
                        cellWidth: httpHistoryItem.numberColumnWidth
                        horizontalAlignment: Text.AlignRight
                        rightPadding: 12
                    }
                    HeaderCell { text: qsTr("METHOD"); cellWidth: httpHistoryItem.methodColumnWidth }
                    HeaderCell {
                        text: qsTr("URL")
                        cellWidth: httpHistoryItem.urlColumnWidth(historyHeader.width)
                    }
                    HeaderCell {
                        text: qsTr("STATUS")
                        cellWidth: httpHistoryItem.statusColumnWidth
                        horizontalAlignment: Text.AlignRight
                        rightPadding: 12
                    }
                    HeaderCell {
                        text: qsTr("PARAMS")
                        cellWidth: httpHistoryItem.paramsColumnWidth
                        horizontalAlignment: Text.AlignHCenter
                    }
                    HeaderCell { text: qsTr("MIME");      cellWidth: httpHistoryItem.mimeColumnWidth }
                    HeaderCell { text: qsTr("TIMESTAMP"); cellWidth: httpHistoryItem.timestampColumnWidth }
                    HeaderCell {
                        text: qsTr("FLAG")
                        cellWidth: httpHistoryItem.flagColumnWidth
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // note: the one horizontal rule that earns its place -- it separates the
                // header from the data, which is a real boundary
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: httpHistoryItem.hairline
                }
            }

            // ---- rows --------------------------------------------------------
            ListView {
                id: historyList
                anchors.top: historyHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                clip: true
                model: httpHistoryItem.historyModel
                boundsBehavior: Flickable.StopAtBounds
                reuseItems: true

                // note: nothing is selected until the user picks something
                currentIndex: -1

                // note: arrow keys move the selection, and the panes follow. Cheap to add
                // and the difference between a toy and a tool you live in.
                focus: true
                keyNavigationEnabled: true

                ScrollBar.vertical: ScrollBar {
                    id: historyScroll
                    policy: historyList.contentHeight > historyList.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    width: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 3

                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: historyScroll.pressed ? "#FF6C50" : historyScroll.hovered ? "#EDEAE8" : "#80929292"
                        opacity: historyScroll.active ? 1.0 : 0.4
                        Behavior on color   { ColorAnimation  { duration: 120 } }
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

                    readonly property bool isCritical: flag === 3

                    // note: zebra groups rows without drawing a line per row; selection and
                    // hover sit on top of it.
                    Rectangle {
                        anchors.fill: parent
                        color: historyRow.ListView.isCurrentItem ? httpHistoryItem.headerFill : rowHover.hovered ? "#8022232B" : (historyRow.index % 2 === 1) ? httpHistoryItem.zebraFill : "transparent"
                    }

                    /*
                     *  note: the SECOND channel for critical severity. Amber and red are
                     *        indistinguishable under red-green colour blindness, so a
                     *        critical row is also tinted -- that reads without any hue at all.
                    */
                    Rectangle {
                        anchors.fill: parent
                        color: httpHistoryItem.criticalTint
                        visible: historyRow.isCritical
                    }

                    // note: edge marker -- coral for the selected row, red for a critical one
                    Rectangle {
                        anchors.left: parent.left
                        width: 3
                        height: parent.height
                        visible: historyRow.ListView.isCurrentItem || historyRow.isCritical
                        color: historyRow.ListView.isCurrentItem ? "#FF6C50" : httpHistoryItem.flagCritical
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
                        anchors.leftMargin: httpHistoryItem.rowInset
                        anchors.rightMargin: httpHistoryItem.rowInset

                        Cell {
                            text: historyRow.number
                            cellWidth: httpHistoryItem.numberColumnWidth
                            horizontalAlignment: Text.AlignRight
                            rightPadding: 12
                            color: httpHistoryItem.textMuted
                            font.family: theme["typography.font_family.secondary"]
                        }
                        Cell {
                            text: historyRow.method
                            cellWidth: httpHistoryItem.methodColumnWidth
                            color: httpHistoryItem.methodColor(historyRow.method)
                            font.weight: historyRow.method === "GET" ? Font.Normal : Font.Medium
                        }
                        Cell {
                            text: historyRow.url
                            cellWidth: httpHistoryItem.urlColumnWidth(historyRow.width)
                        }
                        Cell {
                            // note: status is 0 until the response lands -- show nothing, not "0"
                            text: historyRow.status === 0 ? "" : historyRow.status
                            cellWidth: httpHistoryItem.statusColumnWidth
                            horizontalAlignment: Text.AlignRight
                            rightPadding: 12
                            color: httpHistoryItem.statusColor(historyRow.status)
                            font.family: theme["typography.font_family.secondary"]
                            font.weight: Font.Medium
                        }
                        Cell {
                            text: historyRow.hasParams ? "✓" : ""
                            cellWidth: httpHistoryItem.paramsColumnWidth
                            horizontalAlignment: Text.AlignHCenter
                            color: httpHistoryItem.textMuted
                        }
                        Cell {
                            text: historyRow.mime
                            cellWidth: httpHistoryItem.mimeColumnWidth
                            color: httpHistoryItem.textMuted
                        }
                        Cell {
                            text: historyRow.timestamp
                            cellWidth: httpHistoryItem.timestampColumnWidth
                            color: httpHistoryItem.textMuted
                            font.family: theme["typography.font_family.secondary"]
                            font.pixelSize: 11
                        }

                        // note: the flag cell is interactive -- clicking cycles NullE's
                        // verdict so the user can raise something it missed or clear
                        // something it got wrong.
                        Item {
                            width: httpHistoryItem.flagColumnWidth
                            height: parent.height

                            Text {
                                anchors.centerIn: parent
                                // note: unflagged rows show nothing until hovered. Most rows
                                // are clean; a mark on every one of them is noise, and the
                                // hover state is what keeps the control discoverable.
                                text: historyRow.flag === 0 ? "⚐" : "⚑"
                                visible: historyRow.flag !== 0 || flagHover.hovered
                                font.pixelSize: 15
                                color: httpHistoryItem.flagColor(historyRow.flag)
                            }
                            HoverHandler {
                                id: flagHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: {
                                    historyList.currentIndex = historyRow.index;
                                    if (httpHistoryItem.historyModel
                                        && httpHistoryItem.historyModel.cycleFlag)
                                        httpHistoryItem.historyModel.cycleFlag(historyRow.index);
                                }
                            }
                        }
                    }
                }
            }

            // note: a real empty state, not a grid of ruled blank rows pretending to be data
            Column {
                anchors.centerIn: parent
                spacing: 6
                visible: historyList.count === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("No traffic captured yet")
                    color: httpHistoryItem.textPrimary
                    font.family: theme["typography.font_family.primary"]
                    font.pixelSize: 15
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Requests routed through the proxy will appear here.")
                    color: httpHistoryItem.textMuted
                    font.pixelSize: 12
                }
            }
        }

        // =====================================================================
        // Request / Response panes -- the bottom half
        // =====================================================================
        Row {
            id: paneRow
            anchors.top: historyTable.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 15

            component MessagePane: Rectangle {
                // note: id rather than parent.parent chains -- those resolve to QQuickItem
                // and break the moment anything is nested differently
                id: paneRoot
                property string title: ""
                property string bodyText: ""

                color: "transparent"
                border.color: httpHistoryItem.hairline
                border.width: 1
                radius: 3
                clip: true

                Rectangle {
                    id: paneHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: httpHistoryItem.rowHeight
                    color: httpHistoryItem.headerFill

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: httpHistoryItem.rowInset
                        anchors.verticalCenter: parent.verticalCenter
                        text: paneRoot.title
                        color: httpHistoryItem.textPrimary
                        font.family: theme["typography.font_family.primary"]
                        font.pixelSize: 14
                    }

                    // note: the view selector from the plan. Only "Pretty" exists so far --
                    // Raw / Hex are the obvious next entries, which is why it is a combo
                    // rather than a label.
                    ComboBox {
                        id: viewMode
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 96
                        height: 24
                        model: [ qsTr("Pretty") ]

                        contentItem: Text {
                            leftPadding: 10
                            text: viewMode.displayText
                            color: "#48B584"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: "transparent"
                            border.color: viewMode.hovered ? "#48B584" : "#8048B584"
                            border.width: 1
                            radius: 3
                        }
                        indicator: Text {
                            x: viewMode.width - width - 9
                            y: (viewMode.height - height) / 2
                            text: "⌄"
                            color: "#48B584"
                            font.pixelSize: 13
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: httpHistoryItem.hairline
                    }
                }

                ScrollView {
                    anchors.top: paneHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    clip: true
                    visible: httpHistoryItem.hasSelection

                    TextArea {
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextArea.NoWrap
                        textFormat: TextArea.RichText
                        text: httpHistoryItem.highlight(paneRoot.bodyText)
                        font.family: theme["typography.font_family.secondary"]
                        font.pixelSize: 12
                        color: httpHistoryItem.textPrimary
                        background: Item {}
                    }
                }

                // note: with nothing selected the pane says so, rather than showing an
                // empty box the user reads as "this request had no headers"
                Text {
                    anchors.centerIn: parent
                    visible: !httpHistoryItem.hasSelection
                    text: qsTr("Select a request")
                    color: httpHistoryItem.textMuted
                    font.pixelSize: 12
                    font.family: theme["typography.font_family.primary"]
                    font.weight: Font.Medium
                }
            }

            /*
             *  note: both panes read the SELECTED ROW STRAIGHT FROM THE MODEL, not from
             *        historyList.currentItem. A ListView recycles delegates, so currentItem
             *        is null the moment the selected row scrolls out of view -- binding to it
             *        blanks both panes while the row is still perfectly well selected.
             *  note: the requestTextAt guard also covers a plain QML ListModel, which the
             *        standalone preview uses and which has no such method.
            */
            MessagePane {
                width: (paneRow.width - paneRow.spacing) / 2
                height: paneRow.height
                title: qsTr("Request")
                bodyText: (httpHistoryItem.historyModel && httpHistoryItem.historyModel.requestTextAt) ? httpHistoryItem.historyModel.requestTextAt(httpHistoryItem.selectedRow) : ""
            }

            MessagePane {
                width: (paneRow.width - paneRow.spacing) / 2
                height: paneRow.height
                title: qsTr("Response")
                bodyText: (httpHistoryItem.historyModel && httpHistoryItem.historyModel.responseTextAt) ? httpHistoryItem.historyModel.responseTextAt(httpHistoryItem.selectedRow) : ""
            }
        }
    }
}
