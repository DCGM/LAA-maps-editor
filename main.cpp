#include <QtQml>
#include <QtGui>
#include <QApplication>
#include <QQuickWindow>
#include <QQuickView>
#include <QQuickItem>
#include <QtCore/QTranslator>
#include <QtDebug>
#include <QFile>
#include <QTextStream>

#include "qtquick2controlsapplicationviewer.h"
#include "filereader.h"
#include "networkaccessmanagerfactory.h"
#include "imagesaver.h"
#include "igc.h"
#include "kmljsonconvertor.h"
#include "gpxjsonconvertor.h"


void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;
    switch (type) {
    case QtDebugMsg:
        txt = QString("Debug: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        abort();
    default:
        txt = QString("Other: %1:%2 in %3 %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        break;
    }
    QFile outFile("editor.log");
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    ts << txt << endl;
    outFile.close();
}

int main(int argc, char *argv[]) {

    QApplication app(argc, argv);
    //    QGuiApplication app(argc, argv);


    qInstallMessageHandler(myMessageHandler); // FIXME: timto se zapina vytvareni logu do souboru


    QQmlApplicationEngine engine;

    //    qDebug() << "app.libraryPaths() "  << app.libraryPaths();
    //    qDebug() << "engine.importPathList()" << engine.importPathList();
    //    qDebug() << "engine.pluginPathList()" << engine.pluginPathList();

    qmlRegisterType<ImageSaver>("cz.mlich", 1, 0, "ImageSaver");
    qmlRegisterType<FileReader>("cz.mlich", 1, 0, "FileReader");
    qmlRegisterType<IgcFile>("cz.mlich", 1, 0, "IgcFile");
    qmlRegisterType<KmlJsonConvertor>("cz.mlich", 1, 0, "KmlJsonConvertor");
    qmlRegisterType<GpxJsonConvertor>("cz.mlich", 1, 0, "GpxJsonConvertor");


    QTranslator translator;
    QTranslator qtbasetranslator;

    //    if (translator.load(QLatin1String("editor_") + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
    if (translator.load(QLatin1String("editor_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());

        if (QLocale::system().name() == "cs_CZ") {
            if (qtbasetranslator.load("qtbase_cs", "./")) {
                app.installTranslator(&qtbasetranslator);
                qDebug() << "loading qtbase_cs";
            }
        }

    } else {
        qDebug() << "translation.load() failed - falling back to English";
        //        if (translator.load(QLatin1String("editor_en_US") , QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        if (translator.load(QLatin1String("editor_en_US")   , "./")) {
            app.installTranslator(&translator);
        }
        engine.rootContext()->setContextProperty("locale","en");
    }

    engine.rootContext()->setContextProperty("builddate", QString::fromLocal8Bit(__DATE__));
    engine.rootContext()->setContextProperty("buildtime", QString::fromLocal8Bit(__TIME__));


    NetworkAccessManagerFactory namFactory;

    engine.setNetworkAccessManagerFactory(&namFactory);
    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath() );
    //    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().left(QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().size()-4) );
    engine.rootContext()->setContextProperty("QStandardPathsHomeLocation", QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0]);
    engine.load(QUrl("qml/editor/main.qml"));


    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);

    window->setIcon(QIcon(":/editor64.png"));
    window->show();
    return app.exec();


}
