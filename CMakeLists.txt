cmake_minimum_required(VERSION 3.5)

project(editor LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_VERBOSE_MAKEFILE ON)

include(GNUInstallDirs)
include(FeatureSummary)


# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check http://doc.qt.io/qt-5/deployment-android.html for more information.
# They need to be set before the find_package(Qt5 ...) call.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()


find_package(Git QUIET REQUIRED)

execute_process(COMMAND
  "${GIT_EXECUTABLE}" describe --dirty --broken --always --tags
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  OUTPUT_VARIABLE GIT_VERSION
  ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions( -DGIT_VERSION="${GIT_VERSION}" )

find_package(Qt5 COMPONENTS Core Quick Xml LinguistTools REQUIRED)



file(GLOB TS_FILES i18n/*.ts)

add_executable(editor
  customnetworkaccessmanager.cpp
  filereader.cpp
  gpxjsonconvertor.cpp
  igc.cpp
  imagesaver.cpp
  kmljsonconvertor.cpp
  networkaccessmanagerfactory.cpp
  main.cpp
  editor.qrc
  ${TS_FILES}
)

QT5_ADD_TRANSLATION(QM_FILES ${TS_FILES}
    OPTIONS "-idbased")
add_custom_target(translations DEPENDS ${QM_FILES})
add_dependencies(editor translations)

QT5_CREATE_TRANSLATION(QT_FILES "${CMAKE_SOURCE_DIR}"
    OPTIONS "-no-obsolete")

install(FILES ${QM_FILES}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/editor/i18n")

install(FILES "editor_defaults.json"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/editor")

install(FILES "editor.desktop"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")

install(FILES "editor64.ico" "editor64.png"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/applications/64x64")

install(TARGETS editor RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR})

target_compile_definitions(editor
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(editor
  PRIVATE Qt5::Core Qt5::Quick Qt5::Xml)



if(Qt5_FOUND AND WIN32 AND TARGET Qt5::qmake AND NOT TARGET Qt5::windeployqt)
    get_target_property(_qt5_qmake_location Qt5::qmake IMPORTED_LOCATION)

    execute_process(
        COMMAND "${_qt5_qmake_location}" -query QT_INSTALL_PREFIX
        RESULT_VARIABLE return_code
        OUTPUT_VARIABLE qt5_install_prefix
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    set(imported_location "${qt5_install_prefix}/bin/windeployqt.exe")

    if(EXISTS ${imported_location})
        add_executable(Qt5::windeployqt IMPORTED)

        set_target_properties(Qt5::windeployqt PROPERTIES
            IMPORTED_LOCATION ${imported_location}
        )
    endif()
endif()

 feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
