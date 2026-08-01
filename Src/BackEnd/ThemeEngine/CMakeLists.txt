qt_add_qml_module(themeEngineLib
    URI ThemeEngine
    VERSION 1.0

    SOURCES
        theme_engine.cpp
        theme_engine.hpp

    RESOURCES
        ../../Core/Resources/themes.qrc
)

target_link_libraries(themeEngineLib
    PRIVATE Qt6::Core
    PRIVATE Qt6::Gui

    utilsLib
)