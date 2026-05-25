# Create static library for Null-E
add_library(NullE STATIC
    nulle.cpp
    nulle.hpp
)

# Link Qt libraries
target_link_libraries(NullE PRIVATE
    Qt6::Core
)

# Include directories
target_include_directories(NullE PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
