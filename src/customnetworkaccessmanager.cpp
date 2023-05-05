#include <QtGui>
#include "customnetworkaccessmanager.h"

CustomNetworkAccessManager::CustomNetworkAccessManager(QObject* parent)
    : QNetworkAccessManager(parent)
{
    m_userAgent = QString("Mozilla/5.0 (%1; %2 %3) QtWebEngine/%4 LaaEditor/%5")
                        .arg(QSysInfo::productType())
                        .arg(QSysInfo::currentCpuArchitecture())
                        .arg(QGuiApplication::platformName())
                        .arg(qVersion())
                        .arg(GIT_VERSION);
    qDebug() << m_userAgent;
}
