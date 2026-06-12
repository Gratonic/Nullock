add_library(networkingLib STATIC
    networking.cpp
    networking.hpp
)

target_link_libraries(networkingLib PRIVATE
    Qt6::Core
    Qt6::Network
)
