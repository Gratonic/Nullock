#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QHash>
#include <QList>
#include <QString>
#include <QVariant>

#include <qqmlintegration.h>

/*
 *  note: backing model for the HTTP History table (Components/Proxy/HttpHistory.qml)
 *  note: holds every request/response the proxy has seen this session, one per row
 *  note: the columns are the ones from the original header sketch -- id, number, method,
 *        url ("UserResourceLocater"), status, params status, mime, timestamp, flag
 *  note: it is owned by AppController (C++), NOT created in QML. Two reasons: the tab is
 *        built by a Loader, which destroys its item on every tab switch and would take the
 *        capture history with it; and the proxy needs to write to it from C++.
*/

// note: what NullE concluded about a row, and what the flag colour means.
// note: the user can override any of these by clicking the flag in the table.
namespace HttpHistoryFlag {
Q_NAMESPACE
QML_ELEMENT
enum Flag {
    None     = 0,   // white  -- NullE found nothing wrong with the request
    Info     = 1,   // blue   -- informational CVE/CWE, or a leak
    Warning  = 2,   // yellow -- low/medium severity CVE/CWE
    Critical = 3,   // red    -- critical CVE/CWE
};
Q_ENUM_NS(Flag)
}

// note: one captured request/response pair, i.e. one row ("rectangle") in the table
struct HttpHistoryEntry {
    int id = 0;                       // stable identity, never reused
    int number = 0;                   // 1-based position, as the user counts them
    QString method;                   // GET, POST, ...
    QString url;                      // the "UserResourceLocater" from the original sketch
    int status = 0;                   // 0 while the response has not landed yet
    bool has_params = false;          // carries a query string and/or parameters in the body
    QString mime;                     // short display form -- PNG, TEXT, JSON, ...
    QDateTime timestamp;              // when the request left us
    int flag = HttpHistoryFlag::None;

    // note: the raw text the Request / Response panes under the table show
    QString request_text;
    QString response_text;
};

class HttpHistoryRectangleModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

    // note: lets QML show a count and decide whether to draw the empty state
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    /*
     *  note: one role per column. QML delegates read these by name.
     *  note: this is a QAbstractListModel of rows rather than a QStandardItemModel, because
     *        a role-per-column list model is what a QML delegate can bind to directly -- with
     *        QStandardItemModel the delegate has to go through column indices instead, which
     *        reads badly in the .qml
    */
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NumberRole,
        MethodRole,
        UrlRole,
        StatusRole,
        ParamsRole,
        MimeRole,
        TimestampRole,
        FlagRole,
        RequestTextRole,
        ResponseTextRole,
    };
    Q_ENUM(Roles)

    explicit HttpHistoryRectangleModel(QObject* parent = nullptr);

    // note: the three methods QML needs from any QAbstractListModel
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    /*
     *  note: the proxy calls this once per captured exchange, and it is the ONLY way rows get
     *        in -- so when the networking layer lands it only has to call this one method
     *  note: request_text / response_text are the raw HTTP the two panes under the table show
    */
    Q_INVOKABLE void addEntry(const QString method, const QString url, const int status, const bool has_params, const QString mime, const QString request_text = QString(), const QString response_text = QString(), const int flag = HttpHistoryFlag::None);

    // note: called from QML when the user clicks a row's flag to override NullE
    Q_INVOKABLE void setFlag(const int row, const int flag);

    // note: click-through order used by the table: none -> info -> warning -> critical -> none
    Q_INVOKABLE void cycleFlag(const int row);

    /*
     *  note: the Request / Response panes read the selected row through these rather than
     *        through ListView.currentItem. A ListView RECYCLES its delegates, so currentItem
     *        is null whenever the selected row is scrolled out of view -- reading the panes
     *        from it blanks them the moment the user scrolls away, which looks like data loss.
     *  note: they return an empty string for an out-of-range row rather than asserting,
     *        because QML asks during the window between a clear() and the view catching up.
    */
    Q_INVOKABLE QString requestTextAt(const int row) const;
    Q_INVOKABLE QString responseTextAt(const int row) const;

    // note: called from QML when the user clears the history
    Q_INVOKABLE void clear();

signals:
    void countChanged();

private:
    QList<HttpHistoryEntry> history_entries;

    // note: monotonic, so an id is never reused -- not even after a clear()
    int next_id = 1;
};
