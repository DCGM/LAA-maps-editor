cmake_minimum_required(VERSION 3.5)

project(editor LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GNUInstallDirs)
include(FeatureSummary)

enable_testing()

find_package(Git QUIET REQUIRED)
find_package(Qt5QuickTest REQUIRED)


execute_process(COMMAND
  "${GIT_EXECUTABLE}" describe --dirty --broken --always --tags
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  OUTPUT_VARIABLE GIT_VERSION
  ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions( -DGIT_VERSION="${GIT_VERSION}" )

find_package(Qt5 COMPONENTS Core Quick Xml LinguistTools REQUIRED)
find_package(Qt5QuickCompiler)
#qtquick_compiler_add_resources(RESOURCES editor.qrc)
qt5_add_resources(RESOURCES editor.qrc)

file(GLOB TS_FILES i18n/*.ts)

add_executable(editor WIN32
  src/customnetworkaccessmanager.cpp
  src/filereader.cpp
  src/gpxjsonconvertor.cpp
  src/igc.cpp
  src/imagesaver.cpp
  src/kmljsonconvertor.cpp
  src/networkaccessmanagerfactory.cpp
  src/main.cpp
  editor.rc
  ${RESOURCES}
  ${TS_FILES}
)

add_executable(atest-editor WIN32
  src/customnetworkaccessmanager.cpp
  src/filereader.cpp
  src/gpxjsonconvertor.cpp
  src/igc.cpp
  src/imagesaver.cpp
  src/kmljsonconvertor.cpp
  src/networkaccessmanagerfactory.cpp
  src/main.cpp
  editor.rc
  ${RESOURCES}
  ${TS_FILES}
)

add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_test(NAME atest-editor COMMAND atest-editor)
set_target_properties(atest-editor PROPERTIES COMPILE_DEFINITIONS RUN_TESTS=1)



QT5_ADD_TRANSLATION(QM_FILES ${TS_FILES}
    OPTIONS "-idbased")
add_custom_target(translations DEPENDS ${QM_FILES})
add_dependencies(editor translations)

QT5_CREATE_TRANSLATION(QT_FILES "${CMAKE_SOURCE_DIR}"
    OPTIONS "-no-obsolete")

install(FILES ${QM_FILES}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/editor/i18n")

install(FILES "editor.desktop"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")

install(FILES "images/editor64.ico" "images/editor64.png"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/applications/64x64")

install(TARGETS editor RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR})

target_compile_definitions(editor
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(editor
  PRIVATE Qt5::Core Qt5::Quick Qt5::Xml)

target_compile_definitions(atest-editor
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(atest-editor
  PRIVATE Qt5::Core Qt5::Quick Qt5::Xml Qt5::QuickTest)



option(DEPLOY_QT_LIBRARIES "Deploy Qt libraries to executable path" OFF)
if(DEPLOY_QT_LIBRARIES)
    if(WIN32)
        include(DeployQt)
        windeployqt(editor)
    elseif(APPLE)
        include(DeployQt)
        macdeployqt(editor)
    endif()
endif()
 feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)


# generate proper GUI program on specified platform
if(WIN32) # Check if we are on Windows
    if(MSVC) # Check if we are using the Visual Studio compiler
	set_target_properties(${PROJECT_NAME} PROPERTIES
	    WIN32_EXECUTABLE YES
	    LINK_FLAGS "/ENTRY:mainCRTStartup"
	)
    elseif(CMAKE_COMPILER_IS_GNUCXX)
	    # SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mwindows") # Not tested
    else()
	message(SEND_ERROR "You are using an unsupported Windows compiler! (Not MSVC or GCC)")
    endif(MSVC)
elseif(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
	    MACOSX_BUNDLE YES
    )
elseif(UNIX)
    # Nothing special required
else()
    message(SEND_ERROR "You are on an unsupported platform! (Not Win32, Mac OS X or Unix)")
endif(WIN32)
