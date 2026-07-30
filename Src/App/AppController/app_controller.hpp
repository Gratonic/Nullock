#pragma once

#include <QObject>
#include <QVariantMap>

#include "HttpHistoryRectangleModel.hpp"

class AppController : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap ThemeEngineInstance READ ThemeEngineInstance NOTIFY themeChanged())

    /* note:
     * the HTTP History table's model, reached from QML as App.HttpHistoryModel.
     *
     * note: it is exposed through App rather than imported from the GUI module on purpose.
     * nullock.qml is itself PART of the GUI module, and a module cannot import itself --
     * that is the "QML module not found" error. Going through the App singleton uses the
     * bridge that already exists (qmlRegisterSingletonInstance in nullock.cpp) and needs
     * no import beyond `import Nullock`.
     *
     * note: owning it here in C++ also fixes two things at once. The tab is built by a
     * Loader, which destroys and recreates its item on every tab switch -- a model living
     * in QML would take the whole capture history with it each time. And the proxy will
     * need to write to it from C++ once the networking layer lands:
     *     app_controller.httpHistoryModel()->addEntry(...)
     * CONSTANT because the pointer never changes; the model signals its own updates.
    */
    Q_PROPERTY(HttpHistoryRectangleModel* HttpHistoryModel READ httpHistoryModel CONSTANT)
public:
    // note: this is the class constructor (runs once whenever an instance of this class is created); if a parent QObject is passed, App becomes a child of the parent QObject
    AppController(QObject* parent = nullptr);

    // for ThemeEngine
    Q_INVOKABLE void loadTheme(const QString& theme_name);

    // note: the proxy/NullE side calls this to append captures and to flag them
    HttpHistoryRectangleModel* httpHistoryModel();
private:
    // note: this determines the name that is used for ThemeEngine access in the QML module
    QVariantMap ThemeEngineInstance();

    // note: parented to this AppController, so it lives exactly as long as the app does
    HttpHistoryRectangleModel http_history_model { this };
signals:
    void themeChanged();
};