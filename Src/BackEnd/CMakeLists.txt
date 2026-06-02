# Add BackEnd submodules
add_subdirectory(Cache)

# Expose BackEnd targets to parent scope
set(BACKEND_LIBRARIES
    Cache
    PARENT_SCOPE
)
