cmake_minimum_required(VERSION 3.16)
project(SyllabusTests LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Test Sql Quick)

add_executable(SyllabusTests
    SyllabusTests.cpp
    ../TopicModel.cpp
    ../SessionModel.cpp
    ../DatabaseManager.cpp
    ../FocusController.cpp
)

target_link_libraries(SyllabusTests
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Test
        Qt6::Sql
        Qt6::Quick
)

target_include_directories(SyllabusTests PRIVATE ..)
