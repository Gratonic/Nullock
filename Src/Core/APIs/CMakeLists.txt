add_library(apiLib SHARED
    ExtensionsAPI/extensions_api.cpp
    ExtensionsAPI/extensions_api.hpp
)

target_link_libraries(apiLib PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
)
