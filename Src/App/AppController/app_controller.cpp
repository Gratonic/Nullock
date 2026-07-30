#include "app_controller.hpp"

#include "theme_engine.hpp"

AppController::AppController(QObject *parent) {

}

void AppController::loadTheme(const QString& theme_name) {
    ThemeEngine::getThemeEngineInstance()->loadTheme(theme_name);

    emit themeChanged();
}

QVariantMap AppController::ThemeEngineInstance() {
    return ThemeEngine::getThemeEngineInstance()->getTheme();
}

HttpHistoryRectangleModel* AppController::httpHistoryModel() {
    return &http_history_model;
}