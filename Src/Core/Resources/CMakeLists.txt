qt_add_library(uiResourcesLib STATIC
    icons.qrc

    themes.qrc
    fonts.qrc
    settings.qrc
)

target_link_libraries(uiResourcesLib PUBLIC
    Qt6::Core
)