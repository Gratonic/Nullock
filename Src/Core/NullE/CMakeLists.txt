add_library(nulleLib SHARED
    nulle.cpp
    nulle.hpp
)

target_link_libraries(nulleLib PRIVATE
    Qt6::Core
)
