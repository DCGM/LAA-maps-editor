# Add more folders to ship with the application, here
folder_01.source = qml/editor
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    filereader.cpp \
    customnetworkaccessmanager.cpp \
    networkaccessmanagerfactory.cpp \
    imagesaver.cpp \
    igc.cpp \
    kmljsonconvertor.cpp \
    gpxjsonconvertor.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2controlsapplicationviewer/qtquick2controlsapplicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    filereader.h \
    customnetworkaccessmanager.h \
    networkaccessmanagerfactory.h \
    imagesaver.h \
    igc.h \
    kmljsonconvertor.h \\
    gpxjsonconvertor.h

QT += widgets xml

OTHER_FILES += \
    qml/editor/parser_fn.js \
    qml/editor/CupTextData.qml \
    qml/editor/TracksListPolygonsDelegate.qml \
    qml/editor/PropertiesDetail.qml \
    qml/editor/NativeText.qml \
    qml/editor/NativeTextInput.qml

LANGUAGES = cs_CZ en_US

# var, prepend, append
defineReplace(prependAll) {
    for(a,$$1):result += $$2$${a}$$3
    return($$result)
}

LRELEASE = lrelease

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/i18n/editor_,.ts)

updateqm.input = TRANSLATIONS
updateqm.output = $$OUT_PWD/${QMAKE_FILE_BASE}.qm
updateqm.commands = $$LRELEASE -idbased -silent ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_BASE}.qm
updateqm.CONFIG += no_link target_predeps
QMAKE_EXTRA_COMPILERS += updateqm

qmfiles.files = $$prependAll(LANGUAGES, $$OUT_PWD/editor_,.qm)
# qmfiles.path = /usr/share/$${TARGET}/i18n
qmfiles.CONFIG += no_check_exist

INSTALLS += qmfiles

CODECFORTR = UTF-8
CODECFORSRC = UTF-8

RC_ICON = editor64.ico

RESOURCES += \
    editor.qrc

# CONFIG += qtquickcompiler


win32 {
DEFINES += BUILDTIME=\\\"$$system('echo %time%')\\\"
DEFINES += BUILDDATE=\\\"$$system('echo %date%')\\\"
} else {
DEFINES += BUILDTIME=\\\"$$system(date '+%H:%M.%s')\\\"
DEFINES += BUILDDATE=\\\"$$system(date '+%d/%m/%y')\\\"
}
