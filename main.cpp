#include <QtQml>
#include <QtGui>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QQuickView>
#include <QQuickItem>
#include <QtCore/QTranslator>
#include <QtDebug>
#include <QFile>
#include <QTextStream>

#include "filereader.h"
#include "networkaccessmanagerfactory.h"
#include "imagesaver.h"
#include "igc.h"
#include "kmljsonconvertor.h"
#include "gpxjsonconvertor.h"


void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;

#if defined(Q_OS_LINUX)
    if (!QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).exists()) {
        QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    }
    QFile outFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator() +"editor.log");
#elif (defined (Q_OS_WIN) || defined (Q_OS_WIN32) || defined (Q_OS_WIN64))
    QFile outFile("editor.log");
#else
    QFile outfile("editor.log");
#endif
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);

    QTextStream std_out(stdout, QIODevice::WriteOnly);
    QTextStream std_err(stderr, QIODevice::WriteOnly);

    switch (type) {
    case QtDebugMsg:
        txt = QString("[D] %1:%2 @ %3(): %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl ;
        break;
    case QtWarningMsg:
        txt = QString("[W]: %1:%2 @ %3(): %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << endl;
        break;
    case QtCriticalMsg:
        txt = QString("[C]: %1:%2 @ %3(): %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;
    case QtFatalMsg:
        txt = QString("[F]: %1:%2 @ %3(): %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        abort();
    default:
        txt = QString("[O]: %1:%2 @ %3(): %4").arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << endl;
        break;

    }
    ts << txt;
#if (defined (Q_OS_WIN) || defined (Q_OS_WIN32) || defined (Q_OS_WIN64))
    ts << ('\r');
#endif
    ts << endl;

    outFile.close();
}

int main(int argc, char *argv[]) {

    QGuiApplication app(argc, argv);

    qInstallMessageHandler(myMessageHandler);

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

    if (translator.load(QLatin1String("editor_") + QLocale::system().name(), "./")) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());

    } else if (translator.load(QLatin1String("editor_") + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());

    } else {
        qDebug() << "translation.load() failed - falling back to English";
        if (translator.load(QLatin1String("editor_en_US")   , "./")) {
            app.installTranslator(&translator);
        } else if (translator.load(QLatin1String("editor_en_US"), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
            app.installTranslator(&translator);
        }

        engine.rootContext()->setContextProperty("locale","en");
    }

    engine.rootContext()->setContextProperty("builddate", QString::fromLocal8Bit(__DATE__));
    engine.rootContext()->setContextProperty("buildtime", QString::fromLocal8Bit(__TIME__));

    qDebug() << "Starting build " << QString::fromLocal8Bit(__DATE__) << " " <<  QString::fromLocal8Bit(__TIME__);

    NetworkAccessManagerFactory namFactory;

    engine.setNetworkAccessManagerFactory(&namFactory);
    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath() );
    //    engine.rootContext()->setContextProperty("QStandardPathsApplicationFilePath", QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().left(QFileInfo( QCoreApplication::applicationFilePath() ).dir().absolutePath().size()-4) );
    engine.rootContext()->setContextProperty("QStandardPathsHomeLocation", QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0]);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);

    window->setIcon(QIcon(":/editor64.png"));
    window->show();
    return app.exec();


}
