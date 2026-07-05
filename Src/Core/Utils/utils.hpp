#include <QVariantMap>

class Utils {
public:
    QVariantMap getSettings();
    void saveSettings(QVariantMap settings_map);
};
