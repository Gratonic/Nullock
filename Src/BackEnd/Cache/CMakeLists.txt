add_library(cacheLib STATIC
    cache_handler.cpp
    cache_handler.hpp
)

target_link_libraries(cacheLib
    PRIVATE Qt6::Core
)
