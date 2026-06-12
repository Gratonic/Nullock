qt_add_resources(uiResources
    resources.qrc
)

# add resource target as library
add_library(uiResourcesLib STATIC ${uiResources})

target_link_libraries(uiResourcesLib PRIVATE
    Qt6::Core 
)
