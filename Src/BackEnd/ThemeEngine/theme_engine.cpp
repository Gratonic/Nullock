#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFontDatabase>

#include "theme_engine.hpp"
#include "utils.hpp"

#include <QDebug>

ThemeEngine::ThemeEngine(QObject *parent) {
    loadTheme("default");
}

ThemeEngine* ThemeEngine::getThemeEngineInstance() {
    // note: static here makes the instance globally accessible
    static ThemeEngine instance;

    return &instance;
}

// note: flatten() is a private method; the prefix is the value in a key pair
QVariantMap ThemeEngine::flatten(const QVariantMap& raw_theme, const QString prefix) {
    // map of generated keys (keychain)
    QVariantMap flat;

    // note: both .begin() and .end() return pointers
    for (auto i = raw_theme.begin(); i != raw_theme.end(); ++i) {
        // note: creates a unique key by joining two keys, key: value (holds other key)
        QString key = prefix.isEmpty() ? i.key() : prefix + "." + i.key();

        if (i.value().typeId() == QMetaType::QVariantMap) {
            QVariantMap nested = flatten(i.value().toMap(), i.key());

            // note: this loop is only reached once all keys have been created
            for (auto nestedI = nested.begin(); nestedI != nested.end(); ++nestedI) {
                flat.insert(nestedI.key(), nestedI.value());
            }
        } else {
            // for storing the last key (has no QVarientMap for value)
            flat.insert(key, i.value());
        }
    }

    return flat;
}

void ThemeEngine::loadFonts(const QVariantMap& font_path) {
    for (auto i = font_path.begin(); i != font_path.end(); ++i) {
        QStringList paths = i.value().toStringList();

        for (auto path: paths) {
            int id = QFontDatabase::addApplicationFont(path);

            if (id == -1) {
                qWarning("failed to load font");
            } else {
                QFontDatabase::applicationFontFamilies(id);
            }
        }
    }
}

// for some reason Qt is unable to find the theme file despit it existing and the contructed properly
// note: the themes.qrc file appears to be correct but may be wrong
void ThemeEngine::loadTheme(const QString name)
{
    const QString path = QStringLiteral(":/themes/%1_theme.json").arg(name);
    QFile theme_file(path);

    if (!theme_file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to load theme:" << path
                   << "-" << theme_file.errorString();

        // in order to avoid parsing an unopen file...
        return;
    }

    // create a JSON object with the theme_file
    QJsonParseError err;
    const QJsonDocument theme_doc = QJsonDocument::fromJson(theme_file.readAll(), &err);
    QJsonObject theme_obj = theme_doc.object();

    QVariantMap theme_map = theme_obj.toVariantMap();
    QVariantMap raw_theme = theme_map["theme"].toMap();

    // note: this variable is defined in theme_engine.hpp
    theme_keychain = flatten(raw_theme, "");

    // for fonts...
    QVariantMap fonts = raw_theme["typography"].toMap();
    QVariantMap fonts_path = fonts["fonts_path"].toMap();

    loadFonts(fonts_path);
}

QVariantMap ThemeEngine::getTheme() {
    return theme_keychain;
}

QVariantList ThemeEngine::getKnownThemes() {
    Utils utils;
    QVariantMap settings_map = utils.getSettings();

    // retrieve the known themes
    QVariantMap themes_map = settings_map["themes"].toMap();
    QVariantList known_themes = themes_map["known_themes"].toList();

    return known_themes;
}

void ThemeEngine::addKnownTheme(const QString name) {
    QVariantList known_themes = getKnownThemes();

    // append the new known theme to the end of the list
    known_themes.append(name);


    // write the new known themes to settings
    Utils utils;

    QVariantMap settings_map = utils.getSettings();
    QVariantMap themes_map = settings_map["themes"].toMap();

    themes_map["known_themes"] = known_themes;
    settings_map["themes"] = themes_map;

    utils.saveSettings(settings_map);
}

void ThemeEngine::removeKnownTheme(const QString name) {
    QVariantList known_themes = getKnownThemes();

    // remove all mentions of the theme name
    known_themes.removeAll(name);

    // write the new known themes to settings
    Utils utils;

    QVariantMap settings_map = utils.getSettings();
    QVariantMap themes_map = settings_map["themes"].toMap();

    themes_map["known_themes"] = known_themes;
    settings_map["themes"] = themes_map;

    utils.saveSettings(settings_map);
}