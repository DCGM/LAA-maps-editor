# Add more folders to ship with the application, here

QT += qml quick xml
CONFIG += qtquickcompiler
CONFIG += c++11

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    filereader.cpp \
    customnetworkaccessmanager.cpp \
    networkaccessmanagerfactory.cpp \
    imagesaver.cpp \
    igc.cpp \
    kmljsonconvertor.cpp \
    gpxjsonconvertor.cpp


# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

HEADERS += \
    filereader.h \
    customnetworkaccessmanager.h \
    networkaccessmanagerfactory.h \
    imagesaver.h \
    igc.h \
    kmljsonconvertor.h \
    gpxjsonconvertor.h

LANGUAGES = cs_CZ en_US

# var, prepend, append
defineReplace(prependAll) {
    for(a,$$1):result += $$2$${a}$$3
    return($$result)
}

unix: {
    exists( $(QTDIR)/bin/lrelease ) {
        LRELEASE = $(QTDIR)/bin/lrelease
    } else {
        exists( /usr/bin/lrelease-qt5 ) {
            LRELEASE = /usr/bin/lrelease-qt5
        } else {
            LRELEASE = lrelease-qt5
        }
    }
}
win32: {
    LRELEASE = lrelease
}
TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/i18n/editor_,.ts)

updateqm.input = TRANSLATIONS
updateqm.output = $$OUT_PWD/${QMAKE_FILE_BASE}.qm
updateqm.commands = $$LRELEASE -idbased -silent ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_BASE}.qm
updateqm.CONFIG += no_link target_predeps
QMAKE_EXTRA_COMPILERS += updateqm

qmfiles.files = $$prependAll(LANGUAGES, $$OUT_PWD/editor_,.qm)
unix:!andorid: qmfiles.path = /opt/$${TARGET}/share/editor/i18n
qmfiles.CONFIG += no_check_exist

INSTALLS += qmfiles

editordata.files = editor_defaults.json
unix:!andorid: editordata.path = /opt/$${TARGET}/share/editor
editordata.CONFIG += no_check_exist
INSTALLS += editordata

desktop.files = editor.desktop
unix:!andorid: desktop.path = /opt/$${TARGET}/share/applications
desktop.CONFIG += no_check_exist
INSTALLS += desktop

icons64.files = editor64.png
unix:!andorid: icons64.path = /opt/$${TARGET}/share/icons/hicolor/applications/64x64
icons64.CONFIG += no_check_exist
INSTALLS += icons64


CODECFORTR = UTF-8
CODECFORSRC = UTF-8

RC_ICONS = editor64.ico

RESOURCES += editor.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


DEFINES += GIT_VERSION='"\\\"$$system(git describe --dirty --broken --always --tags)\\\""'
