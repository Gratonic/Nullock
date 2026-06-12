# NOTE: DO NOT LINK INTERNAL LIBRARIES TO THIS LIB!!! THIS LIB MUST REMAIN AS A STAND ALONE LIB SO IT CAN BE USED IN OTHER PEOPLE'S PROGRAMS. 

# TODO: link OpenSSL lib; for all proxy networking (must not use Qt6::Network)

# Create static library for Proxy
add_library(proxyLib SHARED
    proxy.cpp
    proxy.hpp
)
