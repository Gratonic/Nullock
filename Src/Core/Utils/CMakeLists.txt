# note: a shared library is created because it fixes some linker errors and prevents the binary from becoming bloated in the case this library became very large
add_library(utilsLib SHARED
    utils.cpp
    utils.hpp
)

# tells other files where they can find the libraries files - highly important
target_include_directories(utilsLib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(utilsLib PRIVATE
    Qt6::Core
)
