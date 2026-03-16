cmake_minimum_required(VERSION 3.16)

project(SyllabusConqueror VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Sql)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appSyllabusConqueror
    main.cpp
    TopicModel.h     TopicModel.cpp
    FocusController.h FocusController.cpp
    WindowManager.h  WindowManager.cpp
    DatabaseManager.h DatabaseManager.cpp
    SessionModel.h SessionModel.cpp
)

qt_add_qml_module(appSyllabusConqueror
    URI SyllabusConqueror
    VERSION 1.0
    QML_FILES
        Main.qml
        PlanningView.qml
        FocusView.qml
        FocusButton.qml
)

set_target_properties(appSyllabusConqueror PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSyllabusConqueror
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appSyllabusConqueror
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
