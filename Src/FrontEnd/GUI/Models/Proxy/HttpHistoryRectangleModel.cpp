#include "HttpHistoryRectangleModel.hpp"

HttpHistoryRectangleModel::HttpHistoryRectangleModel(QObject* parent)
    : QAbstractListModel(parent) {
}

int HttpHistoryRectangleModel::rowCount(const QModelIndex& parent) const {
    // note: a list model has no children, so a valid parent means "no rows down there"
    if (parent.isValid()) {
        return 0;
    }

    return history_entries.size();
}

QVariant HttpHistoryRectangleModel::data(const QModelIndex& index, int role) const {
    // note: guard the row before indexing -- QML asks for rows that have just been removed
    if (!index.isValid() || index.row() < 0 || index.row() >= history_entries.size()) {
        return QVariant();
    }

    const HttpHistoryEntry& entry = history_entries.at(index.row());

    switch (role) {
    case IdRole:           return entry.id;
    case NumberRole:       return entry.number;
    case MethodRole:       return entry.method;
    case UrlRole:          return entry.url;
    case StatusRole:       return entry.status;
    case ParamsRole:       return entry.has_params;
    case MimeRole:         return entry.mime;
    // note: formatted here rather than in QML so every row reads the same, and so the
    // delegate does not have to know how we store the timestamp
    case TimestampRole:    return entry.timestamp.toString(Qt::ISODate);
    case FlagRole:         return entry.flag;
    case RequestTextRole:  return entry.request_text;
    case ResponseTextRole: return entry.response_text;
    default:               return QVariant();
    }
}

QHash<int, QByteArray> HttpHistoryRectangleModel::roleNames() const {
    // note: these names are what the delegate in HttpHistory.qml binds to
    QHash<int, QByteArray> role_names;

    role_names[IdRole]           = "entryId";
    role_names[NumberRole]       = "number";
    role_names[MethodRole]       = "method";
    role_names[UrlRole]          = "url";
    role_names[StatusRole]       = "status";
    role_names[ParamsRole]       = "hasParams";
    role_names[MimeRole]         = "mime";
    role_names[TimestampRole]    = "timestamp";
    role_names[FlagRole]         = "flag";
    role_names[RequestTextRole]  = "requestText";
    role_names[ResponseTextRole] = "responseText";

    return role_names;
}

int HttpHistoryRectangleModel::count() const {
    return history_entries.size();
}

void HttpHistoryRectangleModel::addEntry(const QString method,
                                         const QString url,
                                         const int status,
                                         const bool has_params,
                                         const QString mime,
                                         const QString request_text,
                                         const QString response_text,
                                         const int flag) {
    HttpHistoryEntry entry;

    entry.id            = next_id;
    entry.number        = history_entries.size() + 1;
    entry.method        = method;
    entry.url           = url;
    entry.status        = status;
    entry.has_params    = has_params;
    entry.mime          = mime;
    entry.timestamp     = QDateTime::currentDateTime();
    entry.flag          = flag;
    entry.request_text  = request_text;
    entry.response_text = response_text;

    next_id = next_id + 1;

    // note: the begin/end pair is what tells the QML view a row is arriving. Appending to
    // history_entries without it leaves the view showing a stale row count.
    beginInsertRows(QModelIndex(), history_entries.size(), history_entries.size());
    history_entries.append(entry);
    endInsertRows();

    emit countChanged();
}

void HttpHistoryRectangleModel::setFlag(const int row, const int flag) {
    if (row < 0 || row >= history_entries.size()) {
        return;
    }

    // note: clamp rather than trust QML -- an out-of-range flag would index the colour
    // table in the delegate out of bounds
    if (flag < HttpHistoryFlag::None || flag > HttpHistoryFlag::Critical) {
        return;
    }

    if (history_entries[row].flag == flag) {
        return;   // note: no dataChanged for a no-op, or the view repaints for nothing
    }

    history_entries[row].flag = flag;

    // note: only the flag column changed, so tell the view exactly that rather than
    // making it re-read every role on the row
    const QModelIndex changed_index = index(row, 0);
    emit dataChanged(changed_index, changed_index, { FlagRole });
}

void HttpHistoryRectangleModel::cycleFlag(const int row) {
    if (row < 0 || row >= history_entries.size()) {
        return;
    }

    // note: none -> info -> warning -> critical -> none
    const int next = (history_entries.at(row).flag + 1) % (HttpHistoryFlag::Critical + 1);
    setFlag(row, next);
}

QString HttpHistoryRectangleModel::requestTextAt(const int row) const {
    if (row < 0 || row >= history_entries.size()) {
        return QString();
    }

    return history_entries.at(row).request_text;
}

QString HttpHistoryRectangleModel::responseTextAt(const int row) const {
    if (row < 0 || row >= history_entries.size()) {
        return QString();
    }

    return history_entries.at(row).response_text;
}

void HttpHistoryRectangleModel::clear() {
    if (history_entries.isEmpty()) {
        return;
    }

    // note: next_id is deliberately NOT reset -- an id the user has seen should never come
    // back attached to a different request
    beginRemoveRows(QModelIndex(), 0, history_entries.size() - 1);
    history_entries.clear();
    endRemoveRows();

    emit countChanged();
}
