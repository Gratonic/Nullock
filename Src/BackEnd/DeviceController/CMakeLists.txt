add_library(deviceControllerLib STATIC
    device_controller.cpp
    device_controller.hpp
)

target_link_libraries(deviceControllerLib
    PRIVATE proxyLib
)
