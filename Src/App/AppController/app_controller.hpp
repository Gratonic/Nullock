#pragma once

#include <QObject>
#include <QVariantMap>

class AppController : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap ThemeEngineInstance READ ThemeEngineInstance NOTIFY themeChanged())
public:
    // note: this is the class constructor (runs once whenever an instance of this class is created); if a parent QObject is passed, App becomes a child of the parent QObject
    AppController(QObject* parent = nullptr);

    // for ThemeEngine
    Q_INVOKABLE void loadTheme(const QString& theme_name);
private:
    // note: this determines the name that is used for ThemeEngine access in the QML module
    QVariantMap ThemeEngineInstance();
signals:
    void themeChanged();
};