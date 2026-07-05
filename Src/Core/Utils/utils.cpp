#include "utils.hpp"

#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>


QVariantMap Utils::getSettings() {
    QFile settings_file("qrc:/settings/settings.json");

    if (!settings_file.open(QIODevice::ReadOnly)) {
        qWarning("failed to fetch known themes");
    }

    // create a JSON object with the settings_file
    QJsonDocument settings_doc = QJsonDocument::fromJson(settings_file.readAll());
    QJsonObject settings_obj = settings_doc.object();

    // closes the settings_file (best practice)
    settings_file.close();

    // convert the settings_obj to a QVariantMap
    QVariantMap settings_map = settings_obj.toVariantMap();

    return settings_map;
}

void Utils::saveSettings(QVariantMap settings_map) {
    QFile settings_file("qrc:/settings/settings.json");

    if (!settings_file.open(QIODevice::WriteOnly)) {
        qWarning("failed to open settings file for writing");
    }

    // convert the provide QVariantMap (settings_map) to JSON bytes
    QJsonDocument settings_doc = QJsonDocument::fromVariant(settings_map);

    // overwrites the settings file with the new settings data
    settings_file.write(settings_doc.toJson());

    // closes the settings_file (best practice)
    settings_file.close();
}