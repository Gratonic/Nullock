#pragma once

#include <string>

#include <QObject>
#include <QVariantMap>
#include <QList>

class ThemeEngine {
    /*
     *  note: this class manually implements a Singleton (recommended approach for all Qt versions)
     *  note: a Singleton class can only have one active instance of itself at any time (program wide - global)
     *  note: this is done using a constructor and the getThemeEngineInstance() method (returns a pointer to this class/an instance of this class)
    */
public:
    // note: the static keyword in this case says that the constructor method belongs to this class and not an instance. This essentially makes this method accessable globally. This means making multiple instances is avoided.
    // example use case: ThemeEngineManager::getThemeEngineInstance(), not... instance.getThemeEngineInstance().
    static ThemeEngine* getThemeEngineInstance();

    // note: this method is used to avoid repeatedly fetching theme data (colors, typography, etc.)
    QVariantMap getTheme();
    // note: this method is called by QML when the user changes their theme
    // note: the purpose of this method is to enable the computer to remember the last theme
    void setTheme(const std::string name);

    // called within QML to load the users chosen theme or the default one if they have not chosen one
    void loadTheme(const QString name);

    // called within QML to get and change the known themes in the settings
    QVariantList getKnownThemes();

    void addKnownTheme(const QString name);
    void removeKnownTheme(const QString name);
private:
    ThemeEngine(QObject* parent = nullptr);

    QVariantMap flatten(const QVariantMap& raw_theme, const QString prefix);

    // for loadTheme(); globally accessible
    QVariantMap theme_keychain;

    void loadFonts(const QVariantMap& font_path);
};