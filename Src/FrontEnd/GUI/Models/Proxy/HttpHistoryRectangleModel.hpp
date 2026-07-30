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
 *  note: the columns are the ones sketched in the original header comment -- id, number,
 *        method, url ("UserResourceLocater"), status, params status, mime, timestamp, flag
*/

// note: one captured request/response pair, i.e. one row ("rectangle") in the table
struct HttpHistoryEntry {
    int       id         = 0;      // stable identity, never reused
    int       number     = 0;      // 1-based position, as the user counts them
    QString   method;              // GET, POST, ...
    QString   url;                 // the "UserResourceLocater" from the original sketch
    int       status     = 0;      // 0 while the response has not landed yet
    bool      has_params = false;  // carries a query string and/or parameters in the body
    QString   mime;                // text/html, application/json, ...
    QDateTime timestamp;           // when the request left us
    bool      flagged    = false;  // user-set marker, for triage
};

class HttpHistoryRectangleModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

    // note: lets QML show a count and decide whether to draw the empty state
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    /*
     *  note: one role per column. QML delegates read these by name.
     *  note: this is a QAbstractListModel of rows rather than the QStandardItemModel from
     *        the first sketch, because a role-per-column list model is what a QML delegate
     *        can bind to directly -- with QStandardItemModel the delegate has to go through
     *        column indices instead, which reads badly in the .qml
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
        FlaggedRole,
    };
    Q_ENUM(Roles)

    explicit HttpHistoryRectangleModel(QObject* parent = nullptr);

    // note: the three methods QML needs from any QAbstractListModel
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    /*
     *  note: the proxy calls this once per captured exchange, and it is the ONLY way rows
     *        get in -- so when the networking layer lands it only has to call this one method
    */
    Q_INVOKABLE void addEntry(const QString method,
                              const QString url,
                              const int status,
                              const bool has_params,
                              const QString mime,
                              const bool flagged = false);

    // note: called from QML when the user flags/unflags a row for triage
    Q_INVOKABLE void setFlagged(const int row, const bool flagged);

    // note: called from QML when the user clears the history
    Q_INVOKABLE void clear();

signals:
    void countChanged();

private:
    QList<HttpHistoryEntry> history_entries;

    // note: monotonic, so an id is never reused -- not even after a clear()
    int next_id = 1;
};