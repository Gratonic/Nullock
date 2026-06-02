# NOTE: DO NOT LINK INTERNAL LIBRARIES TO THIS LIB!!! THIS LIB MUST REMAIN AS A STAND ALONE LIB SO IT CAN BE USED IN OTHER PEOPLE'S PROGRAMS. 

# Create static library for Proxy
add_library(Proxy SHARED
    proxy.cpp
    proxy.hpp
)

# Include directories
target_include_directories(Proxy PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
