#include "customnetworkaccessmanager.h"

CustomNetworkAccessManager::CustomNetworkAccessManager(QObject *parent) : QNetworkAccessManager(parent)
{
    m_userAgent = QString("LaaViewer/%1").arg(GIT_VERSION);
}
