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

// turns on logging of context (file+line number) in c++
#define QT_MESSAGELOGCONTEXT

void myMessageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg) {
    QString txt;

    QDateTime now = QDateTime::currentDateTime();
    int offset = now.offsetFromUtc();
    now.setOffsetFromUtc(offset);

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
    outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text);
    QTextStream ts(&outFile);

    QTextStream std_out(stdout, QIODevice::WriteOnly);
    QTextStream std_err(stderr, QIODevice::WriteOnly);

    switch (type) {
    case QtDebugMsg:
        txt = QString("%1 [D] %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << Qt::endl ;
        break;
    case QtWarningMsg:
        txt = QString("%1 [W]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_out << txt << Qt::endl;
        break;
    case QtCriticalMsg:
        txt = QString("%1 [C]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << Qt::endl;
        break;
    case QtFatalMsg:
        txt = QString("%1 [F]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << Qt::endl;
        abort();
    default:
        txt = QString("%1 [O]: %2:%3 @ %4(): %5").arg(now.toString(Qt::ISODate)).arg(context.file).arg(context.line).arg(context.function).arg(msg);
        std_err << txt << Qt::endl;
        break;

    }
    ts << txt << Qt::endl;

    outFile.close();
}

int main(int argc, char *argv[]) {

    QGuiApplication app(argc, argv);

    app.setOrganizationName("Brno University of Technology");
    app.setOrganizationDomain("fit.vutbr.cz");
    app.setApplicationName("LAA Maps Editor");

    qInstallMessageHandler(myMessageHandler);

#if defined(Q_OS_LINUX)
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator() +"editor.log";
#endif


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

    QString i18nFilename = QLatin1String("editor_") + QLocale::system().name();
    if (translator.load(i18nFilename, "./")) {
        qDebug() << i18nFilename << "./" << QLocale::system().bcp47Name();
        app.installTranslator(&translator);
        engine.rootContext()->setContextProperty("locale", QLocale::system().bcp47Name());

    } else if (translator.load(i18nFilename, QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        qDebug() << i18nFilename << QLibraryInfo::location(QLibraryInfo::TranslationsPath) << QLocale::system().bcp47Name();
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
    engine.rootContext()->setContextProperty("version", QString::fromLocal8Bit(GIT_VERSION));

    qDebug() << "Starting build " << QString::fromLocal8Bit(GIT_VERSION) << " "<< QString::fromLocal8Bit(__DATE__) << " " <<  QString::fromLocal8Bit(__TIME__);
    qDebug() << "Qt" << qVersion();
    qDebug() << QSslSocket::supportsSsl() << QSslSocket::sslLibraryBuildVersionString() << QSslSocket::sslLibraryVersionString();

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
