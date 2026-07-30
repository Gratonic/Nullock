#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

#include "AppController/app_controller.hpp"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    AppController app_controller;

    /* note:
     * Nullock is the name for the QML Module
     * 1 and 0 make up the version number (1.0)
     * App is the name for the interface [must use uppercase letter] (ex: app.ThemeEngineInstance)
    */
    qmlRegisterSingletonInstance("Nullock", 1, 0, "App", &app_controller);

    const QUrl url(QStringLiteral("qrc:/GUI/Main/nullock.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    return app.exec();
}