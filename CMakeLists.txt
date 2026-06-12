cmake_minimum_required(VERSION 3.24)

project(Nullock VERSION 0.1 LANGUAGES CXX)

# set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# enable automoc and autorcc
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# find Qt6 with required components
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    Network
)

# add source subdirectory
add_subdirectory(Src)

# add Tests subdirectory (contains the code used to run tests)
# enable_testing()
# add_subdirectory(Tests)
