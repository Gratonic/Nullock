# Add Core submodules
add_subdirectory(AppController)
add_subdirectory(APIs)
add_subdirectory(Database)
add_subdirectory(Networking)
add_subdirectory(NullE)
add_subdirectory(Proxy)
add_subdirectory(Utils)

# Expose Core targets to parent scope
set(CORE_LIBRARIES
    AppController
    APIs
    Database
    Networking
    NullE
    Proxy
    Utils
    PARENT_SCOPE
)
