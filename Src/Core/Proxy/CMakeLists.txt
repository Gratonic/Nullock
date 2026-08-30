# NOTE: DO NOT LINK INTERNAL LIBRARIES TO THIS LIB!!! THIS LIB MUST REMAIN AS A STAND ALONE LIB SO IT CAN BE USED IN OTHER PEOPLE'S PROGRAMS. 

# TODO: link OpenSSL lib; for all proxy networking (must not use Qt6::Network)

# Create shared library for the proxy (.so)
add_library(proxyLib SHARED
    proxy.cpp
    proxy.hpp

    ScopeTool/scope_tool.hpp
    SitemapTool/sitemap_tool.hpp
    InterceptTool/intercept_tool.hpp
    RepeaterTool/repeater_tool.hpp

    ScopeTool/scope_tool.cpp
    SitemapTool/sitemap_tool.cpp
    InterceptTool/intercept_tool.cpp
    RepeaterTool/repeater_tool.cpp
)

target_link_libraries(proxyLib
    # Qt6 libs
    PRIVATE Qt6::Core
    PRIVATE Qt6::Quick

    # for CLI parsing
    PRIVATE lyra
)