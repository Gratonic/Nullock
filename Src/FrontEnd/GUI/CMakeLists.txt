qt_add_qml_module(guiModule
    URI GUI
    VERSION 1.0
    
    SOURCES
    Models/DevicesHub/devices_hub_model.cpp
    Models/DevicesHub/devices_hub_model.hpp
    Models/ExtensionsHub/extensions_hub_model.cpp
    Models/ExtensionsHub/extensions_hub_model.hpp
    Models/IntruderHub/intruder_hub_model.cpp
    Models/IntruderHub/intruder_hub_model.hpp
    Models/Overview/overview_model.cpp
    Models/Overview/overview_model.hpp
    Models/Proxy/HttpHistoryRectangleModel.cpp
    Models/Proxy/HttpHistoryRectangleModel.hpp
    Models/RepeaterHub/repeater_hub_model.cpp
    Models/RepeaterHub/repeater_hub_model.hpp
    Models/Workspace/workspace_model.cpp
    Models/Workspace/workspace_model.hpp
    
    QML_FILES
    Main/nullock.qml
    Components/DevicesHub/DevicesConsole.qml
    Components/DevicesHub/Devices.qml
    Components/ExtensionsHub/ExtensionsConsole.qml
    Components/ExtensionsHub/Extensions.qml
    Components/IntruderHub/IntruderConsole.qml
    Components/IntruderHub/Intruder.qml
    Components/Overview/Scope.qml
    Components/Overview/Sitemap.qml
    Components/Proxy/HttpHistory.qml
    Components/Proxy/Intercept.qml
    Components/RepeaterHub/RepeaterConsole.qml
    Components/RepeaterHub/Repeater.qml
    Components/Workspace/Notes.qml
    Components/Workspace/ReportGenerator.qml
    Components/Workspace/Settings.qml
    Components/Workspace/Themes.qml
)

target_link_libraries(guiModule PRIVATE
    Qt6::Core
    # Qt6::Qml
    Qt6::Gui
    Qt6::Quick
    uiResourcesLib
)