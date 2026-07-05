# main executable
add_executable(Nullock
    nullock.cpp
    AppController/app_controller.cpp

    ../Core/Resources/icons.qrc
)

target_link_directories(Nullock 
    PRIVATE ${CMAKE_SOURCE_DIR}/Src/BackEnd/ThemeEngine/
)

# link libraries and modules
target_link_libraries(Nullock
    # Qt6 libs
    PRIVATE Qt6::Core
    PRIVATE Qt6::Quick

    # BackEnd libs/modules
    # cacheLib
    themeEngineLib

    # Core libs/modules
    # apiLib
    # networkingLib
    # nulleLib
    # utilsLib

    # FrontEnd libs/modules 
    guiModule
    # uiResourcesLib
    # FrontEndResources
)